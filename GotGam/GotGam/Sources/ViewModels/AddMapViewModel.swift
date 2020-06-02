//
//  AddMapViewModel.swift
//  GotGam
//
//  Created by woong on 2020/06/01.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation


protocol AddMapViewModelInputs {
    var radiusRelay: BehaviorRelay<Double> { get set }
    var locationSubject: BehaviorRelay<CLLocationCoordinate2D> { get set }
    var seedSubject: PublishSubject<Void> { get set }
    
}

protocol AddMapViewModelOutputs {
    var radiusPublish: PublishSubject<Double> { get }
    var locationPublish: PublishSubject<CLLocationCoordinate2D> { get }
}

protocol AddMapViewModelType {
    var inputs: AddMapViewModelInputs { get }
    var outputs: AddMapViewModelOutputs { get }
}

class AddMapViewModel: CommonViewModel, AddMapViewModelInputs, AddMapViewModelOutputs, AddMapViewModelType {
    
    
    // MARK: - Inputs
    
    var locationSubject = BehaviorRelay<CLLocationCoordinate2D>(value: .init())
    var radiusRelay = BehaviorRelay<Double>(value: 150)
    var seedSubject = PublishSubject<Void>()
    
    // MARK: - Outputs
    
    var radiusPublish = PublishSubject<Double>()
    var locationPublish = PublishSubject<CLLocationCoordinate2D>()
    
    // MARK: - Methods
    
    func save() {
        radiusPublish.onNext(radiusRelay.value)
        locationPublish.onNext(locationSubject.value)
        sceneCoordinator.pop(animated: true)
    }
    
    // MARK: - Initializing
    
    var inputs: AddMapViewModelInputs { return self }
    var outputs: AddMapViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, mapPoint: CLLocationCoordinate2D, radius: Double) {
        
        self.storage = storage
        locationSubject.accept(mapPoint)
        radiusRelay.accept(radius)
        super.init(sceneCoordinator: sceneCoordinator)
        
        seedSubject
            .subscribe(onNext: {[weak self] in self?.save()})
            .disposed(by: disposeBag)
        
        
    }
}
