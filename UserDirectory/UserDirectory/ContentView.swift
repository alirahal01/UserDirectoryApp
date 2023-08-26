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
            case .idle:
                Color.clear.onAppear(perform: { viewModel.loadData() })
            case .loading:
                ProgressView()
                    .imageScale(.large)
            case .success:
                UserListView(viewModel: viewModel, loadMoreDataAction: {
                    viewModel.loadData(loadMore: true)
                }, clearCache: {
                    viewModel.clearCache()
                })
            case .failed(let dataLoadError):
                if case .offline = dataLoadError {
                    VStack {
                        Text(dataLoadError.errorMessageString())
                            .padding(5)
                            .foregroundColor(.red)
                        UserListView(viewModel: viewModel, loadMoreDataAction: {
                            print("Offline")
                        }, clearCache: {
                            print("Offline")
                        })
                    }
                } else {
                    Color.clear.alert(isPresented: $viewModel.showErrorAlert) {
                        Alert(title: Text("Error"), message: Text(dataLoadError.errorMessageString()), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
        .padding()
    }
}
