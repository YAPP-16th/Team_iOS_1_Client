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
  
  func requestAuthorization(){
    manager.requestAlwaysAuthorization()
  }
  
  func startUpdatingLocation(){
    manager.startUpdatingLocation()
  }
  
  func startBackgroundUpdates(){
    if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
        return
    }
    manager.startMonitoringSignificantLocationChanges()
    manager.startMonitoringVisits()
  }
  deinit {
    print("deinit", #function)
  }
}

extension LocationManager: CLLocationManagerDelegate{
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    self.delegate?.locationAuthenticationChanged(location: status)
    switch status{
    case .authorizedAlways, .authorizedWhenInUse:
      //위치 접근을 허용한 상태
      print("authorized")
    case .notDetermined:
      // 앱 처음 실행시, 한번만 허용했을 경우 앱을 재실행하면 해당 상태
      print("NotDetermined")
//      requestAuthorization()
    case .denied:
      // 사용자가 위치서비스 자체를 꺼놓고있거나, 사용을 동의하지 않았을경우
      print("denied")
//      if let url = settingLocationURL, UIApplication.shared.canOpenURL(url){
//        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//      }
    case .restricted:
      print("restricted")
    @unknown default:
    break
    }
  }
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let coordinate = locations.last?.coordinate{
      self.delegate?.locationUpdated?(coordinate: coordinate)
    }
  }
  
}
