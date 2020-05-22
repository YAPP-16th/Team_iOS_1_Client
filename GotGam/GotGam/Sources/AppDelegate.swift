//
//  AppDelegate.swift
//  GotGam
//
//  Created by byeonggeunSon on 2020/03/29.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
//    let storage = GotStorage()
//    let coordinator = SceneCoordinator(window: window!)
//    coordinator.createTabBar(gotService: storage)
//
//    let mapViewModel = MapViewModel(sceneCoordinator: coordinator, storage: storage)
//
//    let mapScene = Scene.map(mapViewModel)
//
//    coordinator.transition(to: mapScene, using: .root, animated: false)
    
    
    let gotStorage = GotStorage()
    let alarmStorage = AlarmStorage()
    let coordinator = SceneCoordinator(window: window!)
    coordinator.createTabBar(gotService: gotStorage, alarmService: alarmStorage)
    
    let tabBarViewModel = TabBarViewModel(sceneCoordinator: coordinator, alarmStorage: alarmStorage)

    coordinator.transition(to: .tabBar(tabBarViewModel), using: .root, animated: false)
    
    return true
  }

}

