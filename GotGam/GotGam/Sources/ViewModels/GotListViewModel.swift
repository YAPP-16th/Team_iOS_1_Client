//
//  ListViewModel.swift
//  GotGam
//
//  Created by woong on 17/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

protocol GotListViewModelInputs {
	func showVC()
}

protocol GotListViewModelOutputs {
    var gotList: Observable<[Got]> { get }
}

protocol GotListViewModelType {
    var inputs: GotListViewModelInputs { get }
    var outputs: GotListViewModelOutputs { get }
}


class GotListViewModel: CommonViewModel, GotListViewModelType, GotListViewModelInputs, GotListViewModelOutputs {
    
    var inputs: GotListViewModelInputs { return self }
    var outputs: GotListViewModelOutputs { return self }
    
	func showVC() {
    let got = Got(id: Int64(arc4random()), tag: .init(name: "tag1", color: "#123123"), title: "멍게비빔밥", content: "test", latitude: .zero, longitude: .zero, isDone: false, place: "맛집", insertedDate: Date())
        let addVM = AddPlantViewModel(sceneCoordinator: sceneCoordinator, storage: storage, got: got)
        sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
	}
	
    // Outputs
    
    var gotList: Observable<[Got]> {
        return storage.fetchGotList()
    }
    
}
