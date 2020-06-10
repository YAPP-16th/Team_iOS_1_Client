//
//  ManagedFrequents+CoreDataClass.swift
//  GotGam
//
//  Created by 김삼복 on 26/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedFrequents)
public class ManagedFrequents: NSManagedObject {
	func toFrequents() -> Frequent {
        var frequent:Frequent = .init(
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        type: IconType(rawValue: type)!,
        id: id
        )
        frequent.objectId = objectID
        return frequent
    }
	
	func fromFrequents(frequent: Frequent) {
		self.id = frequent.id
		self.name = frequent.name
		self.address = frequent.address
		self.latitude = frequent.latitude
		self.longitude = frequent.longitude
		self.type = frequent.type.rawValue
	}
}
