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
    
    func createLocationTrigger(got: ManagedGot) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, err) in
            
            if granted {
                print("push auth granted")
            }
            
            let arriveContent = UNMutableNotificationContent()
            arriveContent.title = got.title!
            arriveContent.body = got.arriveMsg ?? ""
            arriveContent.sound = .default
            let arriveId = got.id == "" ? "\(got.objectID)_arrive" : "\(got.id!)_arrive"
            let arriveRegion = CLCircularRegion(center: .init(latitude: got.latitude, longitude: got.longitude), radius: got.radius, identifier: arriveId)
            arriveRegion.notifyOnEntry = true
            arriveRegion.notifyOnExit = false
            let arriveTrigger = UNLocationNotificationTrigger(region: arriveRegion, repeats: true)
            let arriveRequest = UNNotificationRequest(identifier: arriveId, content: arriveContent, trigger: arriveTrigger)
            
            center.add(arriveRequest) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                print("✅ Success add arrive request")
            }
            
            let departureContent = UNMutableNotificationContent()
            departureContent.title = got.title!
            departureContent.body = got.departureMsg ?? ""
            departureContent.sound = .default
            let departureId = got.id == "" ? "\(got.objectID)_departure" : "\(got.id!)_departure"
            let departureRegion = CLCircularRegion(center: .init(latitude: got.latitude, longitude: got.longitude), radius: got.radius, identifier: departureId)
            departureRegion.notifyOnEntry = false
            departureRegion.notifyOnExit = true
            let departureTrigger = UNLocationNotificationTrigger(region: departureRegion, repeats: true)
            let departureRequest = UNNotificationRequest(identifier: departureId, content: departureContent, trigger: departureTrigger)
            center.add(departureRequest) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                    // Handle any errors.
                }
                print("✅ Success add departure request")
            }
        }
    }
    
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
