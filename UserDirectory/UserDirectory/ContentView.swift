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
            case .success(let loadingViewModel):
                UserListView(loadingViewModel: loadingViewModel, loadMoreDataAction: {
                    viewModel.loadData(loadMore: true)
                })
            case .failed(let errorViewModel):
                VStack {
                    Text("Offline")
                        .padding(5)
                        .foregroundColor(.red)
                    UserListView(loadingViewModel: errorViewModel.0, loadMoreDataAction: {
                        print("Paginate")
                    })
                }
                
            }
        }
        .padding()
    }
}
