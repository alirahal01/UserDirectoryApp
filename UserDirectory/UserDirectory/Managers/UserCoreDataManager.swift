//
//  UserCoreDataManager.swift
//  UserDirectory
//
//  Created by ali rahal on 12/08/2023.
//

import Foundation

import Foundation
import CoreData
import CryptoKit


class UserCoreDataManager {
    
    let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        let key = SymmetricKey(size: .bits256)
        let savedKey = key.withUnsafeBytes {Data($0)}
        UserDefaults.standard.set(savedKey, forKey: "encryptionKey")
    }
    
    func fetchExistingUsers() -> [UserCoreData]? {
        return try? persistenceController.container.viewContext.fetch(UserCoreData.fetchRequest()) as? [UserCoreData]
    }
    
    func insertDataIntoCoreData(_ usersData: UsersListViewModel.UsersDataLocal) {
        let context = persistenceController.container.viewContext
        let newUser = UserCoreData(context: context)
        if let retrievedKeyData = UserDefaults.standard.data(forKey: "encryptionKey") {
            let retrievedKey = SymmetricKey(data: retrievedKeyData)
            guard let emailToEncrypt = usersData.email?.data(using: .utf8) else { return }
            let encryptedEmail = self.encryptData(data: emailToEncrypt, key: retrievedKey)
            guard let usernameToEncrypt = usersData.username?.data(using: .utf8) else { return }
            let encryptedUsername = self.encryptData(data: usernameToEncrypt, key: retrievedKey)
            
            newUser.email = encryptedEmail
            newUser.username = encryptedUsername
            newUser.phoneNumber = usersData.phoneNumber
            newUser.imageURL = usersData.imageURL
            newUser.id = usersData.id
            newUser.gender = usersData.gender
            do {
                try context.save()
            } catch {
                print("Error saving user to Core Data: \(error)")
            }
        }
        
    }
    
    func fetchUsersWithoutIDs(_ ids: [String]) -> [UserCoreData]? {
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        
        return try? persistenceController.container.viewContext.fetch(fetchRequest)
    }
    
    func clearCachedUsers() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserCoreData.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistenceController.container.viewContext.execute(batchDeleteRequest)
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
    
}

extension UserCoreDataManager {
    func encryptData(data: Data, key: SymmetricKey) -> Data? {
        do {
            let nonce = AES.GCM.Nonce()
            let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
            return sealedBox.combined
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    func decryptData(data: Data, key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return decryptedData
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
    
}
