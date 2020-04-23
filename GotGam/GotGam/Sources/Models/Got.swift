//
//  Got.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

struct GotGam: Equatable  {
   var title: String
   var insertDate: Date
   var createDate: Date
   var id: Int64
   var content : String
   var tag : String
   var latitude: Double
   var longitude: Double
   var isDone: Bool
    
    
   
    init(title: String, createDate: Date = Date(), content: String, tag: String,
         latitude: Double, longitude: Double, isDone: Bool){
       self.title = title
       self.insertDate = insertDate.timeIntervalSinceReferenceDate
      //수정필요
       self.id = insertData.timeIntervalSinceReferenceDate.Int64
       self.createDate = createDate
       self.content = content
       self.tag = tag
       self.latitude = latitude
       self.longitude = longitude
       self.isDone = false
   }
   
   
   init(original: GotGam, updatedContent: String){
       self = original
       self.content = updatedContent
   }
}
