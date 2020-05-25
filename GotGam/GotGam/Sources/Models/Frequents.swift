//
//  Frequents.swift
//  GotGam
//
//  Created by 김삼복 on 23/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

struct Frequent: Equatable {
	var name: String
    var address: String
    var latitude: Double
    var longitude: Double
	
	init(
		name: String,
		address: String,
		latitude: Double,
		longitude: Double
	) {
		self.name = name
		self.address = address
		self.latitude = latitude
		self.longitude = longitude
	}
}
