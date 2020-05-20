//
//  GotAPIService.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/20.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import Moya

enum GotAPIService{
    enum LoginType{
        case google
        case naver
        case kakao
    }
    
    //User
    case login(LoginType)
    case getUser(String)
    
    //Task
    case createTask
    case getTasks
    case getTask(String)
    
    //TAg
    case createTag
    case getTags
    case getTag(String)
    
    //Frequents
    case createFrequents
    case getFrequents
    case getFrequent(String)
}

extension GotAPIService: TargetType{
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL { return URL(string: "http://15.164.4.225/api/")! }
    var path: String{
        switch self{
            //User
        case .login(let type):
            switch type{
            case .google:
                return "users/google"
            case .naver:
                return "users/naver"
            case .kakao:
                return "users/kakao"
            }
        case .getUser(let email):
            return "users/\(email)"
            //Task
        case .createTask, .getTasks:
            return "tasks"
        case .getTask(let id):
            return "tasks/\(id)"
            //Tag
        case .createTag, .getTags:
            return "tags"
        case .getTag(let id):
            return "tags\(id)"
            //Frequents
        case .createFrequents, .getFrequents:
            return "frequents"
        case .getFrequent(let id):
            return "frequents/\(id)"
        }
    }
    
    var method: Moya.Method{
        switch self {
            //User
        case .login:
            return .post
        case .getUser:
            return .get
            //Task
        case .createTask:
            return .post
        case .getTasks, .getTask:
            return .get
            //Tag
        case .createTag:
            return .post
        case .getTags, .getTag:
            return .get
            //Frequents
        case .createFrequents:
            return .post
        case .getFrequents, .getFrequent:
            return .get
        }
    }
    
    var task: Task{
        switch self {
            //User
        case .login:
            return .requestParameters(
                parameters:
                [
                    "id":"",
                    "email":"",
                    "access_token":"",
                    
                ],
                encoding: JSONEncoding.default)
        case .getUser:
            return .requestPlain
            //Task
        case .createTask:
            return .requestParameters(
            parameters:
            [
                "title":"",
                "coordinates":[0.0, 0.0],
                "address":"",
                "tag": "tagId or nil",
                "memo": "memoString or nil",
                "iconURL": "iconUrlString or nil",
                "isFinished": false,
                "isCheckedArrive": false,
                "isCheckedLeave": false,
                "dueDate": "dateStirng or nil"
            ],
            encoding: JSONEncoding.default)
        case .getTasks:
            return .requestPlain
            //Tag
        case .createTag:
            return .requestParameters(
            parameters:
            [
                "name":"",
                "color":"색상 코드",
                "creator":
                [
                    "userId":"이메일",
                    "nickname":"닉네임"
                ]
            ],
            encoding: JSONEncoding.default)
        case .getTags:
            return .requestPlain
            //Frequents
        case .createFrequents:
            return .requestParameters(
            parameters:
            [
                "name":"이름",
                "address":"주소",
                "coordinates":[0.0,0.0]
            ],
            encoding: JSONEncoding.default)
        case .getFrequents, .getFrequent:
            return .requestPlain
        }
        
        
    }
    var headers: [String : String]? {
        switch self{
        case .getUser, .createTask, .getTasks, .getTask, .createTag, .getTags, .getTag, .createFrequents, .getFrequents, .getFrequent:
            return ["Authorization": "Token tokenString"]
        default:
            return ["Content-type": "application/json"]
        }
        
    }
}
fileprivate extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
