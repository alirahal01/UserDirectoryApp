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
    let clearCache: () -> Void
    
    var body: some View {
        VStack {
            ProgressView(value: loadingViewModel.malePercentage, total: 100.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .background(Color.pink.opacity(1))
                        .cornerRadius(6)
                        .padding(.vertical, 5)
            Text("Female: \(String(format: "%.1f", loadingViewModel.femalePercentage))%, Male: \(String(format: "%.1f", loadingViewModel.malePercentage))%")
                }
        Text("Cached: \(loadingViewModel.numCachedUsers), New: \(loadingViewModel.numNewUsers)")
        Button("clear cache") {
            clearCache()
        }
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
