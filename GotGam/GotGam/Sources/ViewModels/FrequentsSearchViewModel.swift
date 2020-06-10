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
	func addKeyword(history: History)
	func readKeyword()
	func removeHistory(indexPath: IndexPath, history: History)
	func showMapVC()
	func moveFrequentsVC()
	var placeBehavior: BehaviorRelay<Place?> { get set }
}

protocol FrequentsSearchViewModelOutputs {
	var keywords: BehaviorSubject<[History]> { get set }
}

protocol FrequentsSearchViewModelType {
	var inputs: FrequentsSearchViewModelInputs { get }
	var outputs: FrequentsSearchViewModelOutputs { get }
}

class FrequentsSearchViewModel: CommonViewModel, FrequentsSearchViewModelInputs, FrequentsSearchViewModelOutputs, FrequentsSearchViewModelType {
	
	var keywords = BehaviorSubject<[History]>(value: [])
	var placeBehavior = BehaviorRelay<Place?>(value: nil)
	var frequentsPlaceSearch = BehaviorRelay<Place?>(value: nil)
		
	func addKeyword(history: History) {
		let storage = Storage()
		storage.createKeyword(history: history)
			.bind { _ in
			self.readKeyword()
			} .disposed(by: disposeBag)
	}
	
	func readKeyword() {
		storage.fetchKeyword().bind { (keywordList) in
			self.keywords.onNext(keywordList.reversed())
			} .disposed(by: disposeBag)
	}

	func removeHistory(indexPath: IndexPath, history: History) {
		storage.deleteKeyword(historyObjectId: history.objectId!)
			.subscribe { [weak self] keyword in
				if var list = try? self?.keywords.value() {
					list.remove(at: indexPath.row)
					self?.keywords.onNext(list)
				}
		}
		.disposed(by: disposeBag)
	}
	
	func showMapVC(){
		let movemapVM = FrequentsMapViewModel(sceneCoordinator: sceneCoordinator)
		movemapVM.placeBehavior.accept(placeBehavior.value)
		movemapVM.frequentsPlaceMap.bind(to: frequentsPlaceSearch).disposed(by: disposeBag)
		sceneCoordinator.transition(to: .frequentsMap(movemapVM), using: .push, animated: true)
	}
	
	func moveFrequentsVC() {
		let moveFrequentsVM = FrequentsViewModel(sceneCoordinator: sceneCoordinator)
		moveFrequentsVM.frequentsPlace.accept(frequentsPlaceSearch.value)
        sceneCoordinator.pop(animated: true, completion: nil)
	}
	
	var inputs: FrequentsSearchViewModelInputs { return self }
    var outputs: FrequentsSearchViewModelOutputs { return self }
    
    
}
