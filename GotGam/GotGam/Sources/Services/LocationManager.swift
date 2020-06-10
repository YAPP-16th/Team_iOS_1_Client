//
//  LocationManager.swift
//  GotGam
//
//  Created by byeonggeunSon on 2020/04/04.
//  Copyright © 2020 손병근. All rights reserved.
//

import CoreLocation
import UIKit
@objc protocol LocationManagerDelegate: class{
    func locationAuthenticationChanged(location: CLAuthorizationStatus)
    @objc optional func locationUpdated(coordinate: CLLocationCoordinate2D)
}

class LocationManager: NSObject, LocationManagerType{
    
    static let shared = LocationManager()
    private let manager: CLLocationManager
    weak var delegate: LocationManagerDelegate?
    
    private override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    
    deinit {
        print("deinit", #function)
    }
    
    // MARK: - Properties
    
    var currentLocation: CLLocationCoordinate2D?
    var settingLocationURL: URL? {
        guard let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") else { return nil }
        return url
    }
    var locationServicesEnabled: Bool {
      return CLLocationManager.locationServicesEnabled()
    }
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Methods
    
    func updateLocation() {
//        #if targetEnvironment(simulator)
//           // Simulator
//        #else
//            manager.requestLocation()
//           // Device
//        #endif
        
        if TARGET_IPHONE_SIMULATOR == 1 {
            
        } else if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            print("updated location")
            DispatchQueue.main.async {
                self.manager.requestLocation()
            }
        }
    }
    
    func requestAuthorization(){
        manager.requestWhenInUseAuthorization()
    }
    
    func startMonitoringSignificantLocationChanges() {
      print("locationManager startMonitoringSignificantLocationChanges")
      manager.startMonitoringSignificantLocationChanges()
    }
    
