//
//  LoadingState.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import Foundation

enum AppState<T: Equatable>: Equatable {
    case idle
    case loading
    case failed(DataLoadError)
    case success
}
