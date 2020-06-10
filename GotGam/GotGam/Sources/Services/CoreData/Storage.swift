//
//  TaskStorage.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/31.
//  Copyright © 2020 손병근. All rights reserved.
//

import CoreData
import RxSwift
 //MARK: - TaskStorageType
class Storage: StorageType {
    
    
   
  //MARK: - Offline
  
  private let context = DBManager.share.context
    
  func createTask(task: Got) -> Observable<Got> {
    let managedGot = ManagedGot(context: self.context)
    managedGot.fromGot(got: task)
    do{
      try self.context.save()
      let got = managedGot.toGot()
      return .just(got)
    }catch let error{
      return .error(StorageError.create(error.localizedDescription))
    }
  }
  
  func fetchTaskList() -> Observable<[Got]> {
    let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
    do{
      let managedGotList = try self.context.fetch(fetchRequest)
      let gotList = managedGotList.map { $0.toGot() }
      return .just(gotList)
    }catch let error{
      return .error(StorageError.create(error.localizedDescription))
    }
  }
    
    func fetchTaskList(with tag: Tag) -> Observable<[Got]> {
        guard let managedTag = self.context.object(with: tag.objectId!) as? ManagedTag else {
          return .error(StorageError.read("objectId 오류"))
        }
        if let managedGotLists = managedTag.got.allObjects as? [ManagedGot]{
            let gotLists = managedGotLists.map { $0.toGot() }
            return .just(gotLists)
        }else{
            return .just([])
        }
    }
  
  func fetchTask(taskObjectId: NSManagedObjectID) -> Observable<Got> {
    guard let managedGot = self.context.object(with: taskObjectId) as? ManagedGot else {
      return .error(StorageError.read("objectId 오류"))
    }
    return .just(managedGot.toGot())
  }
  
  func updateTask(taskObjectId: NSManagedObjectID, toUpdate: Got) -> Observable<Got> {
    guard let managedGot = self.context.object(with: taskObjectId) as? ManagedGot else {
      return .error(StorageError.update("objectId 오류"))
    }
    managedGot.fromGot(got: toUpdate)
    do{
      try self.context.save()
      return .just(managedGot.toGot())
    }catch let error{
      return .error(StorageError.update(error.localizedDescription))
    }
  }
  
  func deleteTask(taskObjectId: NSManagedObjectID) -> Completable {
    guard let managedGot = self.context.object(with: taskObjectId) as? ManagedGot else {
      return .error(StorageError.delete("objectId 오류"))
    }
    self.context.delete(managedGot)
    do{
      try self.context.save()
      return .empty()
    }catch let error{
      return .error(StorageError.delete(error.localizedDescription))
    }
  }
    
