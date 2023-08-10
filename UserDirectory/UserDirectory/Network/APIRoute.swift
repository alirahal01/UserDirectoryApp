//
//  APIRoute.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import Foundation

enum APIRoute {

    // Different cases for different endpoints.
    // We can configure each with required parameters
    case getUsers(page: String?, results: String?)

    private var baseURLString: String { "https://randomuser.me/api/" }

    private var url: URL? {
        switch self {
        case .getUsers:
            return URL(string: baseURLString)
        }
    }

    private var parameters: [URLQueryItem] {

        switch self {
        case let .getUsers(page: page, results: results):
            if let page = page , let results = results {
                var queryItems: [URLQueryItem] = []
                queryItems.append(URLQueryItem(name: "page", value: page))
                queryItems.append(URLQueryItem(name: "results", value: results))
                return queryItems
            }
            else {
                preconditionFailure("Nil Page or Results. We should never have arrived in this state. Stopping the execution.")
            }
        }
    }

    func asRequest() -> URLRequest {
        guard let url = url else {
            preconditionFailure("Missing URL for route: \(self)")
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters

        guard let parametrizedURL = components?.url else {
            preconditionFailure("Missing URL with parameters for url: \(url)")
        }

        var request = URLRequest(url: parametrizedURL)

        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }
}
