//
//  KakaoResponse.swift
//  GotGam
//
//  Created by 김삼복 on 16/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

struct KakaoResponse:Codable {
	let documents: [Place]
}

struct Place: Codable {
	let addressName: String
	let roadAddressName, x, y: String
	
	enum CodingKeys:String, CodingKey {
		case addressName = "address_name"
		case roadAddressName = "road_address_name"
        case x, y
	}
}
