//
//  UserModel.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import Foundation

// MARK: - Welcome
struct UserModel: Codable {
    let results: [UserModelResult]
}

// MARK: - Result
struct UserModelResult: Codable {
    let gender: String
    let name: Name
    let email: String
    let phone, cell: String
    let picture: Picture
    let login: Login
}

// MARK: - Name
struct Name: Codable {
    let title, first, last: String
}

// MARK: - Login
struct Login: Codable {
    let uuid, username: String
}

// MARK: - Picture
struct Picture: Codable {
    let large, medium, thumbnail: String
}
