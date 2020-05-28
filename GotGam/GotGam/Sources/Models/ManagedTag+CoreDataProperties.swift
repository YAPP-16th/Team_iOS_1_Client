//
//  ManagedTag+CoreDataProperties.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/14.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedTag> {
        return NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
    }
    @NSManaged public var id: String?
    @NSManaged public var hex: String
    @NSManaged public var name: String?
    @NSManaged public var got: NSSet?

}

// MARK: Generated accessors for got
extension ManagedTag {

    @objc(addGotObject:)
    @NSManaged public func addToGot(_ value: ManagedGot)

    @objc(removeGotObject:)
    @NSManaged public func removeFromGot(_ value: ManagedGot)

    @objc(addGot:)
    @NSManaged public func addToGot(_ values: NSSet?)

    @objc(removeGot:)
    @NSManaged public func removeFromGot(_ values: NSSet?)

}
