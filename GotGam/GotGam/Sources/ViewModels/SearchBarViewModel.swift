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
    var placeSubject: PublishSubject<Place> { get set }
	func addKeyword(keyword: String)
	func readKeyword()
	func readFrequents()
	func readGot()
	func removeHistory(indexPath: IndexPath, history: String)
	
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
    var placeSubject = PublishSubject<Place>()
    
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
		storage.fetchKeyword().bind { (keywordList) in
			self.keywords.onNext(keywordList.reversed())
			} .disposed(by: disposeBag)
	}
	
	func readFrequents() {
		storage.fetchFrequents()
			.bind { (frequentsList) in
				self.collectionItems.onNext(frequentsList)
		}.disposed(by: disposeBag)
	}
	
	func readGot() {
		storage.fetchTaskList()
			.bind { (gotList) in
				self.gotList.accept(gotList)
		}.disposed(by: disposeBag)
	}
	
	func removeHistory(indexPath: IndexPath, history: String) {
//		let index = keywords.value().count - indexPath - 1
//		storage.deleteKeyword(indexPath: index, keyword: history)
		storage.deleteKeyword(keyword: history)
			.subscribe({ _ in
				if var list = try? self.keywords.value() {
					list.remove(at: indexPath.row)
					self.keywords.onNext(list)
				}
			})
			.disposed(by: disposeBag)
	}
	
	
	var inputs: SearchBarViewModelInputs { return self }
    var outputs: SearchBarViewModelOutputs { return self }
	
}
