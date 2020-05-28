//
//  AlarmStorage.swift
//  GotGam
//
//  Created by woong on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class AlarmStorage: AlarmStorageType {
    private let context = DBManager.share.context
    
    func createAlarm(_ alarm: Alarm) -> Observable<Alarm> {
        do {
            var alarm = alarm
            self.createId(alarm: &alarm)
            let managedAlarm = ManagedAlarm(context: self.context)
            managedAlarm.fromAlarm(alarm)
            try self.context.save()
            return .just(alarm)
        } catch let error {
            return .error(AlarmStorageError.createError(error.localizedDescription))
        }
    }
    
    func fetchAlarmList() -> Observable<[Alarm]> {
        do{
            let fetchRequest = NSFetchRequest<ManagedAlarm>(entityName: "ManagedAlarm")
            let results = try self.context.fetch(fetchRequest).reversed()
            let alarmList = results.map { $0.toAlarm() }
            
            return .just(alarmList)
        }catch{
            return .error(GotStorageError.fetchError("TagList 조회 과정에서 문제발생"))
        }
    }
    
    func fetchAlarm(id: Int64) -> Observable<Alarm> {
        do {
            let fetchReqeust = NSFetchRequest<ManagedAlarm>(entityName: "ManagedTag")
            let p1 = NSPredicate(format: "id == %lld", id)
            
            
            let results = try self.context.fetch(fetchReqeust)
            
            if let managedAlarm = results.first {
                return .just(managedAlarm.toAlarm())
            } else {
                return .error(AlarmStorageError.fetchError("해당 alarm을 찾을 수 없음"))
            }
            
        } catch let error {
            return .error(AlarmStorageError.fetchError(error.localizedDescription))
        }
    }
    
    func updateAlarm(to alarm: Alarm) -> Observable<Alarm> {
        do{
            let fetchRequest = NSFetchRequest<ManagedAlarm>(entityName: "ManagedAlarm")
            fetchRequest.predicate = NSPredicate(format: "id == %lld", alarm.id)
            let results = try self.context.fetch(fetchRequest)
            if let managedAlarm = results.first {
                managedAlarm.fromAlarm(alarm)
                do{
                    try self.context.save()
                    return .just(alarm)
                }catch let error{
                    return .error(error)
                }
            }else{
                return .error(AlarmStorageError.fetchError("해당 데이터에 대한 Alarm을 찾을 수 없음"))
            }
        } catch let error {
            return .error(AlarmStorageError.updateError(error.localizedDescription))
        }
    }
    
    func deleteAlarm(id: Int64) -> Observable<Alarm> {
        do{
            let fetchRequest = NSFetchRequest<ManagedAlarm>(entityName: "ManagedAlarm")
            fetchRequest.predicate = NSPredicate(format: "id == %lld", id)
            let results = try self.context.fetch(fetchRequest)
            if let managedAlarm = results.first {
                let alarm = managedAlarm.toAlarm()
                self.context.delete(managedAlarm)
                do{
                    try self.context.save()
                    return .just(alarm)
                }catch{
                    return .error(AlarmStorageError.deleteError("id가 \(id)인 Alarm을 제거하는데 오류 발생"))
                }
            }else{
                return .error(AlarmStorageError.fetchError("해당 데이터에 대한 Alarm을 찾을 수 없음"))
            }
        }catch let error{
            return .error(AlarmStorageError.deleteError(error.localizedDescription))
        }
    }
    
    func deleteAlarm(alarm: Alarm) -> Observable<Alarm> {
        deleteAlarm(id: alarm.id)
    }
    
    
}

//MARK: - Helper

extension AlarmStorage {
    
    
    func createId(alarm: inout Alarm) {
        alarm.id = Int64(arc4random())
    }
}
