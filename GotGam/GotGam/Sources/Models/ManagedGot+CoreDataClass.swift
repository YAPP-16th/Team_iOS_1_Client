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
    
      return Got.init(
          id: id,
          tag: tags,
          title: title!,
          content: content,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          isDone: isDone,
          place: place,
          insertedDate: insertedDate
      )
  }
  
  func fromGot(got: Got){
    var managedTags = [ManagedTag]()
    if let tags = got.tag, let context = self.managedObjectContext{
      for tag in tags{
        let managedTag = ManagedTag(context: context)
        managedTag.fromTag(tag: tag)
        managedTags.append(managedTag)
      }
    }
      self.id = got.id!
      self.tag = NSSet.init(array: managedTags)
      self.title = got.title
      self.content = got.content
      self.latitude = got.latitude!
      self.longitude = got.longitude!
      self.radius = got.radius!
      self.isDone = got.isDone
      self.place = got.place
      self.insertedDate = got.insertedDate
  }
}
