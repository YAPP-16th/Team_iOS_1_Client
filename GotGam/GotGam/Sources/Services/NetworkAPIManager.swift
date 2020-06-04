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
    let proviter = MoyaProvider<GotAPIService>()
    let disposeBag = DisposeBag()
    
    var nickname: String{
        return UserDefaults.standard.string(forDefines: .nickname)!
    }
    var email: String{
        return UserDefaults.standard.string(forDefines: .userID)!
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
        return Completable.create { observer in
            self.syncTags().subscribe { c in
                switch c{
                case .completed:
                    self.syncTasks().subscribe { completable in
                        observer(completable)
                    }.disposed(by: self.disposeBag)
                case .error(let error):
                    observer(.error(error))
                }
            }.disposed(by: self.disposeBag)
            return Disposables.create()
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
                self.proviter.rx.request(.synchronize(["frequents": [], "tasks": [], "tags": info]))
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
    
    func syncTasks() -> Completable{
        return Completable.create { observer in
            Observable.zip(self.getAllUnsyncedTasks(),self.uploadAllTasks())
                .filter { $0.0.count == $0.1.count }
                .filter { $0.0.filter { $0.objectId == nil }.isEmpty }
                .bind { (gotList, gotDataList) in
                    var syncData: [SyncData<Got>] = []
                    for (i,v) in gotDataList.enumerated(){
                        let task = gotDataList[i]
                        var newGot = Got(id: v.id, title: v.title, latitude: v.coordinates[0], longitude: v.coordinates[1], place: v.address, insertDate: Date(), tag: nil)
                        if let tagId = task.tag, let tag = self.storage.read(id: tagId){
                            newGot.tag = tag
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
                self.proviter.rx.request(.synchronize(["frequents": [], "tags": [], "tasks": info]))
                    .asObservable()
                    .map { try JSONDecoder().decode(SyncResponse.self,from: $0.data) }
                    .catchErrorJustReturn(nil)
                    .map { $0?.tasks ?? [] }
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
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
                "arriveMessage": $0.arriveMsg,
                "leaveMessage": $0.deparetureMsg,
                "iconURL": "",
                "isFinished": $0.isDone,
                "isCheckedArrive": $0.onArrive,
                "isCheckedLeave": $0.onDeparture,
                "isReadyArrive": $0.readyArrive,
                "isReadyDeparture": $0.readyDeparture
            ]
            }}
    }
    
    private func getAllUnsyncedTags() -> Observable<[Tag]>{
        return storage.fetchTagList()
            .map { $0.filter { $0.id == "" && $0.objectId != nil } }
    }
    
    private func getAllUnsyncedTasks() -> Observable<[Got]>{
        return storage.fetchTaskList()
            .map { $0.filter { $0.id == "" && $0.objectId != nil } }
    }
    
    
}
