//
//  UsersListViewModel.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import Foundation
import Combine
import SwiftUI

class UsersListViewModel: ObservableObject {
    
    private var cancellable: AnyCancellable?
    private let requestHandler: RequestHandler?
    @Published var usersModel: [UsersData] = []
    @Published private(set) var state: LoadingState<LoadingViewModel> = .idle
    @Published var showErrorAlert = false
    private var offset: Int = 0
    
    init(requestHandler: RequestHandler? = nil) {
        self.requestHandler = requestHandler
    }
    
    func incrementOffset() {
        self.offset += 100
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
        
        requestHandler.request(route: .getUsers(page: "1", results: "10")){ [weak self]
            (result: Result<UserModel, DataLoadError>) -> Void in
            switch result {
            case .success(let response):
                print(response)
                let users = response.results
                if users.count != 0 {
                    let usersData = users.map { UsersData(id: UUID().uuidString, username: $0.name.title, phoneNumber: $0.cell, email: $0.email, imageURL: $0.picture.large)
                    }
                    print(usersData)
                    DispatchQueue.main.async {
                        self?.usersModel = usersData
                        self?.state = .success(LoadingViewModel(id: UUID().uuidString, usersData: usersData))
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
                //                self.retryEnabled = true
                DispatchQueue.main.async {
                    self?.state = .failed(ErrorViewModel(message: error.localizedDescription))
                }
                
            }
        }
    }
    
}

extension UsersListViewModel {
    struct UsersData: Identifiable, Equatable {
        let id: String?
        let username: String?
        let phoneNumber: String?
        let email: String?
        let imageURL: String?
    }
    
    struct LoadingViewModel: Equatable {
        let id: String
        let usersData: [UsersData]
        
        static func == (lhs: UsersListViewModel.LoadingViewModel, rhs: UsersListViewModel.LoadingViewModel) -> Bool {
            lhs.id == rhs.id
        }
    }
}
