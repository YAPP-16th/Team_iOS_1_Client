//
//  LoginManager.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/20.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

protocol LoginManagerType{
    func kakaoLogin()
    func googleLogin()
}

class LoginManager: LoginManagerType{
    static let shared: LoginManager = LoginManager()
    func kakaoLogin() {
        
    }
    
    func googleLogin() {
        
    }
    
    
}