    func startMonitoringVisit() {
        print("start Monitoring visits")
        manager.startMonitoringVisits()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    // MARK: CLLocationManager Delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.delegate?.locationAuthenticationChanged(location: status)
        authorizationStatus = status
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("😢 Stop Location Service, \(error) ")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else {
            //self.delegate?.locationUpdated?(coordinate: coordinate)
            return
        }
        
        let center = UNUserNotificationCenter.current()
        //center.removeAllDeliveredNotifications()
        //center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "위치 업데이트"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(identifier: "1", content: content, trigger: trigger)
        center.add(req) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        print("‼️ monitored regions, \(manager.monitoredRegions)")
        
        currentLocation = latestLocation.coordinate
        let inRangeGots = findNearestGot(from: latestLocation)
        
        for monitoredRegion in manager.monitoredRegions {
            if !inRangeGots.contains(where: { $0.objectIDString == monitoredRegion.identifier }) {
                manager.stopMonitoring(for: monitoredRegion)
            }
        }
        
        for got in inRangeGots {
            print("got(\(got.title)) is in range \(String(describing: got.objectIDString)) 👍")
            guard let id = got.objectIDString else { continue }
            
            let circle = CLCircularRegion(center: .init(latitude: got.latitude, longitude: got.longitude), radius: got.radius, identifier: id)
            circle.notifyOnEntry = true
            circle.notifyOnExit = true
            
            center.removePendingNotificationRequests(withIdentifiers: [got.departureID, got.arriveID])
            /*
                Document:
                If an existing region with the same identifier is already being monitored by the app, the old region is replaced by the new one.
                같은 id면 새로운 region으로 덮어씌워진다고 하니 그냥 계속 모니터링 함
             */
            manager.startMonitoring(for: circle)
//            if !manager.monitoredRegions.contains(circle) {
//                print("🤩 start monitoring region: \(circle)")
//                manager.startMonitoring(for: circle)
//            } else {
//                print("☠️ already contained region: \(circle)")
//            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("😡 exit region \(region)")
        if let region = region as? CLCircularRegion {
            guard let got = DBManager.share.fetchGot(objectIDString: region.identifier) else {
                print("⁉️ Not Found got")
                manager.stopMonitoring(for: region)
                return
            }
            guard !got.isDone, got.onDeparture else { return }
            
            if let curr = manager.location, isInRange(got: got, from: curr) {
                return
            }
            
            let unCenter = UNUserNotificationCenter.current()
            unCenter.getPendingNotificationRequests { (request) in
                print("🧨 pending Request: \(request)")
            }
            unCenter.removePendingNotificationRequests(withIdentifiers: [got.departureID, got.arriveID])
            let content = UNMutableNotificationContent()
            let type = AlarmType.departure
            content.title = type.contentTitle(of: got)
            content.body = type.contentBody(of: got)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let req = UNNotificationRequest(identifier: got.departureID, content: content, trigger: trigger)
            
//            unCenter.getDeliveredNotifications { (notifications) in
//                guard !notifications.contains(where: { $0.request.identifier == got.departureID}) else {
//                    return
//                }
//                unCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
//                    if let error = error {
//                        print("🚨 Auth Error, \(error.localizedDescription)")
//                    }
//                    if !granted {
//                        print("🚨 Notification Not granted")
//                    }
//                    unCenter.add(req) { (error) in
//                        if let error = error {
//                            print("🚨 Request Error, \(error.localizedDescription)")
//                        }
//                        AlarmManager.shared.createAlarm(for: got, type: .departure)
//                    }
//                }
//            }
            
            unCenter.getPendingNotificationRequests { (requets) in
                if !requets.isEmpty, requets.contains(where: { $0.identifier == got.departureID }) {
                    return
                }
                
                unCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                    if let error = error {
                        print("🚨 Auth Error, \(error.localizedDescription)")
                    }
                    if !granted {
                        print("🚨 Notification Not granted")
                    }
                    unCenter.add(req) { (error) in
                        if let error = error {
                            print("🚨 Request Error, \(error.localizedDescription)")
                        }
                        AlarmManager.shared.createAlarm(for: got, type: .departure)
                    }
                }
            }
            
//            unCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
//                if let error = error {
//                    print("🚨 Auth Error, \(error.localizedDescription)")
//                }
//                if !granted {
//                    print("🚨 Notification Not granted")
//                }
//                unCenter.add(req) { (error) in
//                    if let error = error {
//                        print("🚨 Request Error, \(error.localizedDescription)")
//                    }
//                    AlarmManager.shared.createAlarm(for: got, type: .departure)
//                }
//            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("😡 enter region \(region)")
        if let region = region as? CLCircularRegion {
            guard let got = DBManager.share.fetchGot(objectIDString: region.identifier) else {
                print("⁉️ Not Found got")
                manager.stopMonitoring(for: region)
                return
            }
            if let curr = manager.location, !isInRange(got: got, from: curr) {
                return
            }
            guard !got.isDone, got.onArrive else { return }
            let unCenter = UNUserNotificationCenter.current()
            unCenter.getPendingNotificationRequests { (request) in
                print("🧨 pending Request: \(request)")
            }
            unCenter.removePendingNotificationRequests(withIdentifiers: [got.departureID, got.arriveID])
            let content = UNMutableNotificationContent()
            let type = AlarmType.arrive
            content.title = type.contentTitle(of: got)
            content.body = type.contentBody(of: got)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let req = UNNotificationRequest(identifier: got.arriveID, content: content, trigger: trigger)
            
//            unCenter.getDeliveredNotifications { (notifications) in
//                guard !notifications.contains(where: { $0.request.identifier == got.arriveID}) else {
//                    return
//                }
//                unCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
//                    if let error = error {
//                        print("🚨 Auth Error, \(error.localizedDescription)")
//                    }
//                    if !granted {
//                        print("🚨 Not granted for notification")
//                    }
//                    unCenter.add(req) { (error) in
//                        if let error = error {
//                            print("🚨 Request Error, \(error.localizedDescription)")
//                        }
//                        AlarmManager.shared.createAlarm(for: got, type: .arrive)
//                    }
//                }
//            }
            
            unCenter.getPendingNotificationRequests { (requets) in
                if !requets.isEmpty, requets.contains(where: { $0.identifier == got.arriveID }) {
                    return
                }
                unCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                    if let error = error {
                        print("🚨 Auth Error, \(error.localizedDescription)")
                    }
                    if !granted {
                        print("🚨 Not granted for notification")
                    }
                    unCenter.add(req) { (error) in
                        if let error = error {
                            print("🚨 Request Error, \(error.localizedDescription)")
                        }
                        AlarmManager.shared.createAlarm(for: got, type: .arrive)
                    }
                }
            }
            
//            unCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
//                if let error = error {
//                    print("🚨 Auth Error, \(error.localizedDescription)")
//                }
//                if !granted {
//                    print("🚨 Not granted for notification")
//                }
//                unCenter.add(req) { (error) in
//                    if let error = error {
//                        print("🚨 Request Error, \(error.localizedDescription)")
//                    }
//                    AlarmManager.shared.createAlarm(for: got, type: .arrive)
//                }
//            }
        }
    }
}

extension LocationManager {
    
    // MARK: Helpers
    
    func findInRange(gotList: [ManagedGot], from target: CLLocation) -> [ManagedGot] {
        return gotList.filter { got in
                    let gotLocation = CLLocation.init(latitude: got.latitude, longitude: got.longitude)
                    if gotLocation.distance(from: target) <= got.radius {
                        return true
                    }
                    return false
                }
    }
    
    func findNearestGot(from location: CLLocation, in radius: Double = 50000) -> [ManagedGot] {
        let gotList = DBManager.share.fetch(ManagedGot.self)
        return gotList.filter { got in
            let gotLocation = CLLocation.init(latitude: got.latitude, longitude: got.longitude)
            if gotLocation.distance(from: location) <= radius {
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
    
//    func isInRange(got: ManagedGot, from target: CLCircularRegion) -> Bool {
//        let gotLocation = CLLocation.init(latitude: got.latitude, longitude: got.longitude)
//
//        if gotLocation.distance(from: .init(latitude: target.center.latitude, longitude: target.center.longitude)) <= got.radius {
//            return true
//        }
//        return false
//    }
}
