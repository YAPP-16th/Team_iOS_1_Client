//
//  Tag.swift
//  GotGam
//
//  Created by woong on 12/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData

struct Tag: Equatable {
    var id: String
    var name: String
    var hex: String // hex. ex) "#FFFFFF"
    //var gotList: [Got]
    // Managed object id
    var objectId: NSManagedObjectID?
    
    init(id: String = "", name: String, hex: String) {
        self.id = id
        self.name = name
        self.hex = hex
        //self.gotList = gotList
    }
}

func ==(lhs: Tag, rhs: Tag) -> Bool {
    return lhs.id == rhs.id
        && lhs.hex == rhs.hex
        && lhs.name == rhs.name
}
