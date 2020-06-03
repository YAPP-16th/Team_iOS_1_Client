//
//  SearchBarViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 07/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol SearchBarViewModelInputs {
	func addKeyword(keyword: String)
	func readKeyword()
	func readFrequents()
	func readGot()
	
	var filteredGotSubject: BehaviorRelay<String> { get set }
	var filteredTagSubject: BehaviorRelay<[Tag]> { get set }
}

protocol SearchBarViewModelOutputs {
	var keywords: BehaviorSubject<[String]> { get set }
	var collectionItems: BehaviorSubject<[Frequent]> { get set }
	var gotSections: BehaviorRelay<[ListSectionModel]> { get }
}

protocol SearchBarViewModelType {
	var inputs: SearchBarViewModelInputs { get }
	var outputs: SearchBarViewModelOutputs { get }
}

class SearchBarViewModel: CommonViewModel, SearchBarViewModelInputs, SearchBarViewModelOutputs, SearchBarViewModelType {
	var keywords: BehaviorSubject<[String]> = BehaviorSubject<[String]>(value: [])
	var collectionItems = BehaviorSubject<[Frequent]>(value: [])
	var gotList = BehaviorRelay<[Got]>(value: [])
	var gotLists = BehaviorRelay<[Got]>(value: [])
	
	var gotSections = BehaviorRelay<[ListSectionModel]>(value: [])
	var filteredGotSubject = BehaviorRelay<String>(value: "")
	var filteredTagSubject = BehaviorRelay<[Tag]>(value: [])
		
	func addKeyword(keyword: String) {
		let storage = Storage()
		storage.createKeyword(keyword: keyword).bind { _ in
			self.readKeyword()
			} .disposed(by: disposeBag)
	}
	
	func readKeyword() {
		let storage = Storage()
		storage.fetchKeyword().bind { (keywordList) in
			self.keywords.onNext(keywordList.reversed())
			} .disposed(by: disposeBag)
	}
	
	func readFrequents() {
		let storage = Storage()
		storage.fetchFrequents()
			.bind { (frequentsList) in
				self.collectionItems.onNext(frequentsList)
		}.disposed(by: disposeBag)
	}
	
	func readGot() {
		let storage = Storage()
		storage.fetchTaskList()
			.bind { (gotList) in
				self.gotList.accept(gotList)
		}.disposed(by: disposeBag)
	}
	
	
	
	var inputs: SearchBarViewModelInputs { return self }
    var outputs: SearchBarViewModelOutputs { return self }
	
}
