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
    
    var delegate: TutorialDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 9
        loginButton.layer.masksToBounds = true
        
        withoutLoginButton.layer.borderWidth = 1.0
        withoutLoginButton.layer.borderColor = UIColor.saffron.cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forDefines: .tutorialShown){
            delegate?.start()
        }
    }
    
    @IBAction func startWithLogin(){
        UserDefaults.standard.set(true, forDefines: .tutorialShown)
        delegate?.startWithLogin()
    }
    
    @IBAction func startWithoutLogin(){
        UserDefaults.standard.set(true, forDefines: .tutorialShown)
        delegate?.start()
    }
    
    
}
