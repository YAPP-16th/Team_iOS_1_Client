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
    
    func format(_ format: String) -> String {
        let df = DateFormatter()
        df.locale = .init(identifier: "ko-KR")
        df.dateFormat = format
        return df.string(from: self)
    }
    
    func agoText(from fromDate: Date) -> String {
        let interval = self.timeIntervalSince(fromDate)
        let hour: Double = 60 * 60
        let today: Double = 24 * hour

        if interval < hour {
            if let minute = Calendar.current.dateComponents([.minute], from: fromDate, to: self).minute {
                return "\(minute)분 전"
            } else {
                print("🚨 이전 시간 계산을 할 수 없습니다. ")
                return ""
            }
        } else if interval <= today {
            if let hour = Calendar.current.dateComponents([.hour], from: fromDate, to: self).hour {
                return "\(hour)시간 전"
            } else {
                print("🚨 이전 시간 계산을 할 수 없습니다. ")
                return ""
            }
        } else {
            return fromDate.format("yyyy.MM.dd")
        }
    }
}


