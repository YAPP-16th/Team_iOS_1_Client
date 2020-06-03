//
//  ManagedGot+CoreDataClass.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/14.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedGot)
public class ManagedGot: NSManagedObject {
  func toGot() -> Got{
    
    var tags = [Tag]()
    if let managedTagList = self.tag?.allObjects as? [ManagedTag]{
      for managedTag in managedTagList{
        tags.append(managedTag.toTag())
      }
    }
    
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
        tag: tags,
        isDone: isDone,
        readyArrive: readyArrive,
        readyDeparture: readyDeparture)
    got.objectId = objectID
    return got
  }
  
  func fromGot(got: Got){
    
    var managedTags = [ManagedTag]()
    if let tags = got.tag {
      for tag in tags {
        if let managedTag = fetchTag(tag: tag) {
            managedTags.append(managedTag)
        }
      }
    }
     
    self.id = got.id!
    self.createdDate = got.createdDate
    self.tag = NSSet.init(array: managedTags)
    self.title = got.title
    self.latitude = got.latitude!
    self.longitude = got.longitude!
    self.radius = got.radius!
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
    
    AlarmManager.shared.setLocationTrigger(got: self)
  }
    
    func fetchTag(tag: Tag) -> ManagedTag? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedTag")
        fetchRequest.predicate = NSPredicate(format: "hex = %@", tag.hex)
        
        let context = self.managedObjectContext
        
        do {
            if let fetchedObjects = try context?.fetch(fetchRequest) as? [ManagedTag] {
                return fetchedObjects.first
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

extension ManagedGot {
    var arriveID: String {
        return id == "" ? "\(objectID)_arrive" : "\(id!)_arrive"
    }
    
    var departureID: String {
        return id == "" ? "\(objectID)_departure" : "\(id!)_departure"
    }
    
    var dateID: String {
        return id == "" ? "\(objectID)_date" : "\(id!)_date"
    }
    
    var requestIds: [String] {
        return [arriveID, departureID, dateID]
    }
}
