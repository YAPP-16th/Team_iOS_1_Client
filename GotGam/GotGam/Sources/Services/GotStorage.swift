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
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedGot")
            let results = try self.context.fetch(fetchRequest) as! [ManagedGot]
            let gotList = results.map { $0.toGot() }
            return .just(gotList)
        }catch let error{
            return .error(error)
        }
    }
    
    func fetchGot(id: Int64) -> Observable<Got> {
        do{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedGot")
            fetchRequest.predicate = NSPredicate(format: "id == %lld", id)
            let results = try self.context.fetch(fetchRequest) as! [ManagedGot]
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
            let managedGot = NSEntityDescription.insertNewObject(forEntityName: "ManagedGot", into: self.context) as! ManagedGot
            managedGot.fromGot(got: got)
            try self.context.save()
            
            return .just(got)
        }catch let error{
            return .error(error)
        }
    }
    
    func updateGot(gotToUpdate: Got) -> Observable<Got> {
        do{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedGot")
            fetchRequest.predicate = NSPredicate(format: "id == %lld", gotToUpdate.id!)
            let results = try self.context.fetch(fetchRequest) as! [ManagedGot]
            if let managedGot = results.first{
                managedGot.fromGot(got: gotToUpdate)
                let got = managedGot.toGot()
                do{
                    try self.context.save()
                    return .just(got)
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
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedGot")
            fetchRequest.predicate = NSPredicate(format: "id == %lld", id)
            let results = try self.context.fetch(fetchRequest) as! [ManagedGot]
            if let managedGot = results.first{
                let got = managedGot.toGot()
                self.context.delete(managedGot)
                do{
                    try self.context.save()
                    return .just(got)
                }catch{
                    return .error(error)
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
