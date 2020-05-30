//
//  Got.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData

struct Got: Equatable {
   
    var id: String?
    var createdDate: Date?
    var title: String?
    var latitude: Double?
    var longitude: Double?
    var radius: Double?
    var place: String?
    var arriveMsg: String?
    var deparetureMsg: String?
    var insertedDate: Date?
    var onArrive: Bool
    var onDeparture: Bool
    var onDate: Bool
    var tag : [Tag]?
    var isDone: Bool
    // ManagedGot을 가져오기 위한
    var objectId: NSManagedObjectID?
    
    init(
        id: String?,
        createdDate: Date? = Date(),
        title: String?,
        latitude: Double,
        longitude: Double?,
        radius: Double? = 100,
        place: String?,
        arriveMsg: String? = "",
        deparetureMsg: String? = "",
        insertedDate: Date?,
        onArrive: Bool = true,
        onDeparture: Bool = false,
        onDate: Bool = false,
        tag: [Tag]?,
        isDone: Bool = false
    ) {
        self.id = id
        self.createdDate = createdDate
        self.title = title ?? ""
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.place = place
        self.arriveMsg = arriveMsg
        self.deparetureMsg = deparetureMsg
        self.insertedDate = insertedDate
        self.onArrive = onArrive
        self.onDeparture = onDeparture
        self.onDate = onDate
        self.tag = tag
        self.isDone = isDone
        
    }
    
	
    
    //타이틀만 바꿀 때
    init(original: Got, updatedTitle: String){
        self = original
        self.title = updatedTitle
    }
}

func ==(lhs: Got, rhs: Got) -> Bool{
    return lhs.id == rhs.id
        && lhs.tag == rhs.tag
        && lhs.title == rhs.title
        && lhs.latitude == rhs.latitude
        && lhs.longitude == rhs.longitude
        && lhs.isDone == rhs.isDone
        && lhs.place == rhs.place
        && lhs.insertedDate == rhs.insertedDate
}
