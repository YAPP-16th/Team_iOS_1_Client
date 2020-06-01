//
//  Frequents.swift
//  GotGam
//
//  Created by 김삼복 on 23/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

enum IconType: Int16 {
	case home = 0
	case office
	case school
	case other

	var image: UIImage {
		switch self {
			case .home:
				return UIImage(named: "icFrequentsHome")!
			case .office:
				return UIImage(named: "icFrequentsOffice")!
			case .school:
				return UIImage(named: "icFrequentsSchool")!
			case .other:
				return UIImage(named: "icFrequentsOther")!
		}
	}
}

struct Frequent: Equatable {
	var name: String
    var address: String
    var latitude: Double
    var longitude: Double
	var type: IconType
	var id: String
	
	init(
		name: String,
		address: String,
		latitude: Double,
		longitude: Double,
		type: IconType,
		id: String
	) {
		self.name = name
		self.address = address
		self.latitude = latitude
		self.longitude = longitude
		self.type = type
		self.id = id
	}
}
