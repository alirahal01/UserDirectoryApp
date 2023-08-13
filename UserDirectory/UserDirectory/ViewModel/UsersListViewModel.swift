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
import CryptoKit

class UsersListViewModel: ObservableObject {
    
    //MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
    private let requestHandler: RequestHandler?
    private var offset: Int = 0
    private let keyUserDefaultsKey = "encryptionKey"
    let userCoreDataManager: UserCoreDataManager
    @Published var usersModel: [UsersDataLocal] = []
    @Published var showErrorAlert = false
    var networkMonitor = NetworkMonitor()
    @Published var isConnected = false
    /// The `state` property plays an important role in the entire application's workflow.
    /// contains information related to the loading process, such as progress, success, error, or idle states.
    @Published private(set) var state: AppState<LoadingViewModel> = .idle
    
    
    //MARK: Initialization
    init(requestHandler: RequestHandler? = nil,persistenceController: PersistenceController) {
        self.requestHandler = requestHandler
        userCoreDataManager = UserCoreDataManager(persistenceController: persistenceController)
        self.generateKey()
        self.setupNetworkMonitor()
        
    }
    
    //MARK: - Methods
    
    //MARK: LoadData
    /// The `loadMore` function is responsible for:
    /// 1- Reacting to the current state and setting it to "loading".
    /// 2- Handling pagination logic.
    /// 3- Requesting user data based on the updated offset.
    /// - Parameter loadMore: load more will be set to to true when pagination need to be triggered  this occurs in user list
    func loadData(loadMore: Bool? = false) {
        guard state != .loading else {
            return
        }
        isConnected ? handleOnlineMode(loadMore: loadMore) : handleOfflineMode()
    }
    
    //MARK: Pagination
    private func handlePagination(loadMore: Bool? = false) {
        if(loadMore == true) { self.offset += 1 }
    }
    
    //MARK: Network Monitoring
    private func setupNetworkMonitor() {
        networkMonitor.start()
        networkMonitor.$isConnected // Use the publisher from NetworkMonitor
            .receive(on: DispatchQueue.main) // Ensure updates are on the main thread
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
                self?.loadData()
            }
            .store(in: &cancellables) // Store the cancellable
        
    }
    
    private func handleOfflineMode() {
        let loadingViewModel = (LoadingViewModel(id: UUID().uuidString, usersData: self.fetchExistingUsers()))
        state = .failed(loadingViewModel, DataLoadError.offline)
    }
    
    private func handleOnlineMode(loadMore: Bool? = false) {
        state = .loading
        handlePagination(loadMore: loadMore)
        requestUsersData()
    }
    private func generateKey() {
        if UserDefaults.standard.data(forKey: keyUserDefaultsKey) == nil {
            // Generate a new key and save it to UserDefaults
            let key = SymmetricKey(size: .bits256)
            let savedKey = key.withUnsafeBytes { Data($0) }
            UserDefaults.standard.set(savedKey, forKey: keyUserDefaultsKey)
        }
    }
    // MARK: Requesting User Data
    private func requestUsersData() {
        guard let requestHandler = requestHandler else { return }
        let page = String(offset)
        let results = UserDirectoryConstants.results
        let route: APIRoute = .getUsers(page: page, results: results)
        requestHandler.request(route: route) { [weak self] result in
            DispatchQueue.global().async {
                self?.handleResponse(result)
            }
        }
    }
    
    /// Handles the response from the API in case of success.
    ///
    /// - Parameter result: The result of the API call containing either a UserModel or a DataLoadError.
    private func handleResponse(_ result: Result<UserModel, DataLoadError>) {
        var newUsersData: [UsersDataLocal] = []
        
        switch result {
        case .success(let response):
            // Handle caching and update newUsersData
            handleCaching(response, &newUsersData)
            
            // Handle success response and update newUsersData
            newUsersData = handleSuccess(response)
            // Update loading state on the main queue
            DispatchQueue.main.async {
                self.state = .success(LoadingViewModel(id: UUID().uuidString, usersData: newUsersData))
            }
        case .failure(let error):
            // Handle failure response and update newUsersData
            handleFailure(error, newUsersData)
        }
        
        
    }
    
    private func handleCaching(_ response: UserModel, _ newUsersData: inout [UsersDataLocal]) {
        response.results.forEach { newUser in
            let userModelLocal = UsersDataLocal(id: newUser.login.uuid, username: newUser.login.username, phoneNumber: newUser.phone, email: newUser.email, imageURL: newUser.picture.large, cached: false, gender: newUser.gender)
            insertUserData(usersData: userModelLocal)
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
            return mergeMappedUsersWithDecryptedData(response, mappedUsers)
        }
        return []
    }
    
    /// Merges mapped user data with decrypted data from existing users, based on their UUIDs.
    ///
    /// If existing users are found with common UUIDs with the any of the mapped users
    /// usrename and email are decrypted and merged with the `mappedUsers` list.
    /// Otherwise, the `mappedUsers` list is returned as is.
    ///
    /// - Parameters:
    ///   - response: The UserModel containing user data from the API response.
    ///   - mappedUsers: An array of UsersDataLocal containing previously mapped user data.
    /// - Returns: An updated array of UsersDataLocal with decrypted data from existing users if applicable.
    private func mergeMappedUsersWithDecryptedData(_ response: UserModel, _ mappedUsers: [UsersListViewModel.UsersDataLocal]) -> [UsersListViewModel.UsersDataLocal] {
        // Extract UUIDs from the API response
        let responseIDs = response.results.map { $0.login.uuid }
        
        // Check for existing users with the extracted UUIDs
        if let existingUsers = self.fetchUsersWithoutIDs(ids: responseIDs), existingUsers.count != 0 {
            // Merge mappedUsers with decrypted data from existing users
            return mappedUsers + self.getDecryptedUsers(existingUsers: existingUsers)
        } else {
            // No existing users found, return mappedUsers as is
            return mappedUsers
        }
    }
    
    private func handleFailure(_ error: DataLoadError, _ newUsersData: [UsersDataLocal]) {
        print("Error: \(error)")
        DispatchQueue.main.async {
            self.showErrorAlert = true
            
            self.state = .failed(LoadingViewModel(id: UUID().uuidString, usersData: self.fetchExistingUsers()), error)
        }
    }
}

