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
    
    func setLocationTrigger(got: ManagedGot) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (granted, err) in
            guard let self = self else {return}
            if granted {
                print("push auth granted")
            }
            
            if got.isDone {
                self.removeAllNotification(of: got)
            } else {
                self.pushNotification(got: got, type: .arrive)
                self.pushNotification(got: got, type: .departure)
                // TODO: Date, Share alarm
            }
            
            
        }
    }
    
    func createAlarm(from current: CLLocation) {
        print("in \(current.coordinate)")
        let gotList = DBManager.share.fetch(ManagedGot.self)
        //let inRangeGotList = findInRange(gotList: gotList, from: current)
        
        for got in gotList {
            // arrive는 범위 밖으로 나가면 ready
            // departure는 범위 안으로 들어오면 readay
            if got.onArrive {
                if isInRange(got: got, from: current) {
                    if got.readyArrive {
                        createAlarm(got: got, type: .arrive)
                        got.readyArrive = false
                    }
                } else {
                    if !got.readyArrive {
                        got.readyArrive = true
                    }
                }
            } else {
                removeNotification(ofGot: got, type: .arrive)
            }
            
            if got.onDeparture {
                if isInRange(got: got, from: current) {
                    if !got.readyDeparture {
                        got.readyDeparture = true
                    }
                } else {
                    if got.readyDeparture {
                        createAlarm(got: got, type: .departure)
                        got.readyDeparture = false
                    }
                }
            } else {
                removeNotification(ofGot: got, type: .departure)
            }
        }

//        // TODO: 아이디 값이 managedObject의 id를 사용할거면 바꾸기
//        if let departureGotIds = UserDefaults.standard.array(forKey: departureKey) as? [String] {
//            let managedDepartureGots = departureGotIds.compactMap({Int64($0)}).compactMap { DBManager.share.fetchGot(id: $0) }
//            let departureGots = managedDepartureGots.map {$0.toGot()}
//
//            var remainDepartureIds = [String]()
//
//            for i in 0..<departureGots.count {
//                let got = departureGots[i]
//                if !isInRange(got: got, from: current) {
//                    createAlarm(got: got, type: .departure)
//                } else {
//                    guard let id = got.id else { return }
//                    remainDepartureIds.append(String(id))
//                }
//            }
//            UserDefaults.standard.set(remainDepartureIds, forKey: departureKey)
//        }

//        gotStorage.fetchGotList()
//            .map{ self.findInRange(gotList: $0, from: current) }
//            .subscribe(onNext: { [weak self] gotList in
//                for got in gotList {
//                    if got.onArrive {
//                        self?.createAlarm(got: got, type: .arrive)
//                    }
//                    if got.onDeparture {
//                        guard
//                            let self = self,
//                            let id = got.id
//                        else { return }
//
//                        if var departureGotIds = UserDefaults.standard.array(forKey: self.departureKey) as? [String] {
//                            departureGotIds.append(String(id))
//                            UserDefaults.standard.set(departureGotIds, forKey: self.departureKey)
//                        } else {
//                            let departureGotIds = [String(id)]
//                            UserDefaults.standard.set(departureGotIds, forKey: self.departureKey)
//                        }
//                    }
//                }
//            })
//            .disposed(by: disposeBag)
    }

    func createAlarm(got: ManagedGot, type: AlarmType) {
        
        let alarm = Alarm(type: type, got: got.toGot())
        print("create Alarm: \(alarm)")
        alarmStorage.createAlarm(alarm)

        // TODO: 타입설정
        //pushNotification(got: got, type: type)
    }
    
    func pushNotification(got: ManagedGot, type: AlarmType) {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, err) in
            if granted {
                print("push auth granted")
            }
            let triggerID = type.getTriggerID(of: got)
            let content = type.getContent(of: got)
            let trigger = type.getLocationTrigger(of: got)
            let request = UNNotificationRequest(identifier: triggerID,
                                                content: content, trigger: trigger)
            
            switch type {
            case .arrive:
                if got.onArrive {
                    center.add(request) { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        print("✅ Success arrive notification request")
                    }
                } else {
                    center.removePendingNotificationRequests(withIdentifiers: [triggerID])
                    print("✅ Remove arrive PendingNotificationRequests id: \(trigger)")
                }
            case .departure:
                if got.onDeparture {
                    center.add(request) { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        print("✅ Success departure notification request")
                    }
                } else {
                    center.removePendingNotificationRequests(withIdentifiers: [triggerID])
                    print("✅ Remove departure PendingNotificationRequests id: \(trigger)")
                }
            default: return
            }
        }
    }
    
    func removeAllNotification(of got: ManagedGot) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, err) in
            if granted {
                print("push auth granted")
            }

            center.removePendingNotificationRequests(withIdentifiers: got.requestIds)
            print("✅ remove All PendingNotificationRequets of \(got.requestIds)")
        }
    }
    
    func removeNotification(ofGot got: ManagedGot, type: AlarmType) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, err) in
            if granted {
                print("push auth granted")
            }
            
            center.removePendingNotificationRequests(withIdentifiers: [type.getTriggerID(of: got)])
            print("✅ remove PendingNotificationRequets of \(type.getTriggerID(of: got))")
        }
    }
    
    func findInRange(gotList: [ManagedGot], from target: CLLocation) -> [ManagedGot] {
        return gotList.filter { got in
                    let gotLocation = CLLocation.init(latitude: got.latitude, longitude: got.longitude)
                    if gotLocation.distance(from: target) <= got.radius {
                        return true
                    }
                    return false
                }
    }
    
    func isInRange(got: ManagedGot, from target: CLLocation) -> Bool {
        let gotLocation = CLLocation.init(latitude: got.latitude, longitude: got.longitude)
        if gotLocation.distance(from: target) <= got.radius {
            return true
        }
        return false
    }
}
