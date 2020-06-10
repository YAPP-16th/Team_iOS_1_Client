//
//  ManagedAlarm+CoreDataClass.swift
//  GotGam
//
//  Created by woong on 2020/06/10.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedAlarm)
public class ManagedAlarm: NSManagedObject {
    
    convenience init(got: ManagedGot, type: AlarmType, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = got.title
        self.createdDate = Date()
        self.insertedDate = got.insertedDate
        self.type = type
        self.tag = got.tag?.hex
        switch type {
        case .arrive: self.message = got.arriveMsg
        case .departure: self.message = got.departureMsg
        default: self.message = ""
        }
    }
}
