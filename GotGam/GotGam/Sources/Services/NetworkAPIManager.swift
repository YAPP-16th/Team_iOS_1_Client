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
  
    func getUser(email: String, completion: @escaping (User?) -> Void){
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
        
    func createTask(got: Got){
        
        let title = got.title ?? ""
        let lat = got.latitude ?? 0.0
        let lng = got.longitude ?? 0.0
        let coordinates = [lat, lng]
        let address = got.place ?? ""
        let tags = ""
        let memo = got.deparetureMsg ?? ""
        let iconUrl = ""
        let isFinished = got.isDone
        let isCheckedArrive = got.onArrive
        let isCheckedLeave = got.onDeparture
        let date = ""
        
        let info = GotAPIInfo(
            title: title,
            coordinates: coordinates,
            address: address,
            tag: tags,
            memo: memo,
            iconUrl: iconUrl,
            isFinished: isFinished,
            isCheckedArrive: isCheckedArrive,
            isCheckedLeave: isCheckedLeave,
            dueDate: "2020-10-10 10:12:34")
        
        provider.request(.createTask(info)) { (result) in
            switch result{
            case .success(let response):
                print(String(data: response.data, encoding: .utf8))
                do{
                    let jsonDecoder = JSONDecoder()
                    let user = try jsonDecoder.decode(User.self, from: response.data)
                    
                }catch let error{
                    print(error.localizedDescription)
                    
                }
            case .failure(let error):
                print(error)
                
            }
        }
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
    func SyncAccount(){
        syncGot()
        syncTags()
    }
    
    func syncGot(){
        let storage = GotStorage()
        storage.fetchGotList().bind { (gots) in
            for got in gots{
                self.createTask(got: got)
            }
        }.disposed(by: disposeBag)
    }
    

    func syncTags(){
        guard let email = UserDefaults.standard.string(forDefines: .userID) else { return }
        guard let nickname = UserDefaults.standard.string(forDefines: .nickname) else { return }
        let storage = GotStorage()
        storage.fetchTagList().bind { tags in
            for tag in tags{
                let name = tag.name
                let color = tag.hex
                let tagInfo = TagAPIInfo(name: name, color: color, email: email, nickname: nickname)
                self.provider.request(.createTag(tagInfo)) { (result) in
                    switch result{
                    case .success(let response):
                        let jsonDecoder = JSONDecoder()
                        do{
                            let tagResponse = try jsonDecoder.decode(TagResponse.self, from: response.data)
                            print(tagResponse.tag.id)
                        }catch let error{
                            print(error.localizedDescription)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }.disposed(by: self.disposeBag)
    }
  
    
}
