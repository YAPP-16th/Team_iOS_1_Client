//
//  AddViewModel.swift
//  GotGam
//
//  Created by woong on 30/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

protocol AddPlantViewModelInputs {
    func close()
    // tap tag
    // tap save
    // tap image
}

protocol AddPlantViewModelOutputs {
    //var detailItem: DetailItem { get }
    var initGot: Observable<Got>? { get set }
    var cellType: Observable<[InputItemType]> { get }
}

protocol AddPlantViewModelType {
    var inputs: AddPlantViewModelInputs { get }
    var outputs: AddPlantViewModelOutputs { get }
}


class AddPlantViewModel: CommonViewModel, AddPlantViewModelType, AddPlantViewModelInputs, AddPlantViewModelOutputs {
    
    // MARK: - Constants
    
    // MARK: - Variables
    
    var inputs: AddPlantViewModelInputs { return self }
    var outputs: AddPlantViewModelOutputs { return self }
    
    // MARK: - Input
    func close() {
        sceneCoordinator.close(animated: true)
    }
    
    // MARK: - Output
    //var detailItem: DetailItem
    var initGot: Observable<Got>?
    var cellType: Observable<[InputItemType]> = Observable.of([.tag(nil), .endDate(nil), .alramMsg(nil)])
    
    //let cellType: Observable<[InputItemType]> = Observable.of([.tag(1), .endDate, .alramMsg])
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, got: Got?) {
        super.init(sceneCoordinator: sceneCoordinator, storage: storage)
        
        //print(got)
        if let got = got {
            //initGot = BehaviorSubject<Got>(value: got)
            initGot = Observable<Got>.just(got)
            cellType = Observable.of([.tag(got.tag), .endDate(got.insertedDate), .alramMsg(got.content)])
        } else {
            initGot = nil
        }
    }
}
