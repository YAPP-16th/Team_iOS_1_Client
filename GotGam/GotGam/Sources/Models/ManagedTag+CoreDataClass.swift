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
  func toTag() -> Tag{
      .init(name: name!, hex: hex!)
  }
  
  func fromTag(tag: Tag) {
      self.name = tag.name
      self.hex = tag.hex
  }
}
