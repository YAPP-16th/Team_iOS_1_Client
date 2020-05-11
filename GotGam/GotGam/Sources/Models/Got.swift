//
//  Got.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

struct Got: Equatable {
   
    var id: Int64?
    var tag : Tag?
    var title: String?
    var content : String?
    var latitude: Double?
    var longitude: Double?
    var isDone: Bool
	var place: String?
    var insertedDate: Date?
     
    init(id: Int64?, tag: Tag?, title: String?, content: String?, latitude: Double, longitude: Double?, isDone: Bool, place: String?, insertedDate: Date?){
        self.id = id
        self.tag = tag
        self.title = title ?? ""
        self.content = content
        self.latitude = latitude
        self.longitude = longitude
        self.isDone = isDone
        self.place = place
        self.insertedDate = insertedDate
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
        && lhs.content == rhs.content
        && lhs.latitude == rhs.latitude
        && lhs.longitude == rhs.longitude
        && lhs.isDone == rhs.isDone
        && lhs.place == rhs.place
        && lhs.insertedDate == rhs.insertedDate
}
