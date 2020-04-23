//
//  Gotgam+CoreDataProperties.swift
//  
//
//  Created by 김삼복 on 23/04/2020.
//
//

import Foundation
import CoreData


extension Gotgam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gotgam> {
        return NSFetchRequest<Gotgam>(entityName: "Gotgam")
    }

    @NSManaged public var content: String?
    @NSManaged public var insertdate: Date?
    @NSManaged public var id: Int64
    @NSManaged public var isDone: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var tag: String?
    @NSManaged public var title: String?
    @NSManaged public var createdate: Date?

}
