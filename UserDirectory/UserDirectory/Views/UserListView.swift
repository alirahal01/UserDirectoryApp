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
        HStack {
            Text("Cached: \(loadingViewModel.numCachedUsers), New: \(loadingViewModel.numNewUsers)")
            Button("clear cache") {
                clearCache()
            }
            .padding(3)
            .foregroundColor(.white)
            .background(.red)
            .cornerRadius(5)
        }
        
        List(loadingViewModel.usersData.indices, id: \.self) { index in
            VStack {
                UserRow(user: loadingViewModel.usersData[index])
                    .onAppear {
                        if index == loadingViewModel.usersData.count - 1 {
                            loadMoreDataAction()
                        }
                    }
            }
            .frame(maxWidth: .infinity) //make sure cell expans to the full width of list
            .overlay(
                RoundedRectangle(cornerRadius: 20) //adds a rounded rectangle overlay
                    .stroke(Color.gray, lineWidth: 1)
            )
            .listRowSeparator(.hidden) // Hide the row separator
            .padding(.vertical, 2)
        }
        .listStyle(PlainListStyle()) // Remove the gray background
        
    }
}
