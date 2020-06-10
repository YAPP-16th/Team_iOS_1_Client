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
    managedGot.objectIDString = managedGot.objectID.uriRepresentation().absoluteString
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
  func syncTask(_ dataList: [SyncData<Got>]) -> Completable{
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
    
    func syncAllTasks(tasks: [Got]) -> Completable{
        return Completable.create { observer in
            for got in tasks{
                guard self.readTask(id: got.id) == nil else { continue }
                let managedGot = ManagedGot(context: self.context)
                managedGot.fromGot(got: got)
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
    func readTask(id: String) -> Got?{
      let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
      do{
        let managedTagList = try self.context.fetch(fetchRequest)
        return managedTagList.first?.toGot()
      }catch{
        return nil
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
    
    func fetchTag(hex: String) -> Observable<Tag> {
        let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
        fetchRequest.predicate = NSPredicate(format: "hex == %@", hex)
        do {
            if let managedTag = try self.context.fetch(fetchRequest).first {
                return .just(managedTag.toTag())
            }
            return .empty()
        } catch let error {
            print(error.localizedDescription)
            return .empty()
        }
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
    
    func syncTag(_ dataList: [SyncData<Tag>]) -> Completable{
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
    
    func syncAllTag(tagList: [Tag]) -> Completable{
        return Completable.create { observer in
            for tag in tagList{
                guard self.readTag(id: tag.id) == nil else { continue }
                let managedTag = ManagedTag(context: self.context)
                managedTag.fromTag(tag: tag)
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
    func readTag(id: String) -> Tag?{
      let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
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
        managedFrequents.fromFrequents(frequent: frequent)
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
            guard let objectId = frequent.objectId, let managedFrequents = self.context.object(with: objectId) as? ManagedFrequents else {
                return .error(StorageError.update("프리퀀트 id가 존재하지 않음"))
            }
            managedFrequents.fromFrequents(frequent: frequent)
            try self.context.save()
            return .just(managedFrequents.toFrequents())
        
        } catch let error{
            return .error(StorageError.update(error.localizedDescription))
        }
    }
    
    func deleteFrequents(objectId: NSManagedObjectID) -> Observable<Frequent> {
        do{
            guard let managedFrequents = self.context.object(with: objectId) as? ManagedFrequents else {
                return .error(StorageError.update("프리퀀트 id가 존재하지 않음"))
            }
            let frequents = managedFrequents.toFrequents()
            self.context.delete(managedFrequents)
            try self.context.save()
            return .just(frequents)
        }catch let error{
            return .error(StorageError.delete(error.localizedDescription))
        }
    }
    
    func deleteFrequents(frequent: Frequent) -> Observable<Frequent> {
        deleteFrequents(objectId: frequent.objectId!)
    }
    
    
    func syncFrequents(_ dataList: [SyncData<Frequent>]) -> Completable{
      return Completable.create { observer in
        for d in dataList{
          guard let managedFrequents = self.context.object(with: d.0) as? ManagedFrequents else {
            observer(.error(StorageError.sync("objectId에 해당하는 데이터가 없음")))
            return Disposables.create()
          }
            managedFrequents.fromFrequents(frequent: d.1)
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
    
    func readFrequents(id: String) -> Frequent?{
      let fetchRequest = NSFetchRequest<ManagedFrequents>(entityName: "ManagedFrequents")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
      do{
        let managedFrequentList = try self.context.fetch(fetchRequest)
        return managedFrequentList.first?.toFrequents()
      }catch{
        return nil
      }
    }
    
    func syncAllFrequents(frequentsList: [Frequent]) -> Completable{
        return Completable.create { observer in
            for frequents in frequentsList{
                guard self.readFrequents(id: frequents.id) == nil else { continue }
                let managedFrequents = ManagedFrequents(context: self.context)
                managedFrequents.fromFrequents(frequent: frequents)
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
    func createAlarm(_ alarm: ManagedAlarm) -> Observable<ManagedAlarm> {
        do {
            var alarm = alarm
            //self.createId(alarm: &alarm)
            let managedAlarm = ManagedAlarm(context: self.context)
            //managedAlarm.fromAlarm(alarm)
            //alarm.id = managedAlarm.objectID.uriRepresentation().absoluteString
            try self.context.save()
            return .just(alarm)
        } catch let error {
            return .error(StorageError.create(error.localizedDescription))
        }
    }
    
    func fetchAlarmList() -> Observable<[ManagedAlarm]> {
        do{
            let fetchRequest = NSFetchRequest<ManagedAlarm>(entityName: "ManagedAlarm")
            let results = try self.context.fetch(fetchRequest).reversed()
            let alarmList = results.map { $0 }
            
            return .just(alarmList)
        }catch{
            return .error(StorageError.read("TagList 조회 과정에서 문제발생"))
        }
    }
    
    func fetchAlarm(id: NSManagedObjectID) -> Observable<ManagedAlarm> {
        if let managedAlarm = self.context.object(with: id) as? ManagedAlarm {
            return .just(managedAlarm)
        } else {
            return .error(StorageError.read("해당 alarm을 찾을 수 없음"))
        }
    }
    
    func updateAlarm(to alarm: ManagedAlarm) -> Observable<ManagedAlarm> {
        //guard let id = alarm.id else { return .error(StorageError.read("Alarm의 ID를 찾을 수 없음"))}
        
        if let managedAlarm = context.object(with: alarm.objectID) as? ManagedAlarm {
            //managedAlarm
            do{
                try self.context.save()
                return .just(managedAlarm)
            }catch let error{
                return .error(error)
            }
        }else{
            return .error(StorageError.read("해당 데이터에 대한 Alarm을 찾을 수 없음"))
        }
    }
    
    func deleteAlarm(id: NSManagedObjectID) -> Observable<ManagedAlarm> {
        
        if let managedAlarm = context.object(with: id) as? ManagedAlarm {
            let alarm = managedAlarm
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
    
    func deleteAlarm(alarm: ManagedAlarm) -> Observable<ManagedAlarm> {
        //guard let id = alarm.id else { return .error(StorageError.read("Alarm의 ID를 찾을 수 없음"))}
        
        return deleteAlarm(id: alarm.objectID)
    }
    
}
