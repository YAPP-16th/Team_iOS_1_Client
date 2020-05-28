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
//    var gotList = [Got]()
//    if let managedGotList = self.got?.allObjects as? [ManagedGot] {
//        for got in managedGotList {
//            print(got)
//            gotList.append(got.toGot())
//        }
//    }
    var tag = Tag(id: id ?? "", name: name ?? "", hex: hex)
    tag.objectId = objectID
    return tag
//      .init(name: name!, hex: hex!, gotList: got)
    
  }
  
  func fromTag(tag: Tag) {
    
//    var managedGotList = [ManagedGot]()
//    if let context = self.managedObjectContext {
//        let gotList = tag.gotList
//        for got in gotList {
//            let managedGot = ManagedGot(context: context)
//            managedGot.fromGot(got: got)
//            managedGotList.append(managedGot)
//        }
//    }
    
    self.id = tag.id
    self.name = tag.name
    self.hex = tag.hex
    //self.got = NSSet.init(array: managedGotList)
  }
}
