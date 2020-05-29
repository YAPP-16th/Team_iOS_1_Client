//
//  ManagedFrequents+CoreDataProperties.swift
//  GotGam
//
//  Created by 김삼복 on 26/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData

extension ManagedFrequents {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFrequents> {
        return NSFetchRequest<ManagedFrequents>(entityName: "ManagedFrequents")
    }

    @NSManaged public var address: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String
	@NSManaged public var type: Int16
}
