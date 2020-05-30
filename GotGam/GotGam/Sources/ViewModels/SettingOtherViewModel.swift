//
//  SettingOtherViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 19/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SettingOtherViewModelInputs {
	func showPersonalInfoVC(row: Int)
}

protocol SettingOtherViewModelOutputs {
	var settingOtherMenu: BehaviorRelay<[String]> { get }
}

protocol SettingOtherViewModelType {
    var inputs: SettingOtherViewModelInputs { get }
    var outputs: SettingOtherViewModelOutputs { get }
}


class SettingOtherViewModel: CommonViewModel, SettingOtherViewModelType, SettingOtherViewModelInputs, SettingOtherViewModelOutputs {
	
	var settingOtherMenu =  BehaviorRelay<[String]>(value: ["개인 정보 처리 방침", "서비스 이용 약관", "위치 기반 서비스 약관"])


	func showPersonalInfoVC(row: Int) {
		var fileName: String
		switch row{
			case 0: fileName = "개인정보처리방침"
			case 1: fileName = "서비스이용약관"
			case 2: fileName = "위치기반서비스약관"
			default:
			fatalError()
		}
        let settingOtherDetailVM = SettingOtherDetailViewModel(sceneCoordinator: sceneCoordinator, storage: storage, name: fileName)
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
