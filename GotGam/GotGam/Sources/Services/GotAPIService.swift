//
//  GotAPIService.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/20.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import RxSwift

enum GotAPIService{
    
    //User
    case login(LoginType)
    case getUser(String)
    
    //Task
    case createTask([String: Any])
    case getTasks
    case getTask(String)
    case updateTask(String, [String: Any])
    case deleteTask(String)
    //TAg
    case createTag([String: Any])
    case getTags
    case getTag(String)
    case updateTag(String, [String:Any])
    case deleteTag(String)
    //Frequents
    case createFrequents
    case getFrequents
    case getFrequent(String)
    
    //Sync
    case synchronize([String: Any])
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
            case .kakao:
                return "users/kakao"
            case .facebook:
                return "users/facebook"
            }
        case .getUser(let email):
            return "users/\(email)"
            //Task
        case .createTask, .getTasks:
            return "tasks"
        case .getTask(let id):
            return "tasks/\(id)"
        case .updateTask(let id, _):
            return "tasks/\(id)"
        case .deleteTask(let id):
            return "tasks/\(id)"
            //Tag
        case .createTag, .getTags:
            return "tags"
        case .getTag(let id):
            return "tags/\(id)"
        case .updateTag(let id, _):
            return "tags/\(id)"
        case .deleteTag(let id):
            return "tags/\(id)"
            //Frequents
        case .createFrequents, .getFrequents:
            return "frequents"
        case .getFrequent(let id):
            return "frequents/\(id)"
        case .synchronize:
            return "synchronizes"
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
        case .updateTask:
            return .patch
        case .deleteTask:
            return .delete
            //Tag
        case .createTag:
            return .post
        case .getTags, .getTag:
            return .get
        case .updateTag:
            return .patch
        case .deleteTag:
            return .delete
            //Frequents
        case .createFrequents:
            return .post
        case .getFrequents, .getFrequent:
            return .get
        case .synchronize:
            return .post
        }
    }
    
    var task: Task{
        switch self {
            //User
        case .login(let type):
            switch type{
            case .kakao(let info):
                return .requestParameters(
                    parameters:
                    [
                        "id":"\(info.id)",
                        "email":info.email,
                        "access_token":info.token,
                        
                    ],
                    encoding: JSONEncoding.default)
            case .google(let info):
                return .requestParameters(
                    parameters:
                    [
                        "id":"\(info.id)",
                        "email":info.email,
                        "access_token":info.token,
                        
                    ],
                    encoding: JSONEncoding.default)
            case .facebook(let info):
                return .requestParameters(
                    parameters:
                    [
                        "id":"\(info.id)",
                        "email":info.email,
                        "access_token":info.token,
                        
                    ],
                    encoding: JSONEncoding.default)
            }
        case .getUser:
            return .requestPlain
            //Task
        case .createTask(let info):
            return .requestParameters(
            parameters:info,
            encoding: JSONEncoding.default)
        case .getTasks, .getTask:
            return .requestPlain
        case .updateTask(_, let info):
            return .requestParameters(
            parameters: info,
            encoding: JSONEncoding.default)
        case .deleteTask:
            return .requestPlain
            //Tag
        case .createTag(let info):
            return .requestParameters(
            parameters: info,
            encoding: JSONEncoding.default)
        case .getTags, .getTag:
            return .requestPlain
        case .updateTag(_, let info):
            return .requestParameters(
                parameters: info,
                encoding: JSONEncoding.default)
        case .deleteTag:
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
        case .synchronize(let info):
            return .requestParameters(parameters: info, encoding: JSONEncoding.default)
      }
    }
    var headers: [String : String]? {
        switch self{
        case .getUser, .createTask, .getTasks, .getTask, .createTag, .getTags, .getTag, .createFrequents, .getFrequents, .getFrequent, .synchronize, .updateTag, .updateTask, .deleteTask, .deleteTag:
             guard let token = UserDefaults.standard.string(forDefines: .userToken) else {
                return [:]
            }
            return ["Authorization": "Token \(token)"]
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
