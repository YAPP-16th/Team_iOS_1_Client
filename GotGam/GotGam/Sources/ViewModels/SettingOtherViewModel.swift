//
//  SettingOtherViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 19/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift


protocol SettingOtherViewModelInputs {
	
}

protocol SettingOtherViewModelOutputs {
	var settingOtherMenu: Observable<[String]> { get }
}

protocol SettingOtherViewModelType {
    var inputs: SettingOtherViewModelInputs { get }
    var outputs: SettingOtherViewModelOutputs { get }
}


class SettingOtherViewModel: CommonViewModel, SettingOtherViewModelType, SettingOtherViewModelInputs, SettingOtherViewModelOutputs {
	
	var settingOtherMenu = Observable<[String]>.just(["위치정보 이용약관", "개인정보처리방침", "오픈소스 라이선스", "법적 공지 / 정보제공처"])
	
    var inputs: SettingOtherViewModelInputs { return self }
    var outputs: SettingOtherViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
	
    
}
