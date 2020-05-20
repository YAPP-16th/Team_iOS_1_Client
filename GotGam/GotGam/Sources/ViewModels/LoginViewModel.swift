//
//  LoginViewModel.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/20.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

protocol LoginViewModelInputs {
    func checkLoginStatus()
    func login(type: LoginType)
}

protocol LoginViewModelOutputs {
    
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

extension LoginViewModelType{
    
}

class LoginViewModel: CommonViewModel, LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs{
    
    var inputs: LoginViewModelInputs { return self }
    var outputs: LoginViewModelOutputs { return self }
    
    //MARK: - Inputs
    func checkLoginStatus() {
        
    }
    
    func login(type: LoginType) {
        switch type {
        case .apple:
            print("")
            self.sceneCoordinator.close(animated: true)
        case .google:
            print("")
            self.sceneCoordinator.close(animated: true)
        case .kakao:
            print("")
            self.sceneCoordinator.close(animated: true)
        }
    }
}