    func reorderTask(toObjectID origin: NSManagedObjectID, fromObjectID destination: NSManagedObjectID) {
        guard
            let fromManagedGot = self.context.object(with: origin) as? ManagedGot,
            let toManagedGot = self.context.object(with: destination) as? ManagedGot
            else { return }
        
        let fromGot = fromManagedGot.toGot()
        let toGot = toManagedGot.toGot()
        
        do {
            fromManagedGot.fromGot(got: toGot)
            toManagedGot.fromGot(got: fromGot)
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
  
  //MARK: - Online
  func syncTask(_ dataList: [(NSManagedObjectID, Got)]) -> Completable{
    return Completable.create { observer in
      for d in dataList{
        guard let managedGot = self.context.object(with: d.0) as? ManagedGot else {
          observer(.error(StorageError.sync("objectId에 해당하는 데이터가 없음")))
          return Disposables.create()
        }
        managedGot.fromGot(got: d.1)
      }
      do{
        try self.context.save()
        observer(.completed)
      }catch let error{
        observer(.error(StorageError.sync(error.localizedDescription)))
      }
      return Disposables.create()
    }
  }
}

//MARK: - TagStorageType
extension Storage{
    func createTag(tag: Tag) -> Observable<Tag> {
      let managedTag = ManagedTag(context: self.context)
      managedTag.fromTag(tag: tag)
      do{
        try self.context.save()
        return .just(managedTag.toTag())
      }catch let error{
        return .error(StorageError.create(error.localizedDescription))
      }
    }
    
    func fetchTagList() -> Observable<[Tag]> {
      let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
      do{
        let managedTagList = try self.context.fetch(fetchRequest)
        let tagList = managedTagList.map { $0.toTag() }
        return .just(tagList)
      }catch let error{
        return .error(StorageError.read(error.localizedDescription))
      }
    }
    
    func fetchEmptyTagList() -> Observable<[Tag]> {
      let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
      do{
        let managedTagList = try self.context.fetch(fetchRequest)
        let tagList = managedTagList.filter({$0.got.count == 0}).map { $0.toTag() }
        return .just(tagList)
      }catch let error{
        return .error(StorageError.read(error.localizedDescription))
      }
    }
    
    func fetchTag(tagObjectId: NSManagedObjectID) -> Observable<Tag> {
      guard let managedTag = self.context.object(with: tagObjectId) as? ManagedTag else {
        return .error(StorageError.read("ObjectId 오류"))
      }
      return .just(managedTag.toTag())
    }
    
    func updateTag(tagObjectId: NSManagedObjectID, toUpdate: Tag) -> Observable<Tag> {
      guard let managedTag = self.context.object(with: tagObjectId) as? ManagedTag else {
        return .error(StorageError.read("ObjectId 오류"))
      }
      managedTag.fromTag(tag: toUpdate)
      do{
        try self.context.save()
        let tag = managedTag.toTag()
        return .just(tag)
      }catch let error{
        return .error(StorageError.update(error.localizedDescription))
      }
    }
    
    func deleteTag(tagObjectId: NSManagedObjectID) -> Completable {
      guard let managedTag = self.context.object(with: tagObjectId) as? ManagedTag else {
        return .error(StorageError.read("ObjectId 오류"))
      }
      self.context.delete(managedTag)
      do{
        try self.context.save()
        return .empty()
      }catch let error{
        return .error(StorageError.delete(error.localizedDescription))
      }
    }
    
    func syncTag(_ dataList: [(NSManagedObjectID, Tag)]) -> Completable{
      return Completable.create { observer in
        for d in dataList{
          guard let managedTag = self.context.object(with: d.0) as? ManagedTag else {
            observer(.error(StorageError.sync("objectId에 해당하는 데이터가 없음")))
            return Disposables.create()
          }
          managedTag.fromTag(tag: d.1)
        }
        do{
          try self.context.save()
          observer(.completed)
        }catch let error{
          observer(.error(StorageError.sync(error.localizedDescription)))
        }
        return Disposables.create()
      }
    }
    
    //MARK: - Server
    func read(id: String) -> Tag?{
      let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
      do{
        let managedTagList = try self.context.fetch(fetchRequest)
        return managedTagList.first?.toTag()
      }catch{
        return nil
      }
    }
}
//MARK: - FrequentStorageType

extension Storage{
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
    
    func updateFrequents(frequent: Frequent) -> Observable<Frequent> {
        do{
            let fetchRequest = NSFetchRequest<ManagedFrequents>(entityName: "ManagedFrequents")
            fetchRequest.predicate = NSPredicate(format: "id == %@", frequent.id)
            let results = try self.context.fetch(fetchRequest)
            if let managedFrequents = results.first {
                do{
                    managedFrequents.fromFrequents(frequent: frequent)
                    try self.context.save()
                    return .just(managedFrequents.toFrequents())
                }catch let error{
                    return .error(error)
                }
            }else{
                print("해당 데이터에 대한 Frequents을 찾을 수 없음. error: ")
                return .error(FrequentsStorageError.updateError("Error"))
            }
        } catch let error as NSError{
            print("error: ", error.localizedDescription)
            return .error(error)
        }
    }
    
    func deleteFrequents(id: String) -> Observable<Frequent> {
        do{
            let fetchRequest = NSFetchRequest<ManagedFrequents>(entityName: "ManagedFrequents")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let results = try self.context.fetch(fetchRequest)
            if let managedFrequents = results.first {
                let frequents = managedFrequents.toFrequents()
                self.context.delete(managedFrequents)
                do{
                    try self.context.save()
                    return .just(frequents)
                }catch{
                    return .error(FrequentsStorageError.deleteError("id이 \(id)인 Frequents을 제거하는데 오류 발생"))
                }
            }else{
                return .error(FrequentsStorageError.fetchError("해당 데이터에 대한 Frequents을 찾을 수 없음"))
            }
        }catch let error{
            return .error(FrequentsStorageError.deleteError(error.localizedDescription))
        }
    }
    
    func deleteFrequents(frequent: Frequent) -> Observable<Frequent> {
        deleteFrequents(id: frequent.id)
    }
}
//MARK: - Search StorageType
extension Storage{
    func createKeyword(history: History) -> Observable<History> {
        let managedHistory = ManagedHistory(context: self.context)
        managedHistory.fromHistory(history: history)
		
        do{
            try self.context.save()
			return .just(managedHistory.toHistory())
        }catch let error as NSError{
            print("history를 생성할 수 없습니다. error: ", error.userInfo)
            return .error(error)
        }
    }
    
    func fetchKeyword() -> Observable<[History]> {
        let fetchRequest = NSFetchRequest<ManagedHistory>(entityName: "ManagedHistory")
        do {
            let managedHistoryList = try self.context.fetch(fetchRequest)
			let historyList = managedHistoryList.map { $0.toHistory() }
            return .just(historyList)
        }catch let error as NSError{
            print("history를 읽을 수 없습니다. error: ", error.userInfo)
            return .error(error)
        }
    }
	
	func deleteKeyword(historyObjectId: NSManagedObjectID) -> Completable {
		guard let managedHistory = self.context.object(with: historyObjectId) as? ManagedHistory else {
			return .error(StorageError.read("ObjectId 오류"))
		}
			self.context.delete(managedHistory)
		do {
			try self.context.save()
			return .empty()
		} catch let error{
			return .error(StorageError.delete(error.localizedDescription))
		}
	}
}
//MARK: - AlarmStorageType
extension Storage{
    func createAlarm(_ alarm: Alarm) -> Observable<Alarm> {
        do {
            var alarm = alarm
            //self.createId(alarm: &alarm)
            let managedAlarm = ManagedAlarm(context: self.context)
            managedAlarm.fromAlarm(alarm)
            alarm.id = managedAlarm.objectID
            try self.context.save()
            return .just(alarm)
        } catch let error {
            return .error(StorageError.create(error.localizedDescription))
        }
    }
    
    func fetchAlarmList() -> Observable<[Alarm]> {
        do{
            let fetchRequest = NSFetchRequest<ManagedAlarm>(entityName: "ManagedAlarm")
            let results = try self.context.fetch(fetchRequest).reversed()
            let alarmList = results.map { $0.toAlarm() }
            
            return .just(alarmList)
        }catch{
            return .error(StorageError.read("TagList 조회 과정에서 문제발생"))
        }
    }
    
    func fetchAlarm(id: NSManagedObjectID) -> Observable<Alarm> {
        if let managedAlarm = self.context.object(with: id) as? ManagedAlarm {
            return .just(managedAlarm.toAlarm())
        } else {
            return .error(StorageError.read("해당 alarm을 찾을 수 없음"))
        }
    }
    
    func updateAlarm(to alarm: Alarm) -> Observable<Alarm> {
        guard let id = alarm.id else { return .error(StorageError.read("Alarm의 ID를 찾을 수 없음"))}
        
        if let managedAlarm = context.object(with: id) as? ManagedAlarm {
            managedAlarm.fromAlarm(alarm)
            do{
                try self.context.save()
                return .just(alarm)
            }catch let error{
                return .error(error)
            }
        }else{
            return .error(StorageError.read("해당 데이터에 대한 Alarm을 찾을 수 없음"))
        }
    }
    
    func deleteAlarm(id: NSManagedObjectID) -> Observable<Alarm> {
        
        if let managedAlarm = context.object(with: id) as? ManagedAlarm {
            let alarm = managedAlarm.toAlarm()
            self.context.delete(managedAlarm)
            do{
                try self.context.save()
                return .just(alarm)
            }catch{
                return .error(StorageError.delete("id가 \(id)인 Alarm을 제거하는데 오류 발생"))
            }
        }else{
            return .error(StorageError.delete("해당 데이터에 대한 Alarm을 찾을 수 없음"))
        }
    }
    
    func deleteAlarm(alarm: Alarm) -> Observable<Alarm> {
        guard let id = alarm.id else { return .error(StorageError.read("Alarm의 ID를 찾을 수 없음"))}
        
        return deleteAlarm(id: id)
    }
    
}
