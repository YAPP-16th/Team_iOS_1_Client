//
//  ManagedGot+CoreDataProperties.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/14.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedGot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedGot> {
        return NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
    }

    @NSManaged public var content: String?
    @NSManaged public var id: Int64
    @NSManaged public var insertedDate: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var radius: Double
    @NSManaged public var place: String?
    @NSManaged public var title: String?
    @NSManaged public var tag: NSSet?
    @NSManaged public var alarm: NSSet?

}

// MARK: Generated accessors for tag
extension ManagedGot {

    @objc(addTagObject:)
    @NSManaged public func addToTag(_ value: ManagedTag)

    @objc(removeTagObject:)
    @NSManaged public func removeFromTag(_ value: ManagedTag)

    @objc(addTag:)
    @NSManaged public func addToTag(_ values: NSSet)

    @objc(removeTag:)
    @NSManaged public func removeFromTag(_ values: NSSet)

}

// MARK: Generated accessors for alarm
extension ManagedGot {

    @objc(addAlarmObject:)
    @NSManaged public func addToAlarm(_ value: ManagedAlarm)

    @objc(removeAlarmObject:)
    @NSManaged public func removeFromAlarm(_ value: ManagedAlarm)

    @objc(addAlarm:)
    @NSManaged public func addToAlarm(_ values: NSSet)

    @objc(removeAlarm:)
    @NSManaged public func removeFromAlarm(_ values: NSSet)

}
