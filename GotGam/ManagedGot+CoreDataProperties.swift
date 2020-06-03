//
//  ManagedGot+CoreDataProperties.swift
//  GotGam
//
//  Created by 손병근 on 2020/06/01.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedGot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedGot> {
        return NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
    }

    @NSManaged public var arriveMsg: String
    @NSManaged public var createdDate: Date
    @NSManaged public var departureMsg: String
    @NSManaged public var id: String
    @NSManaged public var insertedDate: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var onArrive: Bool
    @NSManaged public var onDate: Bool
    @NSManaged public var onDeparture: Bool
    @NSManaged public var place: String
    @NSManaged public var radius: Double
    @NSManaged public var title: String
    @NSManaged public var alarms: NSSet
    @NSManaged public var tag: ManagedTag?

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
