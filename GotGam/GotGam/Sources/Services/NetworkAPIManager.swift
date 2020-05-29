//
//  NetworkAPIManager.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/27.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import RxSwift

class NetworkAPIManager{
    static let shared = NetworkAPIManager()
    var disposeBag = DisposeBag()
    var provider: MoyaProvider<GotAPIService>!
    private init(){
        self.provider = MoyaProvider<GotAPIService>()
    }
  
    func getUser(email: String, completion: @escaping (UserResponseData?) -> Void){
        provider.request(.getUser(email)) { (result) in
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
    
    func getTasks(completion: @escaping (UserResponse?) -> Void){
        provider.request(.getTasks) { (result) in
            switch result{
            case .success(let response):
                do{
                    let jsonDecoder = JSONDecoder()
                    let user = try jsonDecoder.decode(UserResponse.self, from: response.data)
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
    
    func createTag(tag: Tag, completion: @escaping (Tag?) -> Void){
        guard let email = UserDefaults.standard.string(forDefines: .userID) else { return }
        guard let nickname = UserDefaults.standard.string(forDefines: .nickname) else { return }
        
        let info: [String: Any] = [
            "name": tag.name,
            "color": tag.hex,
            "creator": ["userId": email, "nickname": nickname]
        ]
        provider.request(.createTag(info)) { (result) in
            switch result{
            case .success(let response):
                do{
                    print(String(data: response.data, encoding: .utf8))
                    let jsonDecoder = JSONDecoder()
                    let tagResponse = try jsonDecoder.decode(TagResponse.self, from: response.data)
                    var tag = tag
                    tag.id =  tagResponse.tag.id
                    completion(tag)
                }catch let error{
                    print(error.localizedDescription)
                    completion(nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    
    func getTags(){
        provider.request(.getTags) { (result) in
            switch result{
            case .success(let response):
                break
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getTag(id: String){
        provider.request(.getTag(id)) { (result) in
            switch result{
            case .success(let response):
                break
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func SyncAccount(){
        guard let email = UserDefaults.standard.string(forDefines: .userID) else { return }
        guard let nickname = UserDefaults.standard.string(forDefines: .nickname) else { return }
        let frequentsStorage = FrequentsStorage()
        let gotStorage = GotStorage()
        Observable.zip(
            frequentsStorage.fetchFrequents(),
            gotStorage.fetchGotList(),
            gotStorage.fetchTagList()
        ).subscribe(onNext: { fList, gList, tList in
            let fData: [[String: Any]] = fList.map {
                [
                    "name": $0.name,
                    "address": $0.address,
                    "coordinates": [$0.latitude, $0.longitude]
                ]
            }
            
            let tData: [[String: Any]] = tList.map {
                [
                    "name": $0.name,
                    "color": $0.hex,
                    "creator": ["userId": email, "nickname": nickname]
                ]
            }
            
            let gData: [[String: Any]] = gList.map {
                [
                    "title": $0.title ?? "",
                    "coordinates": [$0.latitude ?? 0.0, $0.longitude ?? 0.0],
                    "address": $0.place ?? "",
                    "tagName": "",
                    "memo": $0.arriveMsg ?? $0.deparetureMsg ?? "",
                    "iconURL": "",
                    "isFinished": $0.isDone,
                    "isCheckedArrive": $0.onArrive,
                    "isCheckedLeave": $0.onDeparture
                ]
            }
            let info = ["frequents": fData,
                   "tags": tData,
                   "tasks": gData
            ]
            self.provider.request(.synchronize(info)) { (result) in
                switch result{
                case .success(let syncResponse):
                    let decoder = JSONDecoder()
                    do{
                        let jsonData = try decoder.decode(SyncResponse.self, from: syncResponse.data)
                        self.syncLocalData(data: jsonData)
                    }catch let error{
                        print(error.localizedDescription)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            }).disposed(by: disposeBag)
    }
    
    func syncLocalData(data: SyncResponse){
        let storage = GotStorage()
        Observable.zip(storage.deleteUnsyncedTag(), storage.deleteUnsyncedGot()).subscribe(onNext: { tResult, gResult in
            if tResult && gResult{
                var tagList: [Tag] = []
                for tag in data.tags{
                    let newTag = Tag(id: tag.id, name: tag.name, hex: tag.color)
                    tagList.append(newTag)
                    _ = storage.create(tag: newTag).asObservable().map { _ in }
                }
                
                for task in data.tasks{
                  var newGot = Got(id: task.id, title: task.title, latitude: task.coordinates[0], longitude: task.coordinates[1], place: task.address, insertedDate: Date(), tag: [])
                    if let tag = tagList.first(where: { $0.id == task.tag }) {
                        newGot.tag?.append(tag)
                    }
                    _ = storage.createGot(gotToCreate: newGot).asObservable().map { _ in }
                }
            }
        }).disposed(by: self.disposeBag)
    }
    func createTask(got: Got, completion: @escaping (Got?) -> Void){
        
        let title = got.title ?? ""
        let lat = got.latitude ?? 0.0
        let lng = got.longitude ?? 0.0
        let coordinates = [lat, lng]
        let address = got.place ?? ""
        let tags = got.tag?.first?.id ?? ""
        let memo = got.deparetureMsg ?? ""
        let iconUrl = ""
        let isFinished = got.isDone
        let isCheckedArrive = got.onArrive
        let isCheckedLeave = got.onDeparture
        let date = ""
        
        var info: [String: Any] = [
            "title":title,
            "coordinates":coordinates,
            "address":address,
            "memo": memo,
            "isFinished": isFinished,
            "isCheckedArrive": isCheckedArrive,
            "isCheckedLeave": isCheckedLeave,
            
            ] as [String : Any]
        if tags != ""{
            info["tag"] = tags
        }
        if iconUrl != "" {
            info["iconURL"] = iconUrl
        }
        if date != ""{
            info["dueDate"] = date
        }
        
        provider.request(.createTask(info)) { (result) in
            switch result{
            case .success(let response):
                do{
                    print(String(data: response.data, encoding: .utf8))
                    let jsonDecoder = JSONDecoder()
                    let gotResponse = try jsonDecoder.decode(GotResponse.self, from: response.data)
                    var got = got
                    got.id =  gotResponse.got.id
                    completion(got)
                }catch let error{
                    print(error.localizedDescription)
                    completion(nil)
                }
            case .failure(let error):
                completion(nil)
            }
        }
    }

    
    func updateTag(tag: Tag, completion: @escaping () -> Void){
        let info:[String: Any] = [
            "name": tag.name,
            "color": tag.hex
        ]
        provider.request(.updateTag(tag.id, info)) { (response) in
            if case .success = response {
                completion()
            }
        }
    }
    
    func updateGot(got: Got, completion: @escaping () -> Void){
        let title = got.title ?? ""
        let lat = got.latitude ?? 0.0
        let lng = got.longitude ?? 0.0
        let coordinates = [lat, lng]
        let address = got.place ?? ""
        let tags = got.tag?.first?.id ?? ""
        let memo = got.deparetureMsg ?? ""
        let iconUrl = ""
        let isFinished = got.isDone
        let isCheckedArrive = got.onArrive
        let isCheckedLeave = got.onDeparture
        let date = ""
        
        var info: [String: Any] = [
            "title":title,
            "coordinates":coordinates,
            "address":address,
            "memo": memo,
            "isFinished": isFinished,
            "isCheckedArrive": isCheckedArrive,
            "isCheckedLeave": isCheckedLeave,
            
            ] as [String : Any]
        if tags != ""{
            info["tag"] = tags
        }
        if iconUrl != "" {
            info["iconURL"] = iconUrl
        }
        if date != ""{
            info["dueDate"] = date
        }
        
        provider.request(.updateTask(got.id!, info)) { (result) in
            if case .success = result{
                completion()
            }
        }
    }
  
    func deleteTask(got: Got, completion: @escaping () -> Void){
        let id = got.id!
        provider.request(.deleteTask(id)) { (response) in
            if case .success = response {
                completion()
            }else{
                print("error")
            }
        }
    }
    
    func deleteTag(tag: Tag, completion: @escaping () -> Void){
        let id = tag.id
        provider.request(.deleteTag(id)) { (response) in
            if case .success = response{
                completion()
            }else{
                print("error")
            }
        }
    }
}
