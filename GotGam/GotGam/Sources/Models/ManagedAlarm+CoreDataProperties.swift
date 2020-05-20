//
//  ManagedAlarm+CoreDataProperties.swift
//  GotGam
//
//  Created by woong on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedAlarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedAlarm> {
        return NSFetchRequest<ManagedAlarm>(entityName: "ManagedAlarm")
    }

    @NSManaged public var id: Int64
    @NSManaged public var createdDate: Date?
    @NSManaged public var isChecked: Bool
    @NSManaged public var checkedDate: Date?
    @NSManaged public var got: ManagedGot?

}
