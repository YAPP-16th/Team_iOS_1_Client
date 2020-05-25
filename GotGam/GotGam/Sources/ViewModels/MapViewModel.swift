//
//  MapViewModel.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import CoreLocation

protocol MapViewModelInputs {
    //func createGot(got: Got)
    func showAddVC()
    func updateGot(got: Got)
    func setGotDone(got: inout Got)
    func deleteGot(got: Got)
    func updateList()
    func updateTagList()
    //func quickAdd(text: String, location: CLLocationCoordinate2D)
    func quickAdd(location: CLLocationCoordinate2D)
	func showSearchVC()
    func savePlace(location: CLLocationCoordinate2D)
    var addText: BehaviorRelay<String> { get set }
}

protocol MapViewModelOutputs {
    var gotList: BehaviorSubject<[Got]> { get }
    var tagList: BehaviorSubject<[Tag]> { get }
    var doneAction: PublishSubject<Got> { get }
}

protocol MapViewModelType {
    var input: MapViewModelInputs { get }
    var output: MapViewModelOutputs { get }
}

class MapViewModel: CommonViewModel, MapViewModelType, MapViewModelInputs, MapViewModelOutputs {

    
    //MARK: - Model Input

    var input: MapViewModelInputs { return self }
    var storage: GotStorageType!
    var addText = BehaviorRelay<String>(value: "")
    
    
    //MARK: - Model Output
    var output: MapViewModelOutputs { return self }
    var gotList = BehaviorSubject<[Got]>(value: [])
    var tagList = BehaviorSubject<[Tag]>(value: [])
    var doneAction = PublishSubject<Got>()
    
    enum SeedState{
        case none
        case seeding
        case adding
    }
    
    
    //var seedState = PublishSubject<SeedState>()
    var seedState = BehaviorSubject<SeedState>(value: .none)
    
    func showAddVC() {
        //let got = Got(id: Int64(arc4random()), tag: nil, title: "멍게비빔밥", content: "test", latitude: .zero, longitude: .zero, radius: .zero, isDone: false, place: "맛집", insertedDate: Date())
        let addVM = AddPlantViewModel(sceneCoordinator: sceneCoordinator, storage: storage, got: nil)
        sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
    }
    
    func savePlace(location: CLLocationCoordinate2D) {
        placeSubject.onNext(location)
        sceneCoordinator.pop(animated: true)
    }
    
    func quickAdd(text: String, location: CLLocationCoordinate2D) {
//        let got = Got(id: Int64(arc4random()), createdDate: Date(), title: text, latitude: location.latitude, longitude: location.longitude, radius: false, place: "", arriveMsg: Date())
//        
//        self.storage.createGot(gotToCreate: got).bind(onNext: { _ in
//            self.seedState.onNext(.none)
//            self.updateList()
//            self.updateTagList()
//        }).disposed(by: self.disposeBag)
    }
    
    func quickAdd(location: CLLocationCoordinate2D) {
        createGot(location: location)
        seedState.onNext(.none)
    }
    
    func createGot(location: CLLocationCoordinate2D){
        
        let got = Got(id: Int64(arc4random()), title: addText.value, latitude: location.latitude, longitude: location.longitude, place: "화장실", insertedDate: Date(), tag: [.init(name: "태그1", hex: TagColor.greenishBrown.hex)])
        
        self.storage.createGot(gotToCreate: got).bind(onNext: { _ in
            self.updateList()
            self.updateTagList()
        }).disposed(by: self.disposeBag)
    }
    
    func setGotDone(got: inout Got){
        got.isDone = true
        self.storage.updateGot(gotToUpdate: got).bind{ got in
            self.doneAction.onNext(got)
        }.disposed(by: self.disposeBag)
    }
    
    func updateGot(got: Got){
        self.storage.updateGot(gotToUpdate: got).bind { _ in
            self.updateList()
            self.updateTagList()
        }.disposed(by: self.disposeBag)
    }
    
    func deleteGot(got: Got){
        self.storage.deleteGot(id: got.id!).bind { _ in
            self.updateList()
            self.updateTagList()
        }.disposed(by: self.disposeBag)
    }
    
    func handleError(error: Error){
        if let error = error as? GotStorageError{
            switch error {
            case let .createError(err):
                print(err)
            case let .fetchError(err):
                print(err)
            case let .updateError(err):
                print(err)
            case let .deleteError(err):
                print(err)
            }
        }
    }
    
    func updateList(){
        self.storage.fetchGotList().bind{ list in
            self.gotList.onNext(list)
        }.disposed(by: self.disposeBag)
    }
    
    func updateTagList(){
        self.storage.fetchTagList().bind { (tagList) in
            self.tagList.onNext(tagList)
        }.disposed(by: self.disposeBag)
    }
	
	func showSearchVC() {
		let movesearchVM = SearchBarViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
        sceneCoordinator.transition(to: .searchBar(movesearchVM), using: .modal, animated: true)
	}
	
    var aimToPlace = BehaviorSubject<Bool>(value: false)
    var placeSubject = PublishSubject<CLLocationCoordinate2D>()
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
}
