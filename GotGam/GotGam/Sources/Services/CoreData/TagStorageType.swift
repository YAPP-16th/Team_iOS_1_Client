//
//  TagStorageType.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/31.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

enum TagStorageError: Error{
  case create(String)
  case read(String)
  case update(String)
  case delete(String)
  case sync(String)
}

protocol TagStorageType{
  @discardableResult
  func create(tag: Tag) -> Observable<Tag>
  
  @discardableResult
  func readList() -> Observable<[Tag]>
  
  @discardableResult
  func read(objectId: NSManagedObjectID) -> Observable<Tag>
  
  @discardableResult
  func update(objectId: NSManagedObjectID, toUpdate: Tag) -> Observable<Tag>
  
  func delete(objectId: NSManagedObjectID) -> Completable
}
