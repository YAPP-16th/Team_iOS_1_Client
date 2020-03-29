//
//  AppDelegate.swift
//  GotGam
//
//  Created by byeonggeunSon on 2020/03/29.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

  var window: UIWindow?
  var locationManager: CLLocationManager?
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.requestWhenInUseAuthorization()
//    checkLaunchWithLocationUpdates(options: launchOptions)
    return true
  }

  func checkLaunchWithLocationUpdates(options: [UIApplication.LaunchOptionsKey : Any]?){
    if let options = options, let isLocation = options[UIApplication.LaunchOptionsKey.location] as? Bool {
      if isLocation{
        let manager = CLLocationManager()
        manager.delegate = self
        // 위치 기반으로 실행 될시 처리할 로직 추가
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status{
    case .authorizedAlways, .authorizedWhenInUse:
      print("Authorized")
    case .denied, .notDetermined, .restricted:
      print("UnAuthorized")
    @unknown default:
      break
    }
  }
}

