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
    func createGot(got: Got)
    func showAddVC()
    func updateGot(got: Got)
    func setGotDone(got: inout Got)
    func deleteGot(got: Got)
    func updateList()
    func updateTagList()
    func quickAdd(text: String, location: CLLocationCoordinate2D)
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
    
    
    var seedState = PublishSubject<SeedState>()
    
    func showAddVC() {
        let got = Got(id: Int64(arc4random()), tag: nil, title: "멍게비빔밥", content: "test", latitude: .zero, longitude: .zero, isDone: false, place: "맛집", insertedDate: Date())
        let addVM = AddPlantViewModel(sceneCoordinator: sceneCoordinator, storage: storage, got: got)
        sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
    }
    
    func quickAdd(text: String, location: CLLocationCoordinate2D) {
        let got = Got(id: Int64(arc4random()), tag: [], title: text, content: "", latitude: location.latitude, longitude: location.longitude, isDone: false, place: "", insertedDate: Date())
        
        self.storage.createGot(gotToCreate: got).bind(onNext: { _ in
            self.seedState.onNext(.none)
            self.updateList()
            self.updateTagList()
        }).disposed(by: self.disposeBag)
    }
    
    func createGot(got: Got){
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
}
