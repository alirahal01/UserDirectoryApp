//
//  LoadingState.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import Foundation

struct ErrorViewModel: Equatable {
    let message: String
}

enum LoadingState<LoadingViewModel: Equatable>: Equatable {
    case idle
    case loading
    case failed(LoadingViewModel,ErrorViewModel)
    case success(LoadingViewModel)
}
