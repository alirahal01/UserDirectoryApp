//
//  RequestHandling.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import Foundation

protocol RequestHandling {
    func request<T: Decodable>(route: APIRoute, completion: @escaping (Result<T, DataLoadError>) -> Void)
}
