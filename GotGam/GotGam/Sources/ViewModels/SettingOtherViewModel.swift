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
	func showPersonalInfoVC()
}

protocol SettingOtherViewModelOutputs {
	var settingOtherMenu: Observable<[String]> { get }
}

protocol SettingOtherViewModelType {
    var inputs: SettingOtherViewModelInputs { get }
    var outputs: SettingOtherViewModelOutputs { get }
}


class SettingOtherViewModel: CommonViewModel, SettingOtherViewModelType, SettingOtherViewModelInputs, SettingOtherViewModelOutputs {
	
	var settingOtherMenu = Observable<[String]>.just(["개인 정보 처리 방침", "서비스 이용 약관", "위치 기반 서비스 약관"])
	
	func showPersonalInfoVC() {
        let settingOtherDetailVM = SettingOtherDetailViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
		settingOtherDetailVM.settingOtherMenuList
        sceneCoordinator.transition(to: .settingDetail(settingOtherDetailVM), using: .modal, animated: true)
	}
	
    var inputs: SettingOtherViewModelInputs { return self }
    var outputs: SettingOtherViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
	
    
}
