//
//  ListViewModel.swift
//  GotGam
//
//  Created by woong on 17/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol GotListViewModelInputs {
	func showVC()
}

protocol GotListViewModelOutputs {
    var gotList: BehaviorSubject<[Got]> { get }
    var tagList: BehaviorRelay<[Tag]> { get }
}

protocol GotListViewModelType {
    var inputs: GotListViewModelInputs { get }
    var outputs: GotListViewModelOutputs { get }
}


class GotListViewModel: CommonViewModel, GotListViewModelType, GotListViewModelInputs, GotListViewModelOutputs {
    
    
    // Inputs
    
    // Outputs
    
    var gotList = BehaviorSubject<[Got]>(value: [])
    var tagList = BehaviorRelay<[Tag]>(value: [])
    
//    var gotList: Observable<[Got]> {
//        return storage.fetchGotList()
//    }
    
    
    
    var inputs: GotListViewModelInputs { return self }
    var outputs: GotListViewModelOutputs { return self }
    
	func showVC() {
        let got = Got(id: Int64(arc4random()), tag: nil, title: "멍게비빔밥", content: "test", latitude: .zero, longitude: .zero, isDone: false, place: "맛집", insertedDate: Date())
            let addVM = AddPlantViewModel(sceneCoordinator: sceneCoordinator, storage: storage, got: got)
            sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
	}
    
    
    override init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator, storage: storage)
        
        storage.fetchGotList()
            .subscribe(onNext: { list in
                self.gotList.onNext(list)
            })
            .disposed(by: disposeBag)
        
        // MARK: tag 더미데이터 수정
        storage.fetchTagList()
            .subscribe(onNext: { list in
                self.tagList.accept(list)
            }).disposed(by: disposeBag)
        
//        storage.fetchTagList()
//            .subscribe(onNext: { tag in
//                self.tagList.onNext(tag)
//            })
//            .disposed(by: disposeBag)
        
    }
}
