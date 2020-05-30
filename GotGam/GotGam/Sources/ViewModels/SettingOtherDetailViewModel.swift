//
//  SettingOtherDetailViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 30/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol SettingOtherDetailViewModelInputs {

}

protocol SettingOtherDetailViewModelOutputs {
	
}

protocol SettingOtherDetailViewModelType {
    var inputs: SettingOtherDetailViewModelInputs { get }
    var outputs: SettingOtherDetailViewModelOutputs { get }
}


class SettingOtherDetailViewModel: CommonViewModel, SettingOtherDetailViewModelType, SettingOtherDetailViewModelInputs, SettingOtherDetailViewModelOutputs {
	
    var inputs: SettingOtherDetailViewModelInputs { return self }
    var outputs: SettingOtherDetailViewModelOutputs { return self }
    var storage: GotStorageType!
    
	var fileName: String
	
	init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, name: String) {
        self.storage = storage
		self.fileName = name
		super.init(sceneCoordinator: sceneCoordinator)
    }
    
}
