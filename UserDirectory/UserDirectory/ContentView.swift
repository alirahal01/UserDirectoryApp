//
//  ContentView.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import SwiftUI

struct ContentView: View {
    
    let requestHandler: RequestHandling
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, Users!")
        }
        .padding()
        .onAppear {
            requestHandler.request(route: .getUsers(page: "10", results: "30")) {  (result: Result<UserModel, DataLoadError>) -> Void in
                switch result {
                case .success(let response):
                    print(response)
                case .failure(let dataLoadError):
                    print(dataLoadError)
                }
            }
        }
    }
}
