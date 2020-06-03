//
//  FrequentsSearchViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 26/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FrequentsSearchViewModelInputs {
	func addKeyword(keyword: String)
	func readKeyword()
	func showMapVC()
	var placeBehavior: BehaviorRelay<Place?> { get set }
}

protocol FrequentsSearchViewModelOutputs {
	var keywords: BehaviorSubject<[String]> { get set }
}

protocol FrequentsSearchViewModelType {
	var inputs: FrequentsSearchViewModelInputs { get }
	var outputs: FrequentsSearchViewModelOutputs { get }
}

class FrequentsSearchViewModel: CommonViewModel, FrequentsSearchViewModelInputs, FrequentsSearchViewModelOutputs, FrequentsSearchViewModelType {
	
	var keywords: BehaviorSubject<[String]> = BehaviorSubject<[String]>(value: [])
	var placeBehavior = BehaviorRelay<Place?>(value: nil)
	var frequentsPlaceSearch = BehaviorRelay<Place?>(value: nil)
		
	func addKeyword(keyword: String) {
		let storage = SearchStorage()
		storage.createKeyword(keyword: keyword).bind { _ in
			self.readKeyword()
			} .disposed(by: disposeBag)
	}
	
	func readKeyword() {
		let storage = SearchStorage()
		storage.fetchKeyword().bind { (keywordList) in
			self.keywords.onNext(keywordList.reversed())
			} .disposed(by: disposeBag)
	}

	func showMapVC(){
		let movemapVM = FrequentsMapViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
		movemapVM.placeBehavior.accept(placeBehavior.value)
		movemapVM.frequentsPlaceMap.bind(to: frequentsPlaceSearch).disposed(by: disposeBag)
		sceneCoordinator.transition(to: .frequentsMap(movemapVM), using: .push, animated: true)
	}
	
	
	var inputs: FrequentsSearchViewModelInputs { return self }
    var outputs: FrequentsSearchViewModelOutputs { return self }
    var storage: StorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: StorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
}
