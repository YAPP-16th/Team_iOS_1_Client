//
//  SettingOtherDetailViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 30/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift


protocol SettingOtherDetailViewModelInputs {
	
}

protocol SettingOtherDetailViewModelOutputs {
	
}

protocol SettingOtherDetailViewModelType {
    var inputs: SettingOtherDetailViewModelInputs { get }
    var outputs: SettingOtherDetailViewModelOutputs { get }
}


class SettingOtherDetailViewModel: CommonViewModel, SettingOtherDetailViewModelType, SettingOtherDetailViewModelInputs, SettingOtherDetailViewModelOutputs {
	
	var settingOtherMenuList = Observable<[String]>(value: "")
	
	
    var inputs: SettingOtherDetailViewModelInputs { return self }
    var outputs: SettingOtherDetailViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
    
}
