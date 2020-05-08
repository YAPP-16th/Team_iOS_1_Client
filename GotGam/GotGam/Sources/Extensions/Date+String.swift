//
//  Date+String.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

extension Date {
    // 이름.........
    var endTime: String {
        let df = DateFormatter()
        df.locale = .init(identifier: "ko-KR")
        df.dateFormat = "yyyy.MM.dd.E"
        return df.string(from: self)
    }
}


