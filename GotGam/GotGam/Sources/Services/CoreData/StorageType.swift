//
//  StorageType.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/31.
//  Copyright © 2020 손병근. All rights reserved.
//

import CoreData
import RxSwift

enum StorageError: Error{
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
    func fetchTaskList() -> Observable<[Got]>
    
    @discardableResult
    func fetchTaskList(with tag: Tag) -> Observable<[Got]>
    
    @discardableResult
    func fetch(taskObjectId: NSManagedObjectID) -> Observable<Got>
    
    @discardableResult
    func update(taskObjectId: NSManagedObjectID, toUpdate: Got) -> Observable<Got>
    
    @discardableResult
    func delete(taskObjectId: NSManagedObjectID) -> Completable
}

protocol TagStorageType{
    @discardableResult
    func create(tag: Tag) -> Observable<Tag>
    
    @discardableResult
    func fetchTagList() -> Observable<[Tag]>
    
    @discardableResult
    func fetch(tagObjectId: NSManagedObjectID) -> Observable<Tag>
    
    @discardableResult
    func update(tagObjectId: NSManagedObjectID, toUpdate: Tag) -> Observable<Tag>
    
    func delete(tagObjectId: NSManagedObjectID) -> Completable
}


protocol StorageType: TaskStorageType, TagStorageType{
    
}
