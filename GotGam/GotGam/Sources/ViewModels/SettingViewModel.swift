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
    func showDetailVC()
}

protocol SettingViewModelOutputs {
	var citiesOb: Observable<[String]> { get }
}

protocol SettingViewModelType {
    var inputs: SettingViewModelInputs { get }
    var outputs: SettingViewModelOutputs { get }
}


class SettingViewModel: CommonViewModel, SettingViewModelType, SettingViewModelInputs, SettingViewModelOutputs {
	
	func showDetailVC() {
		let movesettingalarmVM = SettingAlarmViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
        sceneCoordinator.transition(to: .settingAlarm(movesettingalarmVM), using: .push, animated: true)
	}
	
	var citiesOb = Observable<[String]>.just(["푸시 알람 설정", "자주 가는 장소 설정", "약관 및 정책"])
	
    var inputs: SettingViewModelInputs { return self }
    var outputs: SettingViewModelOutputs { return self }
    

	
	
    
}
