//
//  NetworkAPIManagerType.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/31.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CoreData

enum NetworkAPIManagerError: Error{
  case sync(String)
  case syncTag(String)
  case syncTask(String)
}

class NetworkAPIManagerTest{
  static let shared = NetworkAPIManagerTest()
  let tagStorage = TagStorage()
  let taskStorage = TaskStorage()
  let proviter = MoyaProvider<GotAPIService>()
  let disposeBag = DisposeBag()
  
  var nickname: String{
    return UserDefaults.standard.string(forDefines: .nickname)!
  }
  var email: String{
    return UserDefaults.standard.string(forDefines: .userID)!
  }
  
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
          self.tagStorage.sync(syncData).subscribe { completable in
            observer(completable)
          }.disposed(by: self.disposeBag)
      }.disposed(by: self.disposeBag)
      return Disposables.create()
    }
  }
  
  func uploadAllTags() -> Observable<[TagData]> {
    return Observable.create { observer -> Disposable in
      self.getMergedUnsyncedTags().bind { (info) in
        self.proviter.request(.synchronize(["tags": info])) { (result) in
          switch result{
          case .success(let syncResponse):
              let decoder = JSONDecoder()
              do{
                  let jsonData = try decoder.decode(SyncResponse.self, from: syncResponse.data)
                observer.onNext(jsonData.tags)
              }catch let error{
                observer.onError(error)
              }
          case .failure(let error):
              print(error.localizedDescription)
          }
        }
      }.disposed(by: self.disposeBag)
      return Disposables.create()
    }
  }
  
  func syncTasks() -> Completable{
    return Completable.create { observer in
      Observable.zip(self.getAllUnsyncedTasks(),self.uploadAllTasks()).bind { (gotList, gotDataList) in
        guard gotList.count == gotDataList.count else { observer(.error(NetworkAPIManagerError.syncTask("tag 개수가 일치하지 않음")))
          return
        }
        var syncData: [(NSManagedObjectID, Got)] = []
        for i in 0..<gotList.count{
          guard let objectId = gotList[i].objectId else {
            observer(.error(NetworkAPIManagerError.syncTag("objectId가 존재하지 않음")))
            return
          }
          let task = gotDataList[i]
          var newGot = Got(id: task.id, title: task.title, latitude: task.coordinates[0], longitude: task.coordinates[1], place: task.address, insertedDate: Date(), tag: [])
          if let tagId = task.tag, let tag = self.tagStorage.read(id: tagId){
            newGot.tag?.append(tag)
          }
          syncData.append((objectId, newGot))
        }
        self.taskStorage.sync(syncData).subscribe { completable in
          observer(completable)
        }.disposed(by: self.disposeBag)
      }.disposed(by: self.disposeBag)
      return Disposables.create()
    }
  }
  
  func uploadAllTasks() -> Observable<[GotResponseData]> {
    return Observable.create { observer -> Disposable in
      self.getMergedUnsyncedTasks().bind { info in
        self.proviter.request(.synchronize(["tasks": info])) { (result) in
          switch result{
          case .success(let syncResponse):
              let decoder = JSONDecoder()
              do{
                  let jsonData = try decoder.decode(SyncResponse.self, from: syncResponse.data)
                observer.onNext(jsonData.tasks)
              }catch let error{
                observer.onError(error)
              }
          case .failure(let error):
              print(error.localizedDescription)
          }
        }
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
      }}
  }
  
  private func getAllUnsyncedTags() -> Observable<[Tag]>{
    return tagStorage.readList().map { $0.filter { $0.id == "" } }
  }
  
  private func getAllUnsyncedTasks() -> Observable<[Got]>{
    return taskStorage.fetchList().map { $0.filter { $0.id == ""} }
  }
}
