//
//  TaskStorageType.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/31.
//  Copyright © 2020 손병근. All rights reserved.
//

import CoreData
import RxSwift

enum TaskStorageError: Error{
  case create(String)
  case read(String)
  case update(String)
  case delete(String)
  case sync(String)
}

protocol TaskStorageType{
  
  //MARK: - Client
  @discardableResult
  func create(task: Got) -> Observable<Got>
  
  @discardableResult
  func fetchList() -> Observable<[Got]>
  
  @discardableResult
  func fetch(objectId: NSManagedObjectID) -> Observable<Got>
  
  @discardableResult
  func update(objectId: NSManagedObjectID, toUpdate: Got) -> Observable<Got>
  
  @discardableResult
  func delete(objectId: NSManagedObjectID) -> Completable
}
