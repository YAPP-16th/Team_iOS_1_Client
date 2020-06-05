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
	var latitudePlace: BehaviorRelay<String> { get set }
	var longitudePlace: BehaviorRelay<String> { get set }
	var typePlace: BehaviorRelay<IconType?> { get set }

	func addFrequents()
	func updateFrequents()
	func moveSearchVC()
}

protocol FrequentsViewModelOutputs {
	var frequentsList: BehaviorSubject<[Frequent]> { get set }
	var frequentsPlace: BehaviorRelay<Place?> { get set }
}

protocol FrequentsViewModelType {
	var inputs: FrequentsViewModelInputs { get }
	var outputs: FrequentsViewModelOutputs { get }
}

class FrequentsViewModel: CommonViewModel, FrequentsViewModelInputs, FrequentsViewModelOutputs, FrequentsViewModelType {

	var namePlace = BehaviorRelay<String>(value: "")
	var addressPlace = BehaviorRelay<String>(value: "")
	var latitudePlace = BehaviorRelay<String>(value: "")
	var longitudePlace = BehaviorRelay<String>(value: "")
	var typePlace = BehaviorRelay<IconType?>(value: nil)
	
	var frequentsList: BehaviorSubject<[Frequent]> = BehaviorSubject<[Frequent]>(value: [])
	var frequentsPlace = BehaviorRelay<Place?>(value: nil)
		
	var frequentOrigin: Frequent?
	
	
	func addFrequents(){
		let storage = FrequentsStorage()
		let id = String(Date().timeIntervalSince1970)
		guard let la = Double(latitudePlace.value) else { return  }
		guard let lo = Double(longitudePlace.value) else { return  }
		let frequent = Frequent(name: namePlace.value, address: addressPlace.value, latitude: la, longitude: lo, type: typePlace.value!, id: id)

		storage.createFrequents(frequent: frequent).bind { _ in
			let backVM = SettingPlaceViewModel(sceneCoordinator: self.sceneCoordinator, storage: self.storage)
			self.sceneCoordinator.transition(to: .settingPlace(backVM), using: .push, animated: true)
			} .disposed(by: disposeBag)
		print("새로 등록된 값들 🍎", frequent)
	}
	
	func updateFrequents(){
		let storagePlace = FrequentsStorage()
		
		if latitudePlace.value == ""{
			let frequent = Frequent(name: namePlace.value, address: addressPlace.value, latitude: frequentOrigin!.latitude, longitude: frequentOrigin!.longitude, type: typePlace.value!, id: frequentOrigin!.id)
			
			storagePlace.updateFrequents(frequent: frequent)
				.bind { _ in
					self.sceneCoordinator.close(animated: true, completion: nil)
			}.disposed(by: self.disposeBag)
			print("nil 일 때 업뎃된 값들 🍏", frequent)
		} else {
			guard let la = Double(latitudePlace.value) else { return }
			guard let lo = Double(longitudePlace.value) else { return }
			let frequent = Frequent(name: namePlace.value, address: addressPlace.value, latitude: la, longitude: lo, type: typePlace.value!, id: frequentOrigin!.id)
			
			storagePlace.updateFrequents(frequent: frequent)
				.bind { _ in
					self.sceneCoordinator.close(animated: true, completion: nil)
			}.disposed(by: self.disposeBag)
			
		}
		
		
	}
	
	func moveSearchVC(){
		let movesearchVM = FrequentsSearchViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
		movesearchVM.frequentsPlaceSearch.bind(to: frequentsPlace).disposed(by: disposeBag)
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
	
	init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, frequent: Frequent?) {
		self.frequentOrigin = frequent
		super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
		
    }
	
}
