//
//  Tag.swift
//  GotGam
//
//  Created by woong on 12/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

struct Tag: Equatable {
    var name: String
    var hex: String // hex. ex) "#FFFFFF"
    //var gotList: [Got]
    
    init(name: String, hex: String) {
        self.name = name
        self.hex = hex
        //self.gotList = gotList
    }
}

func ==(lhs: Tag, rhs: Tag) -> Bool {
    return lhs.hex == rhs.hex
}
