//
//  TaskStorage.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/31.
//  Copyright © 2020 손병근. All rights reserved.
//

import CoreData
import RxSwift

class Storage: StorageType {
  
    //MARK: - TaskStorageType
  //MARK: - Offline
  
  private let context = DBManager.share.context
  func create(task: Got) -> Observable<Got> {
    let managedGot = ManagedGot(context: self.context)
    managedGot.fromGot(got: task)
    do{
      try self.context.save()
      let got = managedGot.toGot()
      return .just(got)
    }catch let error{
      return .error(StorageError.create(error.localizedDescription))
    }
  }
  
  func fetchTaskList() -> Observable<[Got]> {
    let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
    do{
      let managedGotList = try self.context.fetch(fetchRequest)
      let gotList = managedGotList.map { $0.toGot() }
      return .just(gotList)
    }catch let error{
      return .error(StorageError.create(error.localizedDescription))
    }
  }
    
    func fetchTaskList(with tag: Tag) -> Observable<[Got]> {
        guard let managedTag = self.context.object(with: tag.objectId!) as? ManagedTag else {
          return .error(StorageError.read("objectId 오류"))
        }
        if let managedGotLists = managedTag.got.allObjects as? [ManagedGot]{
            let gotLists = managedGotLists.map { $0.toGot() }
            return .just(gotLists)
        }else{
            return .just([])
        }
    }
  
  func fetch(taskObjectId: NSManagedObjectID) -> Observable<Got> {
    guard let managedGot = self.context.object(with: taskObjectId) as? ManagedGot else {
      return .error(StorageError.read("objectId 오류"))
    }
    return .just(managedGot.toGot())
  }
  
  func update(taskObjectId: NSManagedObjectID, toUpdate: Got) -> Observable<Got> {
    guard let managedGot = self.context.object(with: taskObjectId) as? ManagedGot else {
      return .error(StorageError.update("objectId 오류"))
    }
    managedGot.fromGot(got: toUpdate)
    do{
      try self.context.save()
      return .just(managedGot.toGot())
    }catch let error{
      return .error(StorageError.update(error.localizedDescription))
    }
  }
  
  func delete(taskObjectId: NSManagedObjectID) -> Completable {
    guard let managedGot = self.context.object(with: taskObjectId) as? ManagedGot else {
      return .error(StorageError.delete("objectId 오류"))
    }
    self.context.delete(managedGot)
    do{
      try self.context.save()
      return .empty()
    }catch let error{
      return .error(StorageError.delete(error.localizedDescription))
    }
  }
  
  //MARK: - Online
  func sync(_ dataList: [(NSManagedObjectID, Got)]) -> Completable{
    return Completable.create { observer in
      for d in dataList{
        guard let managedGot = self.context.object(with: d.0) as? ManagedGot else {
          observer(.error(StorageError.sync("objectId에 해당하는 데이터가 없음")))
          return Disposables.create()
        }
        managedGot.fromGot(got: d.1)
      }
      do{
        try self.context.save()
        observer(.completed)
      }catch let error{
        observer(.error(StorageError.sync(error.localizedDescription)))
      }
      return Disposables.create()
    }
  }
    
    
    
    
    
    
    //MARK: - TagStorageType
    
    
    
    func create(tag: Tag) -> Observable<Tag> {
      let managedTag = ManagedTag(context: self.context)
      managedTag.fromTag(tag: tag)
      do{
        try self.context.save()
        return .just(managedTag.toTag())
      }catch let error{
        return .error(StorageError.create(error.localizedDescription))
      }
    }
    
    func fetchTagList() -> Observable<[Tag]> {
      let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
      do{
        let managedTagList = try self.context.fetch(fetchRequest)
        let tagList = managedTagList.map { $0.toTag() }
        return .just(tagList)
      }catch let error{
        return .error(StorageError.read(error.localizedDescription))
      }
    }
    
    func fetch(tagObjectId: NSManagedObjectID) -> Observable<Tag> {
      guard let managedTag = self.context.object(with: tagObjectId) as? ManagedTag else {
        return .error(StorageError.read("ObjectId 오류"))
      }
      return .just(managedTag.toTag())
    }
    
    func update(tagObjectId: NSManagedObjectID, toUpdate: Tag) -> Observable<Tag> {
      guard let managedTag = self.context.object(with: tagObjectId) as? ManagedTag else {
        return .error(StorageError.read("ObjectId 오류"))
      }
      managedTag.fromTag(tag: toUpdate)
      do{
        try self.context.save()
        let tag = managedTag.toTag()
        return .just(tag)
      }catch let error{
        return .error(StorageError.update(error.localizedDescription))
      }
    }
    
    func delete(tagObjectId: NSManagedObjectID) -> Completable {
      guard let managedTag = self.context.object(with: tagObjectId) as? ManagedTag else {
        return .error(StorageError.read("ObjectId 오류"))
      }
      self.context.delete(managedTag)
      do{
        try self.context.save()
        return .empty()
      }catch let error{
        return .error(StorageError.delete(error.localizedDescription))
      }
    }
    
    func sync(_ dataList: [(NSManagedObjectID, Tag)]) -> Completable{
      return Completable.create { observer in
        for d in dataList{
          guard let managedTag = self.context.object(with: d.0) as? ManagedTag else {
            observer(.error(StorageError.sync("objectId에 해당하는 데이터가 없음")))
            return Disposables.create()
          }
          managedTag.fromTag(tag: d.1)
        }
        do{
          try self.context.save()
          observer(.completed)
        }catch let error{
          observer(.error(StorageError.sync(error.localizedDescription)))
        }
        return Disposables.create()
      }
    }
    
    //MARK: - Server
    func read(id: String) -> Tag?{
      let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
      do{
        let managedTagList = try self.context.fetch(fetchRequest)
        return managedTagList.first?.toTag()
      }catch{
        return nil
      }
    }
}
