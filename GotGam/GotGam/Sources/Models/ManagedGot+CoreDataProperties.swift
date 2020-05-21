//
//  ManagedGot+CoreDataProperties.swift
//  GotGam
//
//  Created by woong on 21/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedGot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedGot> {
        return NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
    }

    @NSManaged public var id: Int64
    @NSManaged public var insertedDate: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var place: String?
    @NSManaged public var radius: Double
    @NSManaged public var title: String?
    @NSManaged public var arriveMsg: String?
    @NSManaged public var departureMsg: String?
    @NSManaged public var onArrive: Bool
    @NSManaged public var onDeparture: Bool
    @NSManaged public var createdDate: Date?
    @NSManaged public var onDate: Bool
    @NSManaged public var alarms: NSSet?
    @NSManaged public var tag: NSSet?

}

// MARK: Generated accessors for alarms
extension ManagedGot {

    @objc(addAlarmsObject:)
    @NSManaged public func addToAlarms(_ value: ManagedAlarm)

    @objc(removeAlarmsObject:)
    @NSManaged public func removeFromAlarms(_ value: ManagedAlarm)

    @objc(addAlarms:)
    @NSManaged public func addToAlarms(_ values: NSSet)

    @objc(removeAlarms:)
    @NSManaged public func removeFromAlarms(_ values: NSSet)

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
