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
        return .init(
			name: name,
			address: address,
			latitude: latitude,
			longitude: longitude
        )
    }
}
