//
//  FrequentsViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 23/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol FrequentsViewModelInputs {
	var namePlace: BehaviorRelay<String> { get set }
	var addressPlace: BehaviorRelay<String> { get set }
	var latitudePlace: BehaviorRelay<Double> { get set }
	var longitudePlace: BehaviorRelay<Double> { get set }

	func addFrequents()
	func readFrequents()
	func showSearchVC()
}

protocol FrequentsViewModelOutputs {
	var frequentsList: BehaviorSubject<[Frequent]> { get set }
}

protocol FrequentsViewModelType {
	var inputs: FrequentsViewModelInputs { get }
	var outputs: FrequentsViewModelOutputs { get }
}

class FrequentsViewModel: CommonViewModel, FrequentsViewModelInputs, FrequentsViewModelOutputs, FrequentsViewModelType {
	var namePlace = BehaviorRelay<String>(value: "")
	var addressPlace = BehaviorRelay<String>(value: "")
	var latitudePlace = BehaviorRelay<Double>(value: 0)
	var longitudePlace = BehaviorRelay<Double>(value: 0)
	
	var frequentsList: BehaviorSubject<[Frequent]> = BehaviorSubject<[Frequent]>(value: [])
	
		
	func addFrequents() {
		let storage = FrequentsStorage()
		
		let frequent = Frequent(name: namePlace.value, address: addressPlace.value, latitude: latitudePlace.value, longitude: longitudePlace.value)

		storage.createFrequents(frequent: frequent).bind { _ in
			self.readFrequents()
			} .disposed(by: disposeBag)
		
	}
	
	func readFrequents() {
		let storage = FrequentsStorage()
		storage.fetchFrequents()
			.bind { (frequentsList) in
				self.frequentsList.onNext(frequentsList)
			}
			.disposed(by: disposeBag)
	}
	
	func showSearchVC(){
		let movesearchVM = FrequentsSearchViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
		
		
        sceneCoordinator.transition(to: .frequentsSearch(movesearchVM), using: .push, animated: true)
	}
	
	
	var inputs: FrequentsViewModelInputs { return self }
    var outputs: FrequentsViewModelOutputs { return self }
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
