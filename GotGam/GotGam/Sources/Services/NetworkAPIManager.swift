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
import CoreData

class NetworkAPIManager{
    static let shared = NetworkAPIManager()
    
    let storage = Storage()
    let provider = MoyaProvider<GotAPIService>()
    let disposeBag = DisposeBag()
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "Ko_kr")
        return df
    }()
    
    var nickname: String{
        return UserDefaults.standard.string(forDefines: .nickname)!
    }
    var email: String{
        return UserDefaults.standard.string(forDefines: .userID)!
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
    
    //MARK: - User Info
    func downloadImage(url: String) -> Observable<UIImage>{
        return Observable.create { observer in
            AF.download(url)
                .validate()
                .responseData { (data) in
                    switch data.result{
                    case .success(let data):
                        guard let image = UIImage(data: data) else {
                            observer.onError(NetworkAPIManagerError.download("이미지 다운로드 실패"))
                            return
                        }
                        observer.onNext(image)
                    case .failure(let error):
                        observer.onError(NetworkAPIManagerError.download(error.localizedDescription))
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
        }
        
    }
    
    
    
    //MARK: - Synchronization
    func synchronize() -> Completable{
        return self.syncTags()
            .andThen(self.syncTasks())
            .andThen(self.syncFrequents())
            .andThen(self.syncronizeAllTags())
            .andThen(self.syncronizeAllTasks())
            .andThen(self.syncronizeAllFrequents())
    }
    
    func syncronizeAllTags() -> Completable{
        return Completable.create { observer in
            self.downloadAllTags().bind { tagDataList in
                var tagList: [Tag] = []
                for tagData in tagDataList{
                    let newTag = Tag(id: tagData.id, name: tagData.name, hex: tagData.color)
                    tagList.append(newTag)
                }
                self.storage.syncAllTag(tagList: tagList).subscribe {  completable in
                    observer(completable)
                }.disposed(by: self.disposeBag)
            }
        }
    }
    
    func syncronizeAllTasks() -> Completable{
        return Completable.create { observer in
            self.downloadAllTasks().bind { taskDataList in
                var taskList: [Got] = []
                for v in taskDataList{
                    var newGot = Got(id: v.id, createdDate: self.dateFormatter.date(from: v.createdDate)!, title: v.title, latitude: v.coordinates[0], longitude: v.coordinates[1], radius: 150, place: v.address, arriveMsg: v.arriveMessage, deparetureMsg: v.departureMessage, insertedDate: nil, onArrive: v.isCheckedArrive, onDeparture: v.isCheckedDeparture, onDate: v.isCheckedDueDate, tag: nil, isDone: v.isFinished, readyArrive: v.isReadyArrive, readyDeparture: v.isReadyDeparture)
                    if let tagId = v.tag, let tag = self.storage.readTag(id: tagId){
                        newGot.tag = tag
                    }
                    if v.dueDate != "none"{
                        newGot.insertedDate = self.dateFormatter.date(from: v.dueDate)
                    }
                    taskList.append(newGot)
                }
                self.storage.syncAllTasks(tasks: taskList).subscribe {  completable in
                    observer(completable)
                }.disposed(by: self.disposeBag)
            }
        }
    }
    
    func syncronizeAllFrequents() -> Completable{
        return Completable.create { observer in
            self.downloadAllFrequents().bind { frequentDataList in
                var frequentsList: [Frequent] = []
                for frequentData in frequentDataList{
                    let newFrequent = Frequent(name: frequentData.name, address: frequentData.address, latitude: frequentData.coordinates[0], longitude: frequentData.coordinates[1], type: .home, id: frequentData.id)
                    frequentsList.append(newFrequent)
                }
                self.storage.syncAllFrequents(frequentsList: frequentsList).subscribe {  completable in
                    observer(completable)
                }.disposed(by: self.disposeBag)
            }
        }
    }
    
    func syncTags() -> Completable{
        return Completable.create { observer in
            Observable.zip(
                self.getAllUnsyncedTags(),self.uploadAllTags()).bind { (tagList, tagDataList) in
                    
                    guard tagDataList.count == tagList.count else { observer(.error(NetworkAPIManagerError.syncTag("tag 개수가 일치하지 않음")))
                        return
                    }
                    var syncData: [(NSManagedObjectID, Tag)] = []
                    for i in 0..<tagList.count{
                        guard let objectId = tagList[i].objectId else {
                            observer(.error(NetworkAPIManagerError.syncTag("objectId가 존재하지 않음")))
                            return
                        }
                        let newTagData = tagDataList[i]
                        let newTag = Tag(id: newTagData.id, name: newTagData.name, hex: newTagData.color)
                        syncData.append((objectId, newTag))
                    }
                    self.storage.syncTag(syncData).subscribe { completable in
                        observer(completable)
                    }.disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func uploadAllTags() -> Observable<[TagData]> {
        return Observable.create { observer -> Disposable in
            self.getMergedUnsyncedTags().bind { (info) in
                self.provider.rx.request(.synchronize(["frequents": [], "tasks": [], "tags": info]))
                    .asObservable()
                    .map { try JSONDecoder().decode(SyncResponse.self, from: $0.data) }
                    .debug()
                    .catchErrorJustReturn(nil)
                    .debug()
                    .map { $0?.tags ?? [] }
                    .debug()
                    .bind(to: observer )
                    .disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    private func downloadAllTags() -> Observable<[TagData]>{
        return Observable.create { observer -> Disposable in
            self.provider.rx.request(.getTags)
                .asObservable()
                .map { try JSONDecoder().decode(TagResponse.self, from: $0.data)}
            .debug()
                .catchErrorJustReturn(nil)
            .debug()
                .map { $0?.tag ?? [] }
                .bind(to: observer)
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func syncTasks() -> Completable{
        return Completable.create { observer in
            Observable.zip(self.getAllUnsyncedTasks(),self.uploadAllTasks())
                .filter { $0.0.count == $0.1.count }
                .filter { $0.0.filter { $0.objectId == nil }.isEmpty }
                .bind { (gotList, gotDataList) in
                    var syncData: [SyncData<Got>] = []
                    for (i,v) in gotDataList.enumerated(){
                        let task = gotDataList[i]
                        var newGot = Got(id: v.id, createdDate: self.dateFormatter.date(from: v.createdDate)!, title: v.title, latitude: v.coordinates[0], longitude: v.coordinates[1], radius: 150, place: v.address, arriveMsg: v.arriveMessage, deparetureMsg: v.departureMessage, insertedDate: nil, onArrive: v.isCheckedArrive, onDeparture: v.isCheckedDeparture, onDate: v.isCheckedDueDate, tag: nil, isDone: v.isFinished, readyArrive: v.isReadyArrive, readyDeparture: v.isReadyDeparture)
                        
                        if let tagId = task.tag, let tag = self.storage.readTag(id: tagId){
                            newGot.tag = tag
                        }
                        if v.dueDate != "none"{
                            newGot.insertedDate = self.dateFormatter.date(from: v.dueDate)
                        }
                        syncData.append((gotList[i].objectId!, newGot))
                    }
                    self.storage.syncTask(syncData).subscribe { completable in
                        observer(completable)
                    }.disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func uploadAllTasks() -> Observable<[GotResponseData]> {
        return Observable.create { observer -> Disposable in
            self.getMergedUnsyncedTasks().bind { info in
                self.provider.rx.request(.synchronize(["frequents": [], "tasks": info, "tags": []]))
                    .asObservable()
                    .debug()
                    .map { try JSONDecoder().decode(SyncResponse.self,from: $0.data)}
                    .debug()
                    .catchErrorJustReturn(nil)
                    .debug()
                    .map { $0?.tasks ?? [] }
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    private func downloadAllTasks() -> Observable<[GotResponseData]>{
        return Observable.create { observer -> Disposable in
            self.provider.rx.request(.getTasks)
                .asObservable()
                .map { try JSONDecoder().decode(GotResponse.self, from: $0.data)}
            .debug()
                .catchErrorJustReturn(nil)
            .debug()
                .map { $0?.got ?? [] }
                .bind(to: observer)
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func syncFrequents() -> Completable{
        return Completable.create { observer in
            Observable.zip(self.getAllUnsyncedFrequents(),self.uploadAllFrequents())
                .filter { $0.0.count == $0.1.count }
                .filter { $0.0.filter { $0.objectId == nil }.isEmpty }
                .bind { (frequentsList, frequentsDataList) in
                    var syncData: [SyncData<Frequent>] = []
                    for (i,v) in frequentsDataList.enumerated(){
                        let frequents = frequentsList[i]
                        var coordinates = v.coordinates
                        if coordinates.isEmpty{
                            coordinates = [0,0]
                        }
                        let newFrequents = Frequent(name: v.name, address: v.address, latitude: coordinates[0], longitude:
                            coordinates[1], type: .home, id: v.id)
                        
                        syncData.append((frequents.objectId!, newFrequents))
                    }
                    self.storage.syncFrequents(syncData).subscribe { completable in
                        observer(completable)
                    }.disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    func uploadAllFrequents() -> Observable<[FrequentResponseData]>{
        return Observable.create { observer in
            self.getMergedUnsyncedFrequents().bind { info in
                self.provider.rx.request(.synchronize(["frequents": info, "tasks": [], "tags": []]))
                    .asObservable()
                .debug()
                    .map { try JSONDecoder().decode(SyncResponse.self, from: $0.data)}
                .debug()
                    .catchErrorJustReturn(nil)
                    .map { $0?.frequents ?? [] }
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    private func downloadAllFrequents() -> Observable<[FrequentResponseData]>{
        return Observable.create { observer -> Disposable in
            self.provider.rx.request(.getFrequents)
                .asObservable()
                .map { try JSONDecoder().decode(FrequentResponse.self, from: $0.data)}
                .catchErrorJustReturn(nil)
                .map { $0?.frequents ?? [] }
                .bind(to: observer)
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    //MARK: - Helper
    private func getMergedUnsyncedTags() -> Observable<[[String: Any]]>{
        return getAllUnsyncedTags().map { $0.map {
            [
                "name": $0.name,
                "color": $0.hex,
                "creator": ["userId": self.email, "nickname": self.nickname]
            ]
            }}
    }
    
    private func getMergedUnsyncedTasks() -> Observable<[[String: Any]]> {
        return getAllUnsyncedTasks().map { $0.map {
            [
                "title": $0.title,
                "coordinates": [$0.latitude, $0.longitude],
                "address": $0.place,
                "tagName": $0.tag?.name ?? "",
                "iconURL": "",
                "isFinished": $0.isDone,
                "isCheckedArrive": $0.onArrive,
                "isCheckedDeparture": $0.onDeparture,
                "isCheckedDueDate": $0.onDate,
                "isReadyArrive": $0.readyArrive,
                "isReadyDeparture": $0.readyDeparture,
                "arriveMessage": $0.arriveMsg,
                "departureMessage": $0.deparetureMsg,
                "createdDate": self.dateFormatter.string(from: $0.createdDate),
                "dueDate": $0.insertedDate != nil ?  self.dateFormatter.string(from: $0.insertedDate!) : "none"
            ]
            
            }}
    }
    
    private func getMergedUnsyncedFrequents() -> Observable<[[String: Any]]> {
        return getAllUnsyncedFrequents().map { $0.map{
            [
                "name": $0.name,
                "address": $0.address,
                "coordinates": [$0.latitude, $0.longitude]
            ]
            }
        }
    }
    
    private func getAllUnsyncedTags() -> Observable<[Tag]>{
        return storage.fetchTagList()
            .map { $0.filter { $0.id == "" && $0.objectId != nil } }
    }
    
    private func getAllUnsyncedTasks() -> Observable<[Got]>{
        return storage.fetchTaskList()
            .map { $0.filter { $0.id == "" && $0.objectId != nil } }
    }
    
    private func getAllUnsyncedFrequents() -> Observable<[Frequent]>{
        return storage.fetchFrequents()
            .map { $0.filter { $0.id == "" && $0.objectId != nil } }
    }
    
    
    
    func leave() -> Observable<Response>{
        guard let email = UserDefaults.standard.string(forDefines: .userID) else { return .error(NetworkAPIManagerError.some("탈퇴 실패")) }
        return provider.rx.request(.deleteUser(email)).asObservable()
    }
}
