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
            id: id,
            checkedDate: checkedDate,
            isChecked: isChecked,
            got: got?.toGot())
    }
    
    func fromAlarm(_ alarm: Alarm) {
        guard let got = alarm.got, let context = self.managedObjectContext else { return }
        let managedGot = ManagedGot(context: context)
        managedGot.fromGot(got: got)
       
        self.id = alarm.id
        self.createdDate = alarm.createdDate
        self.checkedDate = alarm.checkedDate
        self.isChecked = alarm.isChecked
        self.got = managedGot
    }
}
