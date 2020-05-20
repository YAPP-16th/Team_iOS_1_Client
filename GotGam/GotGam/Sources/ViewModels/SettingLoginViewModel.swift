//
//  SettingLoginViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

protocol SettingLoginViewModelInputs {
    
}

protocol SettingLoginViewModelOutputs {
    var settingLoginMenu: Observable<[String]> { get }
}

protocol SettingLoginViewModelType {
    var inputs: SettingLoginViewModelInputs { get }
    var outputs: SettingLoginViewModelOutputs { get }
}


class SettingLoginViewModel: CommonViewModel, SettingLoginViewModelType, SettingLoginViewModelInputs, SettingLoginViewModelOutputs {
    
    var settingLoginMenu = Observable<[String]>.just(["로그아웃", "계정 탈퇴"])
    
    
    var inputs: SettingLoginViewModelInputs { return self }
    var outputs: SettingLoginViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
    
    
    
}
