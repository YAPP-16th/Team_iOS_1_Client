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
            }
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
        case .getTasks, .getTask:
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
        case .getTags, .getTag:
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

class NetworkAPIManager{
    static let shared = NetworkAPIManager()
    var provider: MoyaProvider<GotAPIService>!
    private init(){
        self.provider = MoyaProvider<GotAPIService>()
    }
  
    func getUser(token: String, completion: @escaping (User?) -> Void){
        provider.request(.getUser(token)) { (result) in
            switch result{
            case .success(let response):
                do{
                    let jsonDecoder = JSONDecoder()
                    let user = try jsonDecoder.decode(LoginResponse.self, from: response.data)
                    completion(user.user)
                }catch let error{
                    print(error.localizedDescription)
                    completion(nil)
                }
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getProfileImage(url urlString: String, completion: @escaping ((UIImage) -> Void)){
        AF.download(urlString).responseData { result in
            if let data = result.value, let image = UIImage(data: data){
                completion(image)
            }
        }
    }
        
    func createTask(got: Got){
        
    }
    
    func getTasks(completion: @escaping (User?) -> Void){
        provider.request(.getTasks) { (result) in
            switch result{
            case .success(let response):
                do{
                    let jsonDecoder = JSONDecoder()
                    let user = try jsonDecoder.decode(User.self, from: response.data)
                    completion(user)
                }catch let error{
                    print(error.localizedDescription)
                    completion(nil)
                }
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    func getTask(id: String){
        provider.request(.getTask(id)) { (result) in
            switch result{
            case .success(let response):
                print(String(data: response.data, encoding: .utf8))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func createTag(tag: Tag){
        
    }
    
    func getTags(){
        provider.request(.getTags) { (result) in
            switch result{
            case .success(let response):
                print(String(data: response.data, encoding: .utf8))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getTag(id: String){
        provider.request(.getTag(id)) { (result) in
            switch result{
            case .success(let response):
                print(String(data: response.data, encoding: .utf8))
            case .failure(let error):
                print(error)
            }
        }
    }
}
