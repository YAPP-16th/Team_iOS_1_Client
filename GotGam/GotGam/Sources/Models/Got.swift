//
//  Got.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

struct Got : Equatable{
   
    var title: String
    var insertedDate: Date?
    var createedDate: Date
    var id: Int64?
    var content : String?
    var tag : String?
    var latitude: Double?
    var longitude: Double?
    var isDone: Bool
     
     
    
	init(title: String, id: Int64, createedDate: Date = Date(), content: String, tag: String,
          latitude: Double, longitude: Double, isDone: Bool){
        self.title = title
        //수정필요
        self.insertedDate = nil
        self.id = id
      
        self.createedDate = Date()
        self.content = content
        self.tag = tag
        self.latitude = latitude
        self.longitude = longitude
        self.isDone = false
    }
    
    init(title: String, latitude: Double, longitude: Double, isDone: Bool){
        self.title = title
        self.insertedDate = nil
        self.id = nil
        self.createedDate = Date()
        self.content = nil
        self.tag = nil
        self.latitude = latitude
        self.longitude = longitude
        self.isDone = false
    }
   
   init(title: String){
          self.title = title
          self.insertedDate = nil
          self.id = nil
          self.createedDate = Date()
          self.content = nil
          self.tag = nil
          self.latitude = nil
          self.longitude = nil
          self.isDone = false
      }
    
    
    //타이틀만 바꿀 때
    init(original: Got, updatedTitle: String){
        self = original
        self.title = updatedTitle
    }
}
