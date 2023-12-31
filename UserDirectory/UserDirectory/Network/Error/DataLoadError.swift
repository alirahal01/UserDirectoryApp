//
//  DataLoadError.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import Foundation

enum DataLoadError: Error, Equatable {
    case badURL
    case genericError(String)
    case noData
    case malformedContent
    case invalidResponseCode(Int)
    case decodingError(String)
    case offline

    func errorMessageString() -> String {
        switch self {
        case .badURL:
            return "Invalid URL encountered. Please enter the valid URL and try again"
        case let .genericError(message):
            return message
        case .noData:
            return "No data received from the server. Please try again later"
        case .malformedContent:
            return "Received malformed content. Error may have been logged on the server to investigate further"
        case let .invalidResponseCode(code):
            return "Server returned invalid response code. Expected between the range 200-299. Server returned \(code)"
        case .offline:
            return "Your device is currently offline. Please check your internet connection and try again."
        case let .decodingError(message):
            return message
        }
    }
}
