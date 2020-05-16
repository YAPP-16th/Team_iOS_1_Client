//
//  ManagedTag+CoreDataProperties.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/12.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedTag> {
        return NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
    }

    @NSManaged public var hex: String
    @NSManaged public var name: String?
}
