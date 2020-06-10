//
//  ManagedGot+CoreDataProperties.swift
//  GotGam
//
//  Created by 손병근 on 2020/06/03.
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
    @NSManaged public var readyArrive: Bool
    @NSManaged public var readyDeparture: Bool
    @NSManaged public var title: String
    @NSManaged public var tag: ManagedTag?
    @NSManaged public var objectIDString: String?
    
}