//MARK: - Extension UsersListViewModel - UsersDataLocal & LoadingViewModel
//help structure and manage user data and loading states within the view model.
extension UsersListViewModel {
    // A structure representing user data with their properties.
    struct UsersDataLocal: Identifiable, Equatable {
        let id: String?
        let username: String?
        let phoneNumber: String?
        let email: String?
        let imageURL: String?
        let cached: Bool?
        let gender: String?
    }
    
    // A structure representing the loading state of the view, including a unique ID
    // and an array of UsersDataLocal for managing and displaying user data.
    struct LoadingViewModel: Equatable {
        let id: String
        let usersData: [UsersDataLocal]
        
        // Equatable conformance for comparing LoadingViewModel instances.
        static func == (lhs: UsersListViewModel.LoadingViewModel, rhs: UsersListViewModel.LoadingViewModel) -> Bool {
            lhs.id == rhs.id
        }
    }
}


//MARK: - Extension UsersListViewModel - CoreData
// This extension enhances UsersListViewModel with methods for interacting with Core Data,
extension UsersListViewModel {
    // Insert user data into Core Data
    func insertUserData(usersData: UsersDataLocal) {
        userCoreDataManager.insertDataIntoCoreData(usersData)
    }
    
    func fetchExistingUsers() -> [UsersDataLocal] {
        return getDecryptedUsers(existingUsers: userCoreDataManager.fetchExistingUsers() ?? [])
    }
    
    // Fetch users from Core Data without specified IDs
    func fetchUsersWithoutIDs(ids: [String]) -> [UserCoreData]? {
        return userCoreDataManager.fetchUsersWithoutIDs(ids)
    }
    
    // Clear the cached users from Core Data
    // and reload fresh data from an external source
    func clearCache() {
        userCoreDataManager.clearCachedUsers()
        self.loadData() // Triggers loading fresh data
    }
    
    // Decrypts and transforms existing user data to UsersDataLocal format.
    private func getDecryptedUsers(existingUsers: [UserCoreData]) -> [UsersDataLocal] {
        // Check if an encryption key exists in UserDefaults
        guard let retrievedKeyData = UserDefaults.standard.data(forKey: "encryptionKey") else {
            return [] // Return an empty array if encryption key is missing
        }
        
        // Create a SymmetricKey using the retrieved encryption key data
        let retrievedKey = SymmetricKey(data: retrievedKeyData)
        
        // Initialize an array to store decrypted user data
        var decryptedUsers: [UsersDataLocal] = []
        
        // Iterate through existingUsers and decrypt user data
        for user in existingUsers {
            if let emailData = user.email, let usernameData = user.username {
                // Decrypt email and username data using the retrieved key
                let decryptedEmailData = EncryptionManager.shared.decryptData(data: emailData, key: retrievedKey)
                let decryptedUsernameData = EncryptionManager.shared.decryptData(data: usernameData, key: retrievedKey)
                
                // Check if decryption was successful
                if let email = decryptedEmailData, let username = decryptedUsernameData,
                   let emailStr = String(data: email, encoding: .utf8),
                   let usernameStr = String(data: username, encoding: .utf8) {
                    // Create a UsersDataLocal instance with decrypted data
                    let decryptedUser = UsersDataLocal(
                        id: user.id,
                        username: usernameStr,
                        phoneNumber: user.phoneNumber,
                        email: emailStr,
                        imageURL: user.imageURL,
                        cached: true,
                        gender: user.gender ?? ""
                    )
                    decryptedUsers.append(decryptedUser) // Add decrypted user to the array
                } else {
                    print("Failed to decode decrypted email data to string")
                }
            }
        }
        
        return decryptedUsers // Return the array of decrypted user data
    }
}

//MARK: - Extension UsersListViewModel - Calculated Properties
// Extension for enhancing UsersListViewModel.LoadingViewModel with calculated properties
extension UsersListViewModel.LoadingViewModel {
    // Calculate the number of users that are cached
    var numCachedUsers: Int {
        usersData.filter { $0.cached ?? false }.count
    }
    
    // Calculate the number of new (non-cached) users
    var numNewUsers: Int {
        usersData.filter { !($0.cached ?? false) }.count
    }
    
    // Calculate the percentage of male users in the loaded data
    var malePercentage: Double {
        let totalUsers = usersData.count
        let maleUsers = usersData.filter { $0.gender == "male" }.count
        return Double(maleUsers) / Double(totalUsers) * 100
    }
    
    // Calculate the percentage of female users in the loaded data
    var femalePercentage: Double {
        let totalUsers = usersData.count
        let femaleUsers = usersData.filter { $0.gender == "female" }.count
        return Double(femaleUsers) / Double(totalUsers) * 100
    }
}

