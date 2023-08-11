//
//  UserDirectoryApp.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import SwiftUI

@main
struct UserDirectoryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: UsersListViewModel(requestHandler: RequestHandler()))
        }
    }
}
