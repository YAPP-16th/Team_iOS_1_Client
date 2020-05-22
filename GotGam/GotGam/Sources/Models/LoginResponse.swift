//
//  LoginResponse.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/22.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let loginResponseDescription: String
    let user: User

    enum CodingKeys: String, CodingKey {
        case loginResponseDescription = "description"
        case user
    }
}

// MARK: - User
struct User: Codable {
    let profileImageURL: String
    let taskIDS: [String]
    let frequentIDS: [String]
    let tagIDS: [String]
    let id, userID, nickname, token: String
    let joinedDate: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case profileImageURL = "profileImageUrl"
        case taskIDS = "taskIds"
        case frequentIDS = "frequentIds"
        case tagIDS = "tagIds"
        case id = "_id"
        case userID = "userId"
        case nickname, token, joinedDate
        case v = "__v"
    }
}
