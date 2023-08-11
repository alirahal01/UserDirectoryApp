//
//  ContentView.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: UsersListViewModel
    
    var body: some View {
        VStack {
            let state = viewModel.state
            switch state {
            case . idle:
                Color.clear.onAppear(perform: { viewModel.loadData() })
            case .loading:
                ProgressView()
                    .imageScale(.large)
            case .success(let loadingViewModel):
                VStack(alignment: .leading) {
                    List {
                        ForEach(loadingViewModel.usersData.indices, id: \.self) { index in

                            let user = loadingViewModel.usersData[index]

                            VStack(alignment: .leading, spacing: 12) {
                                Text(user.username ?? "")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(user.email ?? "")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
            case .failed(let errorViewModel):
                Color.clear.alert(isPresented: $viewModel.showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(errorViewModel.message), dismissButton: .default(Text("OK")))
                }
            }
        }
        .padding()
    }
}
