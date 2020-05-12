//
//  TagStorage.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/12.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class TagStorage: TagStorageType {
    private let context = DBManager.share.context
    
    @discardableResult
    func fetchTagList() -> Observable<[Tag]> {
        do{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedTag")
            let results = try self.context.fetch(fetchRequest) as! [ManagedTag]
            let tagList = results.map { $0.toTag() }
            return .just(tagList)
        }catch{
            return .error(TagStorageError.fetchError("TagList 조회 과정에서 문제발생"))
        }
    }
    
    @discardableResult
    func createTag(tagToCreate: Tag) -> Observable<Tag>{
        do{
            let managedTag = NSEntityDescription.insertNewObject(forEntityName: "ManagedTag", into: self.context) as! ManagedTag
            managedTag.fromTag(tag: tagToCreate)
            try self.context.save()
            return .just(tagToCreate)
        }catch{
            return .error(TagStorageError.createError("Tag 생성 과정에서 문제발생"))
        }
    }
}
