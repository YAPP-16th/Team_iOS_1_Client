//
//  TaskStorage.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class GotStorage: GotStorageType {
    private let context = DBManager.share.context
    
    func fetchGotList(of tag: Tag) -> Observable<[Got]> {
        do{
            let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
            let results = try self.context.fetch(fetchRequest)
            
            var gotList = [Got]()
            if let tag = results.first, let setGot = tag.got {
                for g in setGot {
                    if let managedGot = g as? ManagedGot {
                        let got = managedGot.toGot()
                        gotList.append(got)
                    }
                }
            }
            return .just(gotList)
        }catch{
            return .error(GotStorageError.fetchError("GotList 조회 과정에서 문제발생"))
        }
    }
    
    func fetchGotList() -> Observable<[Got]> {
        do{
            let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
            let results = try self.context.fetch(fetchRequest)
            let gotList = results.map { $0.toGot() }
            return .just(gotList)
        }catch{
            return .error(GotStorageError.fetchError("GotList 조회 과정에서 문제발생"))
        }
    }
    
    func fetchTagList() -> Observable<[Tag]> {
        do{
            let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
            let results = try self.context.fetch(fetchRequest)
            var tagList = [Tag]()
            for managedTag in results{
                let tag = managedTag.toTag()
                if !tagList.contains(tag){
                    tagList.append(tag)
                }
            }
            return .just(tagList)
        }catch{
            return .error(GotStorageError.fetchError("TagList 조회 과정에서 문제발생"))
        }
    }
    
    func fetchGot(id: String) -> Observable<Got> {
        do{
            let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
            let p1 =
                NSPredicate(format: "id == %@", id)
            let p2 = NSPredicate(format: "isFinished == NO")
            fetchRequest.predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [p1,p2])
            let results = try self.context.fetch(fetchRequest)
            if let managedGot = results.first{
                return .just(managedGot.toGot())
            }else{
                return .error(GotStorageError.fetchError("해당 데이터에 대한 Got을 찾을 수 없음"))
            }
        }catch let error{
            return .error(GotStorageError.fetchError((error.localizedDescription)))
        }
    }
    
    func fetchGot(objectId: NSManagedObjectID) -> Observable<Got?>{
        if let managedGot = self.context.object(with: objectId) as? ManagedGot{
            return .just(managedGot.toGot())
        }else{
            return .just(nil)
        }
    }
    
    func fetchTag(hex: String) -> Observable<Tag> {
        do {
            let fetchReqeust = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
            let p1 = NSPredicate(format: "hex == %@", hex)
            fetchReqeust.predicate = p1
            
            let results = try self.context.fetch(fetchReqeust)
            
            if let managedTag = results.first {
                return .just(managedTag.toTag())
            } else {
                return .error(GotStorageError.fetchError("해당 tag를 찾을 수 없음"))
            }
            
        } catch let error {
            return .error(GotStorageError.fetchError(error.localizedDescription))
        }
    }
    
    func fetchTag(objectId: NSManagedObjectID) -> Observable<Tag?> {
        if let managedTag = self.context.object(with: objectId) as? ManagedTag{
            return .just(managedTag.toTag())
        }else{
            return .just(nil)
        }
    }
    
    func createGot(gotToCreate: Got) -> Observable<Got>{
        do{
            var got = gotToCreate
            let managedGot = ManagedGot(context: self.context)
            managedGot.fromGot(got: got)
            try self.context.save()
            return .just(got)
        }catch let error{
            return .error(GotStorageError.createError(error.localizedDescription))
        }
    }
    
    func create(tag: Tag) -> Observable<Tag> {
        do {
            let managedTag = NSEntityDescription.insertNewObject(forEntityName: "ManagedTag", into: self.context) as! ManagedTag
            managedTag.fromTag(tag: tag)
            try self.context.save()
            return .just(tag)
        } catch let error{
            return .error(GotStorageError.createError(error.localizedDescription))
        }
    }
    
    func updateGot(gotToUpdate: Got) -> Observable<Got> {
        do{
            let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
            fetchRequest.predicate = NSPredicate(format: "id == %@", gotToUpdate.id!)
            let results = try self.context.fetch(fetchRequest)
            if let managedGot = results.first{
                managedGot.fromGot(got: gotToUpdate)
                do{
                    try self.context.save()
                    return .just(gotToUpdate)
                }catch let error{
                    return .error(error)
                }
            }else{
                return .error(GotStorageError.fetchError("해당 데이터에 대한 Got을 찾을 수 없음"))
            }
        }catch let error{
            return .error(GotStorageError.updateError(error.localizedDescription))
        }
    }
    
    func updateGot(_ gotToUpdate: Got) -> Observable<Got?>{
        guard let objectId = gotToUpdate.objectId, let managedGot = self.context.object(with: objectId) as? ManagedGot else {
            return .just(nil)
        }
        managedGot.fromGot(got: gotToUpdate)
        do{
            try self.context.save()
            return .just(managedGot.toGot())
        }catch{
            return .error(GotStorageError.updateError("해당 데이터를 업데이트 할 수 없음"))
        }
    }
    
    
    func updateTag(_ updatedTag: Tag) -> Observable<Tag> {
        do {
            let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
            fetchRequest.predicate = NSPredicate(format: "hex == %@", updatedTag.hex)
            let results = try self.context.fetch(fetchRequest)
            
            if let managedTag = results.first {
                managedTag.fromTag(tag: updatedTag)
                
                do {
                    try self.context.save()
                    return .just(updatedTag)
                } catch let error {
                    return .error(error)
                }
            } else {
                return .error(GotStorageError.fetchError("해당 데이터에 대한 Tag를 찾을 수 없음"))
            }
        } catch let error {
            return .error(GotStorageError.updateError(error.localizedDescription))
        }
    }
    
    func updateTag(_ tagToUpdate: Tag) -> Observable<Tag?>{
        guard let objectId = tagToUpdate.objectId, let managedTag = self.context.object(with: objectId) as? ManagedTag else {
            return .just(nil)
        }
        managedTag.fromTag(tag: tagToUpdate)
        do{
            try self.context.save()
            return .just(managedTag.toTag())
        }catch{
            return .error(GotStorageError.updateError("해당 태그를 데이트 할 수 없음"))
        }
    }
    
    func update(tag origin: Tag, to updated: Tag) -> Observable<Tag> {
        do {
            let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
            fetchRequest.predicate = NSPredicate(format: "hex == %@", origin.hex)
            let results = try self.context.fetch(fetchRequest)
            
            if let managedTag = results.first {
                managedTag.fromTag(tag: updated)
                
                do {
                    try self.context.save()
                    return .just(updated)
                } catch let error {
                    return .error(error)
                }
            } else {
                return .error(GotStorageError.fetchError("해당 데이터에 대한 Tag를 찾을 수 없음"))
            }
        } catch let error {
            return .error(GotStorageError.updateError(error.localizedDescription))
        }
    }
    
    func deleteGot(id: String) -> Observable<Got> {
        do{
            let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let results = try self.context.fetch(fetchRequest)
            if let managedGot = results.first{
                let got = managedGot.toGot()
                self.context.delete(managedGot)
                do{
                    try self.context.save()
                    return .just(got)
                }catch{
                    return .error(GotStorageError.deleteError("id가 \(id)인 Got을 제거하는데 오류 발생"))
                }
            }else{
                return .error(GotStorageError.fetchError("해당 데이터에 대한 Got을 찾을 수 없음"))
            }
        }catch let error{
            return .error(GotStorageError.deleteError(error.localizedDescription))
        }
    }
    
    func deleteGot(got: Got) -> Observable<Got> {
        deleteGot(id: got.id!)
    }
    
    func deleteGot(_ objectId: NSManagedObjectID) -> Observable<Bool> {
        guard let managedGot = self.context.object(with: objectId) as? ManagedGot else {
            return .just(false)
        }
        self.context.delete(managedGot)
        do{
            try self.context.save()
            return .just(true)
        }catch{
            return .error(GotStorageError.deleteError("Got 삭제중 에러 발생"))
        }
    }
    
    func deleteTag(hex: String) -> Observable<Tag> {
        do{
            let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
            fetchRequest.predicate = NSPredicate(format: "hex == %@", hex)
            let results = try self.context.fetch(fetchRequest)
            if let managedTag = results.first{
                let tag = managedTag.toTag()
                self.context.delete(managedTag)
                
                do{
                    try self.context.save()
                    return .just(tag)
                }catch{
                    return .error(GotStorageError.deleteError("hex가 \(hex)인 Tag를 제거하는데 오류 발생"))
                }
            }else{
                return .error(GotStorageError.fetchError("해당 데이터에 대한 Tag를 찾을 수 없음"))
            }
        }catch let error{
            return .error(GotStorageError.deleteError(error.localizedDescription))
        }
    }
    
    func deleteTag(tag: Tag) -> Observable<Tag> {
        deleteTag(hex: tag.hex)
    }
    
    func deleteTag(_ objectId: NSManagedObjectID) -> Observable<Bool> {
        guard let managedTag = self.context.object(with: objectId) as? ManagedTag else {
            return .just(false)
        }
        self.context.delete(managedTag)
        do{
            try self.context.save()
            return .just(true)
        }catch{
            return .error(GotStorageError.deleteError("Tag 삭제중 에러 발생"))
        }
    }
    
    func deleteUnsyncedTag() -> Observable<Bool>{
        do{
            let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
            let results = try self.context.fetch(fetchRequest)
            let unsyncedList = results.filter { $0.id == "" }
            for u in unsyncedList{
                self.context.delete(u)
            }
            do{
                try self.context.save()
                return .just(true)
            }catch{
                return .just(false)
            }
        }catch{
            return .just(false)
        }
    }
    func deleteUnsyncedGot() -> Observable<Bool>{
        do{
            let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
            let results = try self.context.fetch(fetchRequest)
            let unsyncedList = results.filter { $0.id == "" }
            for u in unsyncedList{
                self.context.delete(u)
            }
            do{
                try self.context.save()
                return .just(true)
            }catch{
                return .just(false)
            }
        }catch{
            return .just(false)
        }
    }
}
