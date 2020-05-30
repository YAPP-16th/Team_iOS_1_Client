//
//  FrequentsStorage.swift
//  GotGam
//
//  Created by 김삼복 on 23/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class FrequentsStorage: FrequentsStorageType{
	private let context = DBManager.share.context
	
	func createFrequents(frequent: Frequent) -> Observable<Frequent>{
		let managedFrequents = ManagedFrequents(context: self.context)
		managedFrequents.name = frequent.name
		managedFrequents.address = frequent.address
		managedFrequents.latitude = frequent.latitude
		managedFrequents.longitude = frequent.longitude
		managedFrequents.type = frequent.type.rawValue
		managedFrequents.id = frequent.id
		do{
			try self.context.save()
			return .just(managedFrequents.toFrequents())
		}catch let error as NSError{
			print("frequents를 생성할 수 없습니다. error: ", error.userInfo)
			return .error(error)
		}
	}
	
	func fetchFrequents() -> Observable<[Frequent]> {
		do{
			let fetchRequest = NSFetchRequest<ManagedFrequents>(entityName: "ManagedFrequents")
			let results = try self.context.fetch(fetchRequest)
			let frequentsList = results.map { $0.toFrequents()}
			return .just(frequentsList)
		}catch let error as NSError{
			print("frequents를 읽을 수 없습니다. error: ", error.userInfo)
			return .error(error)
		}
	}
	
//	func updateFrequents(Frequents: Frequents) -> Observable<Frequents> {
//		do{
//			let fetchRequest = NSFetchRequest<Frequents>(entityName: "Frequents")
//			fetchRequest.predicate = NSPredicate(format: "name == %s", Frequents.name)
//			let results = try self.context.fetch(fetchRequest)
//			if let managedFrequents = results.first {
//				do{
//					try self.context.save()
//					return .just(Frequents)
//				}catch let error{
//					return .error(error)
//				}
//			}else if let error as NSError{
//				print("해당 데이터에 대한 Frequents을 찾을 수 없음. error: ", error.userInfo)
//				return .error(error)
//			}
//		} catch let error as NSError{
//			print("error: ", error.localizedDescription)
//			return .error(error)
//		}
//	}
	
	func deleteFrequents(name: String) -> Observable<Frequent> {
        do{
            let fetchRequest = NSFetchRequest<ManagedFrequents>(entityName: "ManagedFrequents")
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
            let results = try self.context.fetch(fetchRequest)
            if let managedFrequents = results.first {
                let frequents = managedFrequents.toFrequents()
                self.context.delete(managedFrequents)
                do{
                    try self.context.save()
                    return .just(frequents)
                }catch{
                    return .error(FrequentsStorageError.deleteError("name이 \(name)인 Frequents을 제거하는데 오류 발생"))
                }
            }else{
                return .error(FrequentsStorageError.fetchError("해당 데이터에 대한 Frequents을 찾을 수 없음"))
            }
        }catch let error{
            return .error(FrequentsStorageError.deleteError(error.localizedDescription))
        }
    }
	
	func deleteFrequents(frequent: Frequent) -> Observable<Frequent> {
		deleteFrequents(name: frequent.name)
	}
}
