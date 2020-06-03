//
//  SettingPlaceViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 19/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol SettingPlaceViewModelInputs {
	func showFrequentsDetailVC()
	func readFrequents()
	func detailVC()
	func removeFrequents(indexPath: IndexPath, frequent: Frequent)
	
	var placeName: BehaviorRelay<String> { get set }
	var placeAddress: BehaviorRelay<String> { get set }
}

protocol SettingPlaceViewModelOutputs {
	var frequentsList: BehaviorSubject<[Frequent]> { get set }
	var placeText: BehaviorRelay<String> { get }
}

protocol SettingPlaceViewModelType {
    var inputs: SettingPlaceViewModelInputs { get }
    var outputs: SettingPlaceViewModelOutputs { get }
}


class SettingPlaceViewModel: CommonViewModel, SettingPlaceViewModelType, SettingPlaceViewModelInputs, SettingPlaceViewModelOutputs {
	var placeName = BehaviorRelay<String>(value: "")
	var placeAddress = BehaviorRelay<String>(value: "")
	var placeText = BehaviorRelay<String>(value: "")
	var frequentsList: BehaviorSubject<[Frequent]> = BehaviorSubject<[Frequent]>(value: [])
	
	func showFrequentsDetailVC() {
		let moveFrequentsDetailVM = FrequentsViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
		sceneCoordinator.transition(to: .frequents(moveFrequentsDetailVM), using: .push, animated: true)
	}
	
	func detailVC() {
		let detailVM = FrequentsViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
		
		sceneCoordinator.transition(to: .frequents(detailVM), using: .push, animated: true)
	}
	
	func readFrequents() {
		let storage = FrequentsStorage()
		storage.fetchFrequents()
			.bind { (frequentsList) in
				self.frequentsList.onNext(frequentsList)
		}
		.disposed(by: disposeBag)
	}
	
	func removeFrequents(indexPath: IndexPath, frequent: Frequent) {
		let storagePlace = FrequentsStorage()
		storagePlace.deleteFrequents(frequent: frequent)
			.subscribe(onNext: { [weak self] frequent in
				if var list = try? self?.frequentsList.value() {
					list.remove(at: indexPath.row)
					self?.frequentsList.onNext(list)
				}
			})
			.disposed(by: disposeBag)
    }
	
    var inputs: SettingPlaceViewModelInputs { return self }
    var outputs: SettingPlaceViewModelOutputs { return self }
   	var storage: StorageType!
	//var storagePlace: FrequentsStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: StorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
		
    }
    
//    init(sceneCoordinator: SceneCoordinatorType, storage: FrequentsStorageType) {
//        super.init(sceneCoordinator: sceneCoordinator)
//        self.storagePlace = storage
//    }
  
}

enum ListFrequentsItem {
    case frequentsItem(frequent: Frequent)
}

extension ListFrequentsItem: IdentifiableType, Equatable {
   typealias Identity = String

   var identity: Identity {
       switch self {
       case let .frequentsItem(frequent): return frequent.name
       }
   }
}
