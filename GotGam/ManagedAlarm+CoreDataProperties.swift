//
//  ManagedAlarm+CoreDataProperties.swift
//  GotGam
//
//  Created by woong on 2020/06/10.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedAlarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedAlarm> {
        return NSFetchRequest<ManagedAlarm>(entityName: "ManagedAlarm")
    }

    @NSManaged public var checkedDate: Date?
    @NSManaged public var createdDate: Date
    @NSManaged public var insertedDate: Date?
    @NSManaged public var isChecked: Bool
    @NSManaged var type: AlarmType
    @NSManaged public var title: String
    @NSManaged public var message: String
    @NSManaged public var tag: String?

}
