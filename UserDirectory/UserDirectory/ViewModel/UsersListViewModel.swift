//
//  UsersListViewModel.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import Foundation
import Combine
import SwiftUI
import CoreData

class UsersListViewModel: ObservableObject {
    
    private var cancellable: AnyCancellable?
    private let requestHandler: RequestHandler?
    @Published var usersModel: [UsersDataLocal] = []
    @Published private(set) var state: LoadingState<LoadingViewModel> = .idle
    @Published var showErrorAlert = false
    
    private var offset: Int = 0
    let userCoreDataManager: UserCoreDataManager
    
    init(requestHandler: RequestHandler? = nil,persistenceController: PersistenceController) {
        self.requestHandler = requestHandler
        userCoreDataManager = UserCoreDataManager(persistenceController: persistenceController)
    }
    
    func incrementOffset() {
        self.offset += 1
    }
    
    func loadData(loadMore: Bool? = false) {
        guard state != .loading else {
            return
        }
        state = .loading
        if let loadMore = loadMore, loadMore == true {
            self.incrementOffset()
        }
        guard let requestHandler = requestHandler else { return }
        
        requestHandler.request(route: .getUsers(page: String(offset), results: "8")) { [weak self] result in
            DispatchQueue.global().async {
                self?.handleResponse(result)
            }
        }
    }
    
    private func handleResponse(_ result: Result<UserModel, DataLoadError>) {
        var newUsersData: [UsersDataLocal] = []
        switch result {
        case .success(let response):
            handleCaching(response, &newUsersData)
            newUsersData = handleSuccess(response)
        case .failure(let error):
            handleFailure(error, newUsersData)
        }
        
        
        DispatchQueue.main.async {
            self.usersModel = newUsersData
            self.state = .success(LoadingViewModel(id: UUID().uuidString, usersData: newUsersData))
        }
    }
    
    private func handleCaching(_ response: UserModel, _ newUsersData: inout [UsersDataLocal]) {
        response.results.forEach { newUser in
            let userModelLocal = UsersDataLocal(id: newUser.login.uuid, username: newUser.login.username, phoneNumber: newUser.phone, email: newUser.email, imageURL: newUser.picture.large, cached: false, gender: newUser.gender)
            insertUserData(usersData: userModelLocal)
        }
    }
    
    fileprivate func handleMappedUsers(_ response: UserModel, _ mappedUsers: [UsersListViewModel.UsersDataLocal]) -> [UsersListViewModel.UsersDataLocal] {
        let responseIDs = response.results.map { $0.login.uuid }
        if let existingUsers = self.fetchUsersWithoutIDs(ids: responseIDs), existingUsers.count != 0 {
            let cachedUsersData = existingUsers.map {
                UsersListViewModel.UsersDataLocal(id: $0.id, username: $0.username, phoneNumber: $0.phoneNumber, email: $0.email, imageURL: $0.imageURL, cached: true, gender: $0.gender ?? "")
            }
            return mappedUsers + cachedUsersData
            
        } else {
            return mappedUsers
        }
    }
    
    private func handleSuccess(_ response: UserModel) -> [UsersDataLocal] {
        DispatchQueue.main.async {
            self.showErrorAlert = false
        }
        let users = response.results
        if !users.isEmpty {
            let mappedUsers = users.map {
                UsersListViewModel.UsersDataLocal(id: UUID().uuidString, username: $0.login.username, phoneNumber: $0.cell, email: $0.email, imageURL: $0.picture.large, cached: false, gender: $0.gender)
            }
            return handleMappedUsers(response, mappedUsers)
        }
        return []
    }
    
    private func handleFailure(_ error: DataLoadError, _ newUsersData: [UsersDataLocal]) {
        print("Error: \(error)")
        DispatchQueue.main.async {
            self.showErrorAlert = true
            self.state = .failed(LoadingViewModel(id: UUID().uuidString, usersData: newUsersData), ErrorViewModel(message: error.localizedDescription))
        }
    }
}

extension UsersListViewModel {
    struct UsersDataLocal: Identifiable, Equatable {
        let id: String?
        let username: String?
        let phoneNumber: String?
        let email: String?
        let imageURL: String?
        let cached: Bool?
        let gender: String?
    }
    
    struct LoadingViewModel: Equatable {
        let id: String
        let usersData: [UsersDataLocal]
        
        static func == (lhs: UsersListViewModel.LoadingViewModel, rhs: UsersListViewModel.LoadingViewModel) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension UsersListViewModel {
    func insertUserData(usersData: UsersDataLocal) {
        userCoreDataManager.insertDataIntoCoreData(usersData)
    }
    
    func fetchExistingUsers() -> [UsersDataLocal] {
        return userCoreDataManager.fetchExistingUsers()?
            .map { UsersDataLocal(id: $0.id, username: $0.username, phoneNumber: $0.phoneNumber, email: $0.email, imageURL: $0.imageURL, cached: true, gender: $0.gender) } ?? []
    }
    
    func fetchUsersWithoutIDs(ids: [String]) -> [UserCoreData]? {
        return userCoreDataManager.fetchUsersWithoutIDs(ids)
    }
    
    func clearCache() {
        userCoreDataManager.clearCachedUsers()
        self.loadData()
    }
    
}

extension UsersListViewModel.LoadingViewModel {
    var numCachedUsers: Int {
        usersData.filter { $0.cached ?? false }.count
    }
    
    var numNewUsers: Int {
        usersData.filter { !($0.cached ?? false) }.count
    }
    
    var malePercentage: Double {
        let totalUsers = usersData.count
        let maleUsers = usersData.filter { $0.gender == "male" }.count
        return Double(maleUsers) / Double(totalUsers) * 100
    }
    
    var femalePercentage: Double {
        let totalUsers = usersData.count
        let femaleUsers = usersData.filter { $0.gender == "female" }.count
        return Double(femaleUsers) / Double(totalUsers) * 100
    }

}
