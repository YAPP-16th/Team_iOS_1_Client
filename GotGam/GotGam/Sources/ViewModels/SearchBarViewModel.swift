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
	
	func readGot() {
		let storage = GotStorage()
		storage.fetchGotList()
			.bind { (gotList) in
				self.gotList.accept(gotList)
		}.disposed(by: disposeBag)
	}
	
	
	
	var inputs: SearchBarViewModelInputs { return self }
    var outputs: SearchBarViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage

//		gotLists
//		.subscribe(onNext: { [unowned self] gotList in
//			self.gotSections.accept(self.configureDataSource(gotList: gotList))
//		})
//		.disposed(by: disposeBag)
//		
//		filteredGotSubject
//		.subscribe(onNext: { [weak self] searchText in
//			guard let gotList = self?.gotLists.value else { return }
//			let filteredList = gotList.filter ({ got -> Bool in
//				if searchText != "", let title = got.title, !title.lowercased().contains(searchText.lowercased()) {
//					return false
//				}
//				return true
//			})
//			let filteredDataSources = self?.configureDataSource(gotList: filteredList)
//			self?.gotSections.accept(filteredDataSources ?? [])
//		})
//		.disposed(by: disposeBag)
//    }
//	
//	func configureDataSource(gotList: [Got]) -> [ListSectionModel] {
//        return [
//            .listSection(title: "", items: gotList.map {
//                ListItem.gotItem(got: $0)
//            })
//        ]
//    }

	}
	
}
