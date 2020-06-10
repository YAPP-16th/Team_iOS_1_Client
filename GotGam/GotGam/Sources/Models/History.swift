//
//  History.swift
//  GotGam
//
//  Created by 김삼복 on 10/06/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData

struct History: Equatable {
    var keyword: String
    var objectId: NSManagedObjectID?
    
    init(keyword: String) {
        self.keyword = keyword
    }
}

func ==(lhs: History, rhs: History) -> Bool {
    return lhs.keyword == rhs.keyword
}
