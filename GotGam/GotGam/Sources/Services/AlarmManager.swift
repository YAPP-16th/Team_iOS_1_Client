//
//  AlarmManager.swift
//  GotGam
//
//  Created by woong on 26/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation
import UserNotifications

class AlarmManager {
    static let shared = AlarmManager()
    private init() {}
    
    var disposeBag = DisposeBag()
    let gotStorage = GotStorage()
    let alarmStorage = AlarmStorage()
    private let departureKey = "listForDeparuture"
    //var departureGots = [Got]()
    
    func createAlarm(from current: CLLocation) {
        
        // TODO: 아이디 값이 managedObject의 id를 사용할거면 바꾸기
        if let departureGotIds = UserDefaults.standard.array(forKey: departureKey) as? [String] {
            let managedDepartureGots = departureGotIds.compactMap({Int64($0)}).compactMap { DBManager.share.fetchGot(id: $0) }
            let departureGots = managedDepartureGots.map {$0.toGot()}
            
            var remainDepartureIds = [String]()
            
            for i in 0..<departureGots.count {
                let got = departureGots[i]
                if !isInRange(got: got, from: current) {
                    createAlarm(got: got, type: .departure)
                } else {
                    guard let id = got.id else { return }
                    remainDepartureIds.append(String(id))
                }
            }
            UserDefaults.standard.set(remainDepartureIds, forKey: departureKey)
        }

        gotStorage.fetchGotList()
            .map{ self.findInRange(gotList: $0, from: current) }
            .subscribe(onNext: { [weak self] gotList in
                for got in gotList {
                    if got.onArrive {
                        self?.createAlarm(got: got, type: .arrive)
                    }
                    if got.onDeparture {
                        guard
                            let self = self,
                            let id = got.id
                        else { return }
                        
                        if var departureGotIds = UserDefaults.standard.array(forKey: self.departureKey) as? [String] {
                            departureGotIds.append(String(id))
                            UserDefaults.standard.set(departureGotIds, forKey: self.departureKey)
                        } else {
                            let departureGotIds = [String(id)]
                            UserDefaults.standard.set(departureGotIds, forKey: self.departureKey)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func createAlarm(got: Got, type: AlarmType) {
        print("create Alarm: \(got), \(type)")
        let alarm = Alarm(id: Int64(arc4random()), type: type, got: got)
        alarmStorage.createAlarm(alarm)
        
        // TODO: 타입설정
        pushNotification(got: got, type: type)
    }
    
    func pushNotification(got: Got, type: AlarmType) {
        let title = got.title ?? "곳감"
        
        var body = ""
        
        switch type {
        case .arrive:
            if got.onArrive { body = got.arriveMsg ?? "" }
        case .departure:
            if got.onDeparture { body = got.deparetureMsg ?? ""}
        case .share:
            body = "슬기로운 곳감생활님이 태그를 공유하셨어요?"
        case .date:
            if let date = got.insertedDate { body = "\(date.format("MM월 dd일"))에 가야 할 🍊이 있어요" }
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, err) in
            
            if granted {
                print("push auth granted")
            }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "alarm",
                                                content: content, trigger: trigger)
            
            // Schedule the request with the system.
            //let notificationCenter = UNUserNotificationCenter.current()
            center.add(request) { (error) in
                if error != nil {
                    print(error?.localizedDescription)
                    // Handle any errors.
                }
            }
        }
    }
    
    func findInRange(gotList: [Got], from target: CLLocation) -> [Got] {
        return gotList.filter { got in
            guard let gotLat = got.latitude, let gotLong = got.longitude, let radius = got.radius else {return false}
            let gotLocation = CLLocation.init(latitude: gotLat, longitude: gotLong)
            
            
            if gotLocation.distance(from: target) <= radius {
                return true
            }
            return false
        }
    }
    
    func isInRange(got: Got, from target: CLLocation) -> Bool {
        guard let gotLat = got.latitude, let gotLong = got.longitude, let radius = got.radius else {return false}
        let gotLocation = CLLocation.init(latitude: gotLat, longitude: gotLong)
        if gotLocation.distance(from: target) <= radius {
            return true
        }
        return false
    }
}
