//
//  ManagedGot+CoreDataProperties.swift
//  
//
//  Created by 손병근 on 2020/05/04.
//
//

import Foundation
import CoreData


extension ManagedGot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedGot> {
        return NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
    }

    @NSManaged public var memo: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var id: Int64
    @NSManaged public var dueDate: Date?
    @NSManaged public var isFinished: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var tag: String?
    @NSManaged public var title: String?
    @NSManaged public var address: String?

}
