//
//  UserCoreDataManager.swift
//  UserDirectory
//
//  Created by ali rahal on 12/08/2023.
//

import Foundation

import Foundation
import CoreData

class UserCoreDataManager {
    
    let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
    
    func fetchExistingUsers() -> [UserCoreData]? {
        return try? persistenceController.container.viewContext.fetch(UserCoreData.fetchRequest()) as? [UserCoreData]
    }
    
    func insertDataIntoCoreData(_ usersData: UsersListViewModel.UsersDataLocal) {
        let context = persistenceController.container.viewContext
        let newUser = UserCoreData(context: context)
        newUser.username = usersData.username
        newUser.email = usersData.email
        newUser.phoneNumber = usersData.phoneNumber
        newUser.imageURL = usersData.imageURL
        newUser.id = usersData.id
        
        do {
            try context.save()
        } catch {
            print("Error saving user to Core Data: \(error)")
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
