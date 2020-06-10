//
//  ManagedGot+CoreDataClass.swift
//  GotGam
//
//  Created by 손병근 on 2020/06/01.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedGot)
public class ManagedGot: NSManagedObject {
  func toGot() -> Got{
    var got =  Got.init(
        id: id,
        createdDate: createdDate,
        title: title,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        place: place,
        arriveMsg: arriveMsg,
        deparetureMsg: departureMsg,
        insertedDate: insertedDate,
        onArrive: onArrive,
        onDeparture: onDeparture,
        onDate: onDate,
        tag: tag?.toTag(),
        isDone: isDone,
        readyArrive: readyArrive,
        readyDeparture: readyDeparture)
    
    got.objectId = objectID
    got.objectIDString = objectIDString
    return got
  }
  
  func fromGot(got: Got){
    if let objectId = got.tag?.objectId, let managedTag = self.managedObjectContext?.object(with: objectId) as? ManagedTag{
        managedTag.fromTag(tag: got.tag!)
        self.tag = managedTag
    } else {
        self.tag = nil
    }
    self.id = got.id
    self.createdDate = got.createdDate
    self.title = got.title
    self.latitude = got.latitude
    self.longitude = got.longitude
    self.radius = got.radius
    self.isDone = got.isDone
    self.place = got.place
    self.insertedDate = got.insertedDate
    self.arriveMsg = got.arriveMsg
    self.departureMsg = got.deparetureMsg
    self.onArrive = got.onArrive
    self.onDeparture = got.onDeparture
    self.onDate = got.onDate
    self.readyArrive = got.readyArrive
    self.readyDeparture = got.readyDeparture
    //self.objectIDString = objectID.uriRepresentation().absoluteString
//    AlarmManager.shared.setLocationTrigger(got: self)
  }
}

extension ManagedGot {
    var arriveID: String {
        guard let objectIDString = objectIDString else {
            print("😢 Not Found objectIDString")
            return ""
        }
        return id == "" ? "\(objectIDString)_arrive" : "\(id)_arrive"
    }
    
    var departureID: String {
        guard let objectIDString = objectIDString else {
            print("😢 Not Found objectIDString")
            return ""
        }
        return id == "" ? "\(objectIDString)_departure" : "\(id)_departure"
    }
    
    var dateID: String {
        guard let objectIDString = objectIDString else {
            print("😢 Not Found objectIDString")
            return ""
        }
        return id == "" ? "\(objectIDString)_date" : "\(id)_date"
    }
    
    var requestIDs: [String] {
        return [arriveID, departureID, dateID]
    }
    
//    var objectIDString: String {
//        return objectID.uriRepresentation().absoluteString
//    }
}
