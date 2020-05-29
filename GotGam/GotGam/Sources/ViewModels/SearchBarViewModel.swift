//
//  SearchBarViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 07/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift


protocol SearchBarViewModelInputs {
	func addKeyword(keyword: String)
	func readKeyword()
	func readFrequents()
}

protocol SearchBarViewModelOutputs {
	var keywords: BehaviorSubject<[String]> { get set }
	var collectionItems: BehaviorSubject<[Frequent]> { get set }
}

protocol SearchBarViewModelType {
	var inputs: SearchBarViewModelInputs { get }
	var outputs: SearchBarViewModelOutputs { get }
}

class SearchBarViewModel: CommonViewModel, SearchBarViewModelInputs, SearchBarViewModelOutputs, SearchBarViewModelType {
	var keywords: BehaviorSubject<[String]> = BehaviorSubject<[String]>(value: [])
	var collectionItems = BehaviorSubject<[Frequent]>(value: [])
	
		
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
	
	func readFrequents() {
		let storage = FrequentsStorage()
		storage.fetchFrequents()
			.bind { (frequentsList) in
				self.collectionItems.onNext(frequentsList)
		}.disposed(by: disposeBag)
	}
	
	
	
	var inputs: SearchBarViewModelInputs { return self }
    var outputs: SearchBarViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
}
