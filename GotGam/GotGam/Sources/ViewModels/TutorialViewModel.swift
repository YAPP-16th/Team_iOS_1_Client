//
//  TutorialViewModel.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/30.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
protocol TutorialViewModelInputs{
    func showLoginVC()
    func showMain()
}

protocol TutorialViewModelOutputs{
    
}

protocol TutorialViewModelType{
    var input: TutorialViewModelInputs { get }
    var output: TutorialViewModelOutputs { get }
}

class TutorialViewModel: CommonViewModel, TutorialViewModelType, TutorialViewModelInputs, TutorialViewModelOutputs{
    
    var input: TutorialViewModelInputs { return self }
    var output: TutorialViewModelOutputs { return self }
    
    func showLoginVC() {
        let loginViewModel = LoginViewModel(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .login(loginViewModel), using: .modal, animated: true)
    }
    
    func showMain() {
        let storage = Storage()
        sceneCoordinator.createTabBar()
        
        let tabBarViewModel = TabBarViewModel(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .tabBar(tabBarViewModel), using: .root, animated: false)
    }
}
