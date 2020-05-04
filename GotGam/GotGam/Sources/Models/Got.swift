//
//  Got.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreLocation
struct Got: Equatable{
    
    var id: Int64?
    var title: String
    var createedDate: Date
    var dueDate: Date
    var memo : String?
    var tag : String?
    var location: CLLocationCoordinate2D
    var isFinished: Bool
    var address: String?
     
    
    init(title: String, createdDate: Date = Date(), dueDate: Date, memo: String, tag: String,
         location: CLLocationCoordinate2D, address: String){
        self.title = title
        self.createedDate = Date()
        self.dueDate = dueDate
        self.memo = memo
        self.tag = tag
        self.location = location
        self.isFinished = false
        self.address = address
    }
    
    init(id: Int64, title: String, createdDate: Date = Date(), dueDate: Date, memo: String, tag: String,
         location: CLLocationCoordinate2D, address: String){
        self.id = id
        self.title = title
        self.createedDate = Date()
        self.dueDate = dueDate
        self.memo = memo
        self.tag = tag
        self.location = location
        self.isFinished = false
        self.address = address
    }
}

func ==(lhs: Got, rhs: Got) -> Bool{
    return lhs.title == rhs.title
        && lhs.createedDate == rhs.createedDate
        && lhs.memo == rhs.memo
        && lhs.tag == rhs.tag
        && lhs.location.latitude == rhs.location.latitude
        && lhs.location.longitude == rhs.location.longitude
        && lhs.isFinished == rhs.isFinished
        && lhs.address == rhs.address
}
