//
//  UserListView.swift
//  UserDirectory
//
//  Created by ali rahal on 11/08/2023.
//

import Foundation
import SwiftUI

struct UserListView: View {
    let viewModel: UsersListViewModel
    let loadMoreDataAction: () -> Void // Closure property to trigger action when last element is reached
    let clearCache: () -> Void
    
    var body: some View {
        VStack {
            ProgressView(value: viewModel.malePercentage, total: 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .background(Color.pink.opacity(1))
                .cornerRadius(6)
                .padding(.vertical, 5)
            Text("Female: \(String(format: "%.1f", viewModel.femalePercentage))%, Male: \(String(format: "%.1f", viewModel.malePercentage))%")
        }
        HStack {
            Text("Cached: \(viewModel.numCachedUsers), New: \(viewModel.numNewUsers)")
            Button("clear cache") {
                clearCache()
            }
            .padding(3)
            .foregroundColor(.white)
            .background(.red)
            .cornerRadius(5)
        }
        
        List(viewModel.usersModel.indices, id: \.self) { index in
            VStack {
                UserRow(user: viewModel.usersModel[index])
                    .onAppear {
                        if index == viewModel.usersModel.count - 1 {
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
