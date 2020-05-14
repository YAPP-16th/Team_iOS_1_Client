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
    
    func fetchGot(id: Int64) -> Observable<Got> {
        do{
            let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
            let p1 =
                NSPredicate(format: "id == %lld", id)
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
    
    func createGot(gotToCreate: Got) -> Observable<Got>{
        do{
            var got = gotToCreate
            self.createId(got: &got)
          let managedGot = ManagedGot(context: self.context)
            managedGot.fromGot(got: got)
            try self.context.save()
            return .just(got)
        }catch let error{
            return .error(GotStorageError.createError(error.localizedDescription))
        }
    }
    
    func updateGot(gotToUpdate: Got) -> Observable<Got> {
        do{
            let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
            fetchRequest.predicate = NSPredicate(format: "id == %lld", gotToUpdate.id!)
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
    
    func deleteGot(id: Int64) -> Observable<Got> {
        do{
            let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
            fetchRequest.predicate = NSPredicate(format: "id == %lld", id)
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
    
    //MARK: - Helper
    func createId(got: inout Got){
        guard got.id == nil else { return }
        got.id = Int64(arc4random())
    }
}
