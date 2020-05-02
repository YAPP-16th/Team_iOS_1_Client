//
//  Tag+CoreDataProperties.swift
//  GotGam
//
//  Created by 김삼복 on 02/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedTag> {
        return NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
    }

    @NSManaged public var color: String?
    @NSManaged public var name: String?

}
