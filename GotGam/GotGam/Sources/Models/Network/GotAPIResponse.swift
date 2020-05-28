//
//  TagResponse.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/27.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

class BaseResponse: Decodable{
    var baseResponseDescription: String
    
    private enum CodingKeys: String, CodingKey{
        case baseResponseDescription = "description"
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        baseResponseDescription = try container.decode(String.self, forKey: .baseResponseDescription)
    }
}
class GotResponse: BaseResponse{
    var got: GotResponseData

    private enum CodingKeys: String, CodingKey {
        case got = "task"
    }
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        got = try container.decode(GotResponseData.self, forKey: .got)
        try super.init(from: decoder)
        
    }
}
// MARK: - Tag
class TagResponse: BaseResponse {
    var tag: TagData

    private enum CodingKeys: String, CodingKey {
        case tag
    }
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tag = try container.decode(TagData.self, forKey: .tag)
        try super.init(from: decoder)
        
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

//MARK: - Login Response
class LoginResponse: BaseResponse {
    let user: UserResponseData

    enum CodingKeys: String, CodingKey {
        case user
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decode(UserResponseData.self, forKey: .user)
        try super.init(from: decoder)
    }
}

// MARK: - User
class UserResponse: BaseResponse{
    let user: UserResponseData

    enum CodingKeys: String, CodingKey {
        case user
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decode(UserResponseData.self, forKey: .user)
        try super.init(from: decoder)
    }
}

class SyncResponse: BaseResponse{
    var frequents: [FrequentResponseData]
    var tags: [TagData]
    var tasks: [GotResponseData]
    
    enum CodingKeys: String, CodingKey {
        case frequents
        case tags
        case tasks
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        frequents = try container.decode([FrequentResponseData].self, forKey: .frequents)
        tags = try container.decode([TagData].self, forKey: .tags)
        tasks = try container.decode([GotResponseData].self, forKey: .tasks)
        try super.init(from: decoder)
    }
}

struct FrequentResponseData: Codable{
    let taskIDS: [String]
    let id, name: String
    let creator: Creator
    let color: String

    enum CodingKeys: String, CodingKey {
        case taskIDS = "taskIds"
        case id = "_id"
        case name, creator, color
    }
}

struct GotResponseData: Codable{
    let title: String
    let coordinates: [Double]
    let tag: String?
    let memo, iconURL: String
    let isFinished: Bool
    let dueDate: String?
    let id: String
    let isCheckedLeave: Bool
    let address: String
    let isCheckedArrive: Bool
    let createdDate: String
    
    enum CodingKeys: String, CodingKey {
        case title, coordinates, tag, memo, iconURL, isFinished, dueDate
        case id = "_id"
        case isCheckedLeave, address, isCheckedArrive, createdDate
    }
}

struct UserResponseData: Codable {
    let profileImageURL: String
    let taskIDS: [String]
    let frequentIDS: [String]
    let tagIDS: [String]
    let id, userID, nickname: String
    let token: String?
    let joinedDate: String

    enum CodingKeys: String, CodingKey {
        case profileImageURL = "profileImageUrl"
        case taskIDS = "taskIds"
        case frequentIDS = "frequentIds"
        case tagIDS = "tagIds"
        case id = "_id"
        case userID = "userId"
        case nickname, token, joinedDate
    }
}

