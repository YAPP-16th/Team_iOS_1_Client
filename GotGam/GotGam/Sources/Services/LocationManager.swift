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
    private override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }
    weak var delegate: LocationManagerDelegate?
    
    var currentLocation: CLLocationCoordinate2D?
    
    var settingLocationURL: URL? {
        guard let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") else { return nil }
        return url
    }
    var locationServicesEnabled: Bool {
      return CLLocationManager.locationServicesEnabled()
    }
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    func requestAuthorization(){
        manager.requestWhenInUseAuthorization()
        print("allowsBackgroundLocationUpdates")
    }
    
    func startUpdatingLocation(){
        manager.startUpdatingLocation()
    }
    
    func addRegionToMinotir(region: CLCircularRegion){
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            // Register the region
            manager.startMonitoring(for: region)
        }
         
    }
    
    func startBackgroundUpdates(){
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            return
        }
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        UIApplication.shared.beginBackgroundTask(expirationHandler: {
          UIApplication.shared.endBackgroundTask(.invalid)
        })
        manager.startMonitoringSignificantLocationChanges()
    }
    deinit {
        print("deinit", #function)
    }
    
}

extension LocationManager: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.delegate?.locationAuthenticationChanged(location: status)
        authorizationStatus = status
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        if let coordinate = locations.last?.coordinate{
            self.delegate?.locationUpdated?(coordinate: coordinate)
        }
        if let location = manager.location {
            self.currentLocation = location.coordinate
            print("didUpdate Location")
            AlarmManager.shared.createAlarm(from: location)
            UserDefaults.standard.set(location.coordinate.asDictionary, forDefines: .location)
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            addNotification(regionID: identifier)
        }
    }
    func addNotification(regionID: String){
        var title = "기본 타이틀"
        var body = "기본 바디"
        if regionID == "enterHome"{
            title = "집"
            body = "집에 접근합니다,"
        }else if regionID == "enterOther"{
            title = "다른곳"
            body = "집밖에 접근합니다,"
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, err) in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            // Create the trigger as a repeating event.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString,
                                                content: content, trigger: trigger)
            
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    // Handle any errors.
                }
            }
        }
    }
}
