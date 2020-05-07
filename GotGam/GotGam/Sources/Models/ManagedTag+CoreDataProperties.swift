//
//  ManagedTag+CoreDataProperties.swift
//  
//
//  Created by 김삼복 on 08/05/2020.
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
    @NSManaged public var id: Int64

}
