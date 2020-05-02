//
//  Gotgam+CoreDataProperties.swift
//  GotGam
//
//  Created by 김삼복 on 23/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedGot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedGot> {
        return NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
    }

    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var id: Int64
    @NSManaged public var latitude: Double
    @NSManaged public var tag: String?
    @NSManaged public var date: Date?
    @NSManaged public var longitude: Double
    @NSManaged public var isDone: Bool
	@NSManaged public var palce: String?

}
