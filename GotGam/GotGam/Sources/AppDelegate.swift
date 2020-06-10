//
//  AppDelegate.swift
//  GotGam
//
//  Created by byeonggeunSon on 2020/03/29.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import GoogleSignIn
import Moya
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        //LocationManager.shared.startMonitoringSignificantLocationChanges()
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GIDSignIn.sharedInstance().clientID = "842168227804-t42u931svmolch20us3n495m7mtj0o45.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        KOSession.shared()?.isAutomaticPeriodicRefresh = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(kakaoSessionDidChange(notification:)),
                                               name: Notification.Name.KOSessionDidChange,
                                               object: nil)
    
        
        if UserDefaults.standard.bool(forDefines: .tutorialShown){
            let coordinator = SceneCoordinator(window: window!)
            coordinator.createTabBar()

            let tabBarViewModel = TabBarViewModel(sceneCoordinator: coordinator)


                coordinator.transition(to: .tabBar(tabBarViewModel), using: .root, animated: false)
        }else{
            let coordinator = SceneCoordinator(window: window!)
            let tutorialViewModel = TutorialViewModel(sceneCoordinator: coordinator)
            coordinator.transition(to: .tutorial(tutorialViewModel), using: .root, animated: false)
        }
        
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    @objc func kakaoSessionDidChange(notification: Notification){
        if let session = KOSession.shared(){
            if session.isOpen(){
                print("카카오로 로그인 된 상태")
//                UserDefaults.standard.set(LoginType.kakao.rawValue, forDefines: .loginType)
            }else{
                print("카카오로 로그인이 안된 상태")
            }
        }
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if KOSession.isKakaoAccountLoginCallback(url) {
            
            
            return KOSession.handleOpen(url)
        }else{
            GIDSignIn.sharedInstance().handle(url)
        }
        
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }else{
            GIDSignIn.sharedInstance().handle(url)
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        KOSession.handleDidEnterBackground()
        //LocationManager.shared.startBackgroundUpdates()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
        KOSession.handleDidBecomeActive()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("구글로그인: 유저가 로그인한 적이 없거나, 로그아웃했습니다.")
            }else{
                print(error.localizedDescription)
            }
            return
        }
//        UserDefaults.standard.set(LoginType.google.rawValue, forDefines: .loginType)
        
        //Todo: Google 로그인에 대한 후처리 로직 만들기
        let userId = user.userID                  // 클라이언트에서만 사용할 ID
        let idToken = user.authentication.idToken // 서버에 보낼 토큰
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        
        let provider = MoyaProvider<GotAPIService>()
        
        if let id = userId, let email = email, let token = idToken{
            let loginInfo = SocialLoginInfo(id: id, email: email, token: token)
            provider.request(.login(.google(loginInfo))) { (result) in
                switch result{
                case .success(let response):
                    let data = response.data
                    let decoder = JSONDecoder()
                    do{
                        let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                        let token = loginResponse.user.token
                        UserDefaults.standard.set(loginResponse.user.nickname, forDefines: .nickname)
                        UserDefaults.standard.set(token, forDefines: .userToken)
                        UserDefaults.standard.set(true, forDefines: .isLogined)
                        UserDefaults.standard.set(email, forDefines: .userID)
                        if let loginVC = self.window?.rootViewController?.presentedViewController as? LoginViewController{
                            loginVC.viewModel.close()
                        }
                    }catch let error{
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //구글 사용자가 로그아웃 했을시 해당 메소드 호출됨. 후처리해주기
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔴 didReceive notification")
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("🔴 notification in willPresent \(notification.request.identifier)")
        completionHandler([.alert, .sound])
    }
}
