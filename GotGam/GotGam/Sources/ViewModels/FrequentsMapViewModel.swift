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
	func showFrequentsVC()
}

protocol FrequentsMapViewModelOutputs {

}

protocol FrequentsMapViewModelType {
	var inputs: FrequentsMapViewModelInputs { get }
	var outputs: FrequentsMapViewModelOutputs { get }
}

class FrequentsMapViewModel: CommonViewModel, FrequentsMapViewModelInputs, FrequentsMapViewModelOutputs, FrequentsMapViewModelType {
	
	var inputs: FrequentsMapViewModelInputs { return self }
    var outputs: FrequentsMapViewModelOutputs { return self }
    var storage: GotStorageType!
	var placeMapText = BehaviorRelay<String>(value: "")
	
	var placeBehavior = BehaviorRelay<Place?>(value: nil)
	//var isCurrentBehavior = BehaviorRelay<Bool>(value: false)
	
	func showFrequentsVC(){
		let movefrequentsVM = FrequentsViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
		sceneCoordinator.transition(to: .frequents(movefrequentsVM), using: .root, animated: true)
	}
    
	init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
}
