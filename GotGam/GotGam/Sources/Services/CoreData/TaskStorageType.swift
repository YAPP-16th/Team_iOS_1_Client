//
//  TaskStorageType.swift
//  GotGam
//
//  Created by 손병근 on 2020/06/03.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
protocol TaskStorageType{
    
    //MARK: - Client
    @discardableResult
    func createTask(task: Got) -> Observable<Got>
    
    @discardableResult
    func fetchTaskList() -> Observable<[Got]>
    
    @discardableResult
    func fetchTaskList(with tag: Tag) -> Observable<[Got]>
    
    @discardableResult
    func fetchTask(taskObjectId: NSManagedObjectID) -> Observable<Got>
    
    @discardableResult
    func updateTask(taskObjectId: NSManagedObjectID, toUpdate: Got) -> Observable<Got>
    
    @discardableResult
    func deleteTask(taskObjectId: NSManagedObjectID) -> Completable
}
