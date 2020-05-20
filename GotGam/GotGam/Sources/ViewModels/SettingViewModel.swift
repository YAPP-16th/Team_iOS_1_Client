//
//  SettingViewModel.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift


protocol SettingViewModelInputs {
    func showAlarmDetailVC()
	func showOtherDetailVC()
	func showPlaceDetailVC()
	func showLoginDetailVC()
}

protocol SettingViewModelOutputs {
	var settingMenu: Observable<[String]> { get }
}

protocol SettingViewModelType {
    var inputs: SettingViewModelInputs { get }
    var outputs: SettingViewModelOutputs { get }
}


class SettingViewModel: CommonViewModel, SettingViewModelType, SettingViewModelInputs, SettingViewModelOutputs {
	
	func showAlarmDetailVC() {
		
		let movesettingalarmVM = SettingAlarmViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
        sceneCoordinator.transition(to: .settingAlarm(movesettingalarmVM), using: .push, animated: true)
	}
	
	func showOtherDetailVC() {
		
		let movesettingotherVM = SettingOtherViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
        sceneCoordinator.transition(to: .settingOther(movesettingotherVM), using: .push, animated: true)
	}
	
	func showPlaceDetailVC() {
        let movesettingplaceVM = SettingPlaceViewModel(sceneCoordinator: sceneCoordinator, storage: self.storage)
        sceneCoordinator.transition(to: .settingPlace(movesettingplaceVM), using: .push, animated: true)
	}
	
	func showLoginDetailVC() {
		
		let movesettingloginVM = SettingLoginViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
        sceneCoordinator.transition(to: .settingLogin(movesettingloginVM), using: .push, animated: true)
	}
	
	var settingMenu = Observable<[String]>.just(["푸시 알람 설정", "자주 가는 장소 설정", "약관 및 정책"])
	
    var inputs: SettingViewModelInputs { return self }
    var outputs: SettingViewModelOutputs { return self }
    var storage: GotStorageType!
    

    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
	
    
}
