//
//  StartViewController.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/30.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class StartViewController: UIViewController{
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var withoutLoginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 9
        loginButton.layer.masksToBounds = true
        
        withoutLoginButton.layer.borderWidth = 1.0
        withoutLoginButton.layer.borderColor = UIColor.saffron.cgColor
        
    }
    
    @IBAction func startWithLogin(){
        
    }
    
    @IBAction func startWithoutLogin(){
        start()
    }
    
    func start(){
        UserDefaults.standard.set(true, forDefines: .tutorialShown)
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let gotStorage = GotStorage()
        let alarmStorage = AlarmStorage()
        let coordinator = SceneCoordinator(window: window)
        coordinator.createTabBar(gotService: gotStorage, alarmService: alarmStorage)

        let tabBarViewModel = TabBarViewModel(sceneCoordinator: coordinator, alarmStorage: alarmStorage)


            coordinator.transition(to: .tabBar(tabBarViewModel), using: .root, animated: false)
    }
}
