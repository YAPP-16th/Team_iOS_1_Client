//
//  SettingPlaceViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 19/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift


protocol SettingPlaceViewModelInputs {
	func showFrequentsDetailVC()
	func readFrequents()
}

protocol SettingPlaceViewModelOutputs {
	var frequentsList: BehaviorSubject<[Frequent]> { get set }
}

protocol SettingPlaceViewModelType {
    var inputs: SettingPlaceViewModelInputs { get }
    var outputs: SettingPlaceViewModelOutputs { get }
}


class SettingPlaceViewModel: CommonViewModel, SettingPlaceViewModelType, SettingPlaceViewModelInputs, SettingPlaceViewModelOutputs {
	
	var frequentsList: BehaviorSubject<[Frequent]> = BehaviorSubject<[Frequent]>(value: [])
	
	func showFrequentsDetailVC() {
		let moveFrequentsDetailVM = FrequentsViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
		sceneCoordinator.transition(to: .frequents(moveFrequentsDetailVM), using: .push, animated: true)
	}
	
	func readFrequents() {
		let storage = FrequentsStorage()
		storage.fetchFrequents()
			.bind { (frequentsList) in
				self.frequentsList.onNext(frequentsList)
		}
		.disposed(by: disposeBag)
	}
	
    var inputs: SettingPlaceViewModelInputs { return self }
    var outputs: SettingPlaceViewModelOutputs { return self }
   	var storage: GotStorageType!
	var storagePlace: FrequentsStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
    
    init(sceneCoordinator: SceneCoordinatorType, storage: FrequentsStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storagePlace = storage
    }
  
}
