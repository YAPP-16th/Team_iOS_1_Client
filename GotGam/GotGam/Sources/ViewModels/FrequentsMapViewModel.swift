//
//  FrequentsMapViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 27/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol FrequentsMapViewModelInputs {
	func toFrequentsVC()
}

protocol FrequentsMapViewModelOutputs {
	var frequentsPlaceMap: BehaviorRelay<Place?> { get set }
}

protocol FrequentsMapViewModelType {
	var inputs: FrequentsMapViewModelInputs { get }
	var outputs: FrequentsMapViewModelOutputs { get }
}

class FrequentsMapViewModel: CommonViewModel, FrequentsMapViewModelInputs, FrequentsMapViewModelOutputs, FrequentsMapViewModelType {
	
	var inputs: FrequentsMapViewModelInputs { return self }
    var outputs: FrequentsMapViewModelOutputs { return self }
    var storage: GotStorageType!
	var frequentsPlaceMap = BehaviorRelay<Place?>(value:nil)
	
	var placeBehavior = BehaviorRelay<Place?>(value: nil)
	
	func toFrequentsVC(){
//		let movefrequentsVM = FrequentsViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
//		movefrequentsVM.frequentsPlace.bind(to: frequentsPlaceMap).disposed(by: disposeBag)
		
		print("↗️placeBehavior value: ", frequentsPlaceMap.value)
	}
    
	init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
}
