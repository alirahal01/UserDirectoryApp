//
//  UserListView.swift
//  UserDirectory
//
//  Created by ali rahal on 11/08/2023.
//

import Foundation
import SwiftUI

struct UserListView: View {
    let loadingViewModel: UsersListViewModel.LoadingViewModel
    let loadMoreDataAction: () -> Void // Closure property to trigger action when last element is reached
    var body: some View {
        List(loadingViewModel.usersData.indices, id: \.self) { index in
            UserRow(user: loadingViewModel.usersData[index])
                .onAppear {
                    if index == loadingViewModel.usersData.count - 1 {
                        loadMoreDataAction()
                    }
                }
        }
    }
}
