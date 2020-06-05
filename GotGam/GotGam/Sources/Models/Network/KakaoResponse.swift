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
    var addressName: String?
    var placeName: String?
    var roadAddressName: String?
    var x: String?
    var y: String?
    var address: Address?
    var roadAddress: RoadAddress?
	
	enum CodingKeys:String, CodingKey {
		case addressName = "address_name"
		case roadAddressName = "road_address_name"
		case placeName = "place_name"
        case x, y
        case address
        case roadAddress = "road_address"
	}
}

struct Address: Codable {
    let addressName: String
    let city: String // 지역 1Depth명 - 시도
    let country: String // 지역 2Depth명 - 구 단위
    let town: String // 지역 3Depth명 - 동 단위
    let mainAddressNo: String
    let subAddressNo: String
    
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case city = "region_1depth_name"
        case country = "region_2depth_name"
        case town = "region_3depth_name"
        case mainAddressNo = "main_address_no"
        case subAddressNo = "sub_address_no"
    }
}

struct RoadAddress: Codable {
    let addressName: String
    let city: String // 지역 1Depth명 - 시도
    let country: String // 지역 2Depth명 - 구 단위
    let town: String // 지역 3Depth명 - 면 단위
    let roadName: String // 도로명
    let mainBuildingNo: String
    let subBuildingNo: String
    let buildingName: String
    
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case roadName = "road_name"
        case city = "region_1depth_name"
        case country = "region_2depth_name"
        case town = "region_3depth_name"
        case mainBuildingNo = "main_building_no"
        case subBuildingNo = "sub_building_no"
        case buildingName = "building_name"
    }
}

//address_name    String    전체 지번 주소
//region_1depth_name    String    지역 1Depth명 - 시도 단위
//region_2depth_name    String    지역 2Depth명 - 구 단위
//region_3depth_name    String    지역 3Depth명 - 동 단위
//mountain_yn    String    산 여부, "Y" 또는 "N"
//main_address_no    String    지번 주 번지
//sub_address_no    String
