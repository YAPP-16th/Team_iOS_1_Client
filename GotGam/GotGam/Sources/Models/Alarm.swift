//
//  Alarm.swift
//  GotGam
//
//  Created by woong on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

enum AlarmType: Int16 {
    case arrive = 0
    case leave = 1
    case share = 2
}

struct Alarm: Equatable {
    var id: Int64
    var type: AlarmType
    var createdDate: Date?
    var isChecked: Bool
    var checkedDate: Date?
    var got: Got?
    
    init(id: Int64, type: AlarmType, createdDate: Date? = Date(), checkedDate: Date?, isChecked: Bool = false, got: Got?) {
        self.id = id
        self.type = type
        self.createdDate = createdDate
        self.checkedDate = checkedDate
        self.isChecked = isChecked
        self.got = got
    }
}
