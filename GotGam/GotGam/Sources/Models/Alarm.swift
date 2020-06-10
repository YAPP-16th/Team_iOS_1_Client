//
//  Alarm.swift
//  GotGam
//
//  Created by woong on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

struct Alarm: Equatable {
    var id: NSManagedObjectID?
    var type: AlarmType
    var createdDate: Date
    var isChecked: Bool
    var checkedDate: Date?
    var got: ManagedGot
    
    init(
        id: NSManagedObjectID? = nil,
        type: AlarmType,
        createdDate: Date = Date(),
        checkedDate: Date? = nil,
        isChecked: Bool = false,
        got: ManagedGot
    ) {
        self.id = id
        self.type = type
        self.createdDate = createdDate
        self.checkedDate = checkedDate
        self.isChecked = isChecked
        self.got = got
    }
}



@objc enum AlarmType: Int16 {
    case arrive = 0
    case departure = 1
    case share = 2
    case date = 3
    
    func triggerID(of got: ManagedGot) -> String {
        switch self {
        case .arrive: return got.arriveID
        case .departure: return got.departureID
        case .date: return got.dateID
        default: return ""
        }
    }
    
    func contentTitle(of got: ManagedGot) -> String {
        switch self {
        case .arrive: return "근처에 '\(got.title)'(이)가 있습니다."
        case .departure: return "'\(got.title)'(을)를 떠났습니다."
        case .date: return "\(got.title) 방문 날짜가 되었습니다."
        default: return ""
        }
    }
    
    func contentBody(of got: ManagedGot) -> String {
        switch self {
        case .arrive:
            if got.arriveMsg == "" { return "" }
            var content = "'\(got.arriveMsg)'(이)라고 메모했습니다."
            if let date = got.insertedDate { content += "\n\(date.format("yyyy.MM.dd"))까지 꼭 방문해야 합니다."}
            return content
        case .departure:
            if got.departureMsg == "" { return "" }
            var content = "'\(got.departureMsg)'(이)라고 메모했습니다."
            if let date = got.insertedDate { content += "\n\(date.format("yyyy.MM.dd"))까지 꼭 방문해야 합니다."}
            return content
        case .date:
            guard let date = got.insertedDate else { return "" }
            return "\(date.format("MM월 dd일"))에 가야 할 🍊이 있어요"
        default: return ""
        }
    }
    
    
    func locationTrigger(of got: ManagedGot) -> UNLocationNotificationTrigger {
        
        let circleRegion = CLCircularRegion(center: .init(latitude: got.latitude, longitude: got.longitude), radius: got.radius, identifier: triggerID(of: got))
        
        
        switch self {
        case .arrive:
            circleRegion.notifyOnEntry = true
            circleRegion.notifyOnExit = false
        case .departure:
            circleRegion.notifyOnEntry = false
            circleRegion.notifyOnExit = true
        default: break
        }
        return UNLocationNotificationTrigger(region: circleRegion, repeats: true)
    }
    
    func circleRegion(of got: ManagedGot) -> CLCircularRegion {
        let circleRegion = CLCircularRegion(center: .init(latitude: got.latitude, longitude: got.longitude), radius: got.radius, identifier: triggerID(of: got))
        
        
        switch self {
        case .arrive:
            circleRegion.notifyOnEntry = true
            circleRegion.notifyOnExit = false
        case .departure:
            circleRegion.notifyOnEntry = false
            circleRegion.notifyOnExit = true
        default: break
        }
        return circleRegion
    }
    
    func content(of got: ManagedGot) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = contentTitle(of: got)
        content.body = contentBody(of: got)
        content.sound = .default
        
        return content
    }
}

