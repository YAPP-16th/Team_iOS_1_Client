//
//  Alarm.swift
//  GotGam
//
//  Created by woong on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreLocation

enum AlarmType: Int16 {
    case arrive = 0
    case departure = 1
    case share = 2
    case date = 3
    
    func getTriggerID(of got: ManagedGot) -> String {
        switch self {
        case .arrive: return got.arriveID
        case .departure: return got.departureID
        case .date: return got.dateID
        default: return ""
        }
    }
    
    func getContentBody(of got: ManagedGot) -> String {
        switch self {
        case .arrive: return got.arriveMsg ?? ""
        case .departure: return got.departureMsg ?? ""
        case .date:
            guard let date = got.insertedDate else { return "" }
            return "\(date.format("MM월 dd일"))에 가야 할 🍊이 있어요"
        default: return ""
        }
    }
    
    func getLocationTrigger(of got: ManagedGot) -> UNLocationNotificationTrigger {
        let circleRegion = CLCircularRegion(center: .init(latitude: got.latitude, longitude: got.longitude), radius: got.radius, identifier: getTriggerID(of: got))
        return UNLocationNotificationTrigger(region: circleRegion, repeats: true)
    }
    
    func getContent(of got: ManagedGot) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = got.title ?? "곳감"
        content.body = self.getContentBody(of: got)
        content.sound = .default
        
        return content
    }
}

struct Alarm: Equatable {
    var id: Int64
    var type: AlarmType
    var createdDate: Date?
    var isChecked: Bool
    var checkedDate: Date?
    var got: Got?
    
    init(
        id: Int64,
        type: AlarmType,
        createdDate: Date? = Date(),
        checkedDate: Date? = nil,
        isChecked: Bool = false,
        got: Got?
    ) {
        self.id = id
        self.type = type
        self.createdDate = createdDate
        self.checkedDate = checkedDate
        self.isChecked = isChecked
        self.got = got
    }
}
