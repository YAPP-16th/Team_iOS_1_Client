//
//  TagStorage.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/31.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class TagStorage: TagStorageType{
  private let context = DBManager.share.context
  
  func create(tag: Tag) -> Observable<Tag> {
    let managedTag = ManagedTag(context: self.context)
    managedTag.fromTag(tag: tag)
    do{
      try self.context.save()
      return .just(managedTag.toTag())
    }catch let error{
      return .error(TagStorageError.create(error.localizedDescription))
    }
  }
  
  func readList() -> Observable<[Tag]> {
    let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
    do{
      let managedTagList = try self.context.fetch(fetchRequest)
      let tagList = managedTagList.map { $0.toTag() }
      return .just(tagList)
    }catch let error{
      return .error(TagStorageError.read(error.localizedDescription))
    }
  }
  
  func read(objectId: NSManagedObjectID) -> Observable<Tag> {
    guard let managedTag = self.context.object(with: objectId) as? ManagedTag else {
      return .error(TagStorageError.read("ObjectId 오류"))
    }
    return .just(managedTag.toTag())
  }
  
  func update(objectId: NSManagedObjectID, toUpdate: Tag) -> Observable<Tag> {
    guard let managedTag = self.context.object(with: objectId) as? ManagedTag else {
      return .error(TagStorageError.read("ObjectId 오류"))
    }
    managedTag.fromTag(tag: toUpdate)
    do{
      try self.context.save()
      let tag = managedTag.toTag()
      return .just(tag)
    }catch let error{
      return .error(TagStorageError.update(error.localizedDescription))
    }
  }
  
  func delete(objectId: NSManagedObjectID) -> Completable {
    guard let managedTag = self.context.object(with: objectId) as? ManagedTag else {
      return .error(TagStorageError.read("ObjectId 오류"))
    }
    self.context.delete(managedTag)
    do{
      try self.context.save()
      return .empty()
    }catch let error{
      return .error(TagStorageError.delete(error.localizedDescription))
    }
  }
  
  func sync(_ dataList: [(NSManagedObjectID, Tag)]) -> Completable{
    return Completable.create { observer in
      for d in dataList{
        guard let managedTag = self.context.object(with: d.0) as? ManagedTag else {
          observer(.error(TagStorageError.sync("objectId에 해당하는 데이터가 없음")))
          return Disposables.create()
        }
        managedTag.fromTag(tag: d.1)
      }
      do{
        try self.context.save()
        observer(.completed)
      }catch let error{
        observer(.error(TagStorageError.sync(error.localizedDescription)))
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
