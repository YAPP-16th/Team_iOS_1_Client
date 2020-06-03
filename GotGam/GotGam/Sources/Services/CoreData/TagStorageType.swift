//
//  TagStorageType.swift
//  GotGam
//
//  Created by 손병근 on 2020/06/03.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

protocol TagStorageType{
    @discardableResult
    func createTag(tag: Tag) -> Observable<Tag>
    
    @discardableResult
    func fetchTagList() -> Observable<[Tag]>
    
    @discardableResult
    func fetchTag(tagObjectId: NSManagedObjectID) -> Observable<Tag>
    
    @discardableResult
    func updateTag(tagObjectId: NSManagedObjectID, toUpdate: Tag) -> Observable<Tag>
    
    func deleteTag(tagObjectId: NSManagedObjectID) -> Completable
}
