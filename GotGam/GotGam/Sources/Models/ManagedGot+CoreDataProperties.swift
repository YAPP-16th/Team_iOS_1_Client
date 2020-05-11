//
//  ManagedGot+CoreDataProperties.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/12.
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
    @NSManaged public var place: String?
    @NSManaged public var title: String?
    @NSManaged public var tag: ManagedTag?

}
