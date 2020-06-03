//
//  ManagedAlarm+CoreDataClass.swift
//  GotGam
//
//  Created by woong on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedAlarm)
public class ManagedAlarm: NSManagedObject {
    func toAlarm() -> Alarm {
        return .init(
            id: objectID,
            type: AlarmType(rawValue: type)!,
            createdDate: createdDate,
            checkedDate: checkedDate,
            isChecked: isChecked,
            got: got.toGot()
        )
    }
    
    func fromAlarm(_ alarm: Alarm) {
        self.type = alarm.type.rawValue
        self.createdDate = alarm.createdDate
        self.checkedDate = alarm.checkedDate
        self.isChecked = alarm.isChecked
        let managedGot = fetchManagedGot(from: alarm)
        //print("managedGot in fromAlarm \(managedGot)")
        //managedGot?.addToAlarms(self)
        self.got = managedGot!
    }
    func fetchManagedGot(from alarm: Alarm) -> ManagedGot? {
        
        guard let context = self.managedObjectContext else {
            print("alarm에 곳이 없어요")
            return nil
        }
        
        let gotID = alarm.got.id
        
        if gotID == "", let objectID = alarm.got.objectId {
            if let managedGot = context.object(with: objectID) as? ManagedGot {
                return managedGot
            } else {
                return nil
            }
        } else {
            do {
                let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
                let p1 =
                    NSPredicate(format: "id == %lld", gotID)
                fetchRequest.predicate = p1
                let results = try context.fetch(fetchRequest)
                if let managedGot = results.first {
                    return managedGot
                } else {
                    print("해당 데이터에 대한 Got을 찾을 수 없음")
                    return nil
                }
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
        }
    }
}
