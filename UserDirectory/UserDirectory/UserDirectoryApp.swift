//
//  UserDirectoryApp.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import SwiftUI

@main
struct UserDirectoryApp: App {
    
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: UsersListViewModel(requestHandler: RequestHandler(), persistenceController: persistenceController))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)

        }.onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}


