//
//  Alarm.swift
//  GotGam
//
//  Created by woong on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

struct Alarm: Equatable {
    var id: Int64
    var createdDate: Date?
    var isChecked: Bool
    var checkedDate: Date?
    var got: Got?
    
    init(id: Int64, createdDate: Date? = Date(), checkedDate: Date?, isChecked: Bool = false, got: Got?) {
        self.id = id
        self.createdDate = createdDate
        self.checkedDate = checkedDate
        self.isChecked = isChecked
        self.got = got
    }
}
