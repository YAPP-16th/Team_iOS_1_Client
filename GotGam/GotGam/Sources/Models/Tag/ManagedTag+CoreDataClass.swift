//
//  ManagedTag+CoreDataClass.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/14.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedTag)
public class ManagedTag: NSManagedObject {
  func toTag() -> Tag {
    var tag = Tag(id: id, name: name, hex: hex)
    tag.objectId = objectID
    return tag
  }
  
  func fromTag(tag: Tag) {
    self.id = tag.id
    self.name = tag.name
    self.hex = tag.hex
  }
}
