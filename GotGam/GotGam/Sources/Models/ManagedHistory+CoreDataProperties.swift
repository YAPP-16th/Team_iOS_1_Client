//
//  ManagedHistory+CoreDataProperties.swift
//  GotGam
//
//  Created by 김삼복 on 10/06/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedHistory> {
        return NSFetchRequest<ManagedHistory>(entityName: "ManagedHistory")
    }

    @NSManaged public var keyword: String

}
