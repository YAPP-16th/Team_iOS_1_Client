//
//  ManagedGot+CoreDataClass.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/12.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedGot)
public class ManagedGot: NSManagedObject {
    func toGot() -> Got{
        Got.init(
            id: id,
            tag: tag?.toTag(),
            title: title!,
            content: content,
            latitude: latitude,
            longitude: longitude,
            isDone: isDone,
            place: place,
            insertedDate: insertedDate
        )
    }
    
    func fromGot(got: Got){
        self.id = got.id!
        self.tag?.from(got.tag!)
        self.title = got.title
        self.content = got.content
        self.latitude = got.latitude!
        self.longitude = got.longitude!
        self.isDone = got.isDone
        self.place = got.place
        self.insertedDate = got.insertedDate
    }
}
