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
    
    let storage = GotStorage()
    let coordinator = SceneCoordinator(window: window!)
    
    let mapViewModel = MapViewModel(sceneCoordinator: coordinator, storage: storage)
    
    let mapScene = Scene.map(mapViewModel)
    
    coordinator.transition(to: mapScene, using: .root, animated: false)
    
    return true
  }

}

