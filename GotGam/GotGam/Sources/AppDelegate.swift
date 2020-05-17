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
        
        KOSession.shared()?.isAutomaticPeriodicRefresh = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(kakaoSessionDidChange(notification:)),
                                               name: Notification.Name.KOSessionDidChange,
                                               object: nil)
        let storage = GotStorage()
        let coordinator = SceneCoordinator(window: window!)
        coordinator.createTabBar(gotService: storage)
        
        let tabBarViewModel = TabBarViewModel(sceneCoordinator: coordinator, storage: storage)
        
        coordinator.transition(to: .tabBar(tabBarViewModel), using: .root, animated: false)
        return true
    }
    @objc func kakaoSessionDidChange(notification: Notification){
        if let session = KOSession.shared(){
            if session.isOpen(){
                print("카카오로 로그인 된 상태")
            }else{
                print("카카오로 로그인이 안된 상태")
            }
        }
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        KOSession.handleDidEnterBackground()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        KOSession.handleDidBecomeActive()
    }
}

