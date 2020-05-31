//
//  TaskStorage.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/31.
//  Copyright © 2020 손병근. All rights reserved.
//

import CoreData
import RxSwift

class TaskStorage: TaskStorageType{
  
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
      return .error(TaskStorageError.create(error.localizedDescription))
    }
  }
  
  func fetchList() -> Observable<[Got]> {
    let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
    do{
      let managedGotList = try self.context.fetch(fetchRequest)
      let gotList = managedGotList.map { $0.toGot() }
      return .just(gotList)
    }catch let error{
      return .error(TaskStorageError.create(error.localizedDescription))
    }
  }
  
  func fetch(objectId: NSManagedObjectID) -> Observable<Got> {
    guard let managedGot = self.context.object(with: objectId) as? ManagedGot else {
      return .error(TaskStorageError.read("objectId 오류"))
    }
    return .just(managedGot.toGot())
  }
  
  func update(objectId: NSManagedObjectID, toUpdate: Got) -> Observable<Got> {
    guard let managedGot = self.context.object(with: objectId) as? ManagedGot else {
      return .error(TaskStorageError.update("objectId 오류"))
    }
    managedGot.fromGot(got: toUpdate)
    do{
      try self.context.save()
      return .just(managedGot.toGot())
    }catch let error{
      return .error(TaskStorageError.update(error.localizedDescription))
    }
  }
  
  func delete(objectId: NSManagedObjectID) -> Completable {
    guard let managedGot = self.context.object(with: objectId) as? ManagedGot else {
      return .error(TaskStorageError.delete("objectId 오류"))
    }
    self.context.delete(managedGot)
    do{
      try self.context.save()
      return .empty()
    }catch let error{
      return .error(TaskStorageError.delete(error.localizedDescription))
    }
  }
  
  //MARK: - Online
  func sync(_ dataList: [(NSManagedObjectID, Got)]) -> Completable{
    return Completable.create { observer in
      for d in dataList{
        guard let managedGot = self.context.object(with: d.0) as? ManagedGot else {
          observer(.error(TaskStorageError.sync("objectId에 해당하는 데이터가 없음")))
          return Disposables.create()
        }
        managedGot.fromGot(got: d.1)
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
}
