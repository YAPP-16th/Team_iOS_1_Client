//
//  TagResponse.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/27.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

// MARK: - Tag
struct TagResponse: Codable {
    let tagResponseDescription: String
    let tag: TagData

    enum CodingKeys: String, CodingKey {
        case tagResponseDescription = "description"
        case tag
    }
}
struct TagData: Codable {
    let taskIDS: [String]
    let id, name, color: String
    let creator: Creator

    enum CodingKeys: String, CodingKey {
        case taskIDS = "taskIds"
        case id = "_id"
        case name, color, creator
    }
}

struct Creator: Codable {
    let userID, nickname: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case nickname
    }
}
