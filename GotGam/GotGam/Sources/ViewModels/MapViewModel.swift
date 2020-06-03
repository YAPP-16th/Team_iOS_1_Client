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
    func showAddDetailVC(location: CLLocationCoordinate2D?, text: String)
    func showAddDetailVC(got: Got)
    func updateGot(got: Got)
    func setGotDone(got: Got)
    func deleteGot(got: Got)
    func updateList()
    func updateTagList()
    //func quickAdd(text: String, location: CLLocationCoordinate2D)
    func quickAdd(location: CLLocationCoordinate2D, radius: Double)
    func showSearchVC()
    func savePlace(location: CLLocationCoordinate2D)
    var addText: BehaviorRelay<String> { get set }
    
    var filteredTagSubject: BehaviorRelay<[Tag]> { get set }
    var tagListCellSelect: PublishSubject<Void> { get set }
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
    
    
    
    enum SeedState{
        case none
        case seeding
        case adding
    }

    //MARK: - Model Output
    
    var output: MapViewModelOutputs { return self }
    var gotList = BehaviorSubject<[Got]>(value: [])
    var tagList = BehaviorSubject<[Tag]>(value: [])
    var doneAction = PublishSubject<Got>()
    
    //MARK: - Model Input

    var input: MapViewModelInputs { return self }
    var addText = BehaviorRelay<String>(value: "")
    
    var filteredTagSubject = BehaviorRelay<[Tag]>(value: [])
    var tagListCellSelect = PublishSubject<Void>()
    
    //var seedState = PublishSubject<SeedState>()
    var seedState = BehaviorSubject<SeedState>(value: .none)
    
    func showAddDetailVC(location: CLLocationCoordinate2D? = nil, text: String) {
        //let got = Got(id: Int64(arc4random()), tag: nil, title: "멍게비빔밥", content: "test", latitude: .zero, longitude: .zero, radius: .zero, isDone: false, place: "맛집", insertedDate: Date())
        let addVM = AddPlantViewModel(sceneCoordinator: sceneCoordinator, got: nil)
        addVM.placeSubject.accept(location)
        addVM.nameText.accept(text)
        addVM.radiusSubject.accept(100)
        sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
    }
    
    func showAddDetailVC(got: Got) {
        let addVM = AddPlantViewModel(sceneCoordinator: sceneCoordinator, got: got)
        sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
    }
    
    func savePlace(location: CLLocationCoordinate2D) {
        placeSubject.onNext(location)
        sceneCoordinator.pop(animated: true)
    }
    func quickAdd(location: CLLocationCoordinate2D, radius: Double) {
        createGot(location: location, radius: radius)
        seedState.onNext(.none)
    }
    
    func createGot(location: CLLocationCoordinate2D, radius: Double){
        
        APIManager.shared.getPlace(longitude: location.longitude, latitude: location.latitude) { [weak self] (place) in
            guard let self = self else { return }

            let got = Got(title: self.addText.value, latitude: location.latitude, longitude: location.longitude, place: place?.address?.addressName ?? "")
//            if UserDefaults.standard.bool(forDefines: .isLogined){
//                NetworkAPIManager.shared.createTask(got: got) { (got) in
//                    if let got = got{
//                        self.storage.createGot(gotToCreate: got).bind(onNext: { _ in
//                            self.updateList()
//                            self.updateTagList()
//                        }).disposed(by: self.disposeBag)
//                    }
//                }
//            }else{
//                self.storage.createGot(gotToCreate: got).bind(onNext: { _ in
//                    self.updateList()
//                    self.updateTagList()
//                }).disposed(by: self.disposeBag)
//            }
        }
        
    }
    
    func setGotDone(got: Got){
        var gotToUpdate = got
        gotToUpdate.isDone = true
        let isLogin = UserDefaults.standard.bool(forDefines: .isLogined)
        
        self.storage.updateTask(taskObjectId: gotToUpdate.objectId!, toUpdate: gotToUpdate).bind{ got in
                self.doneAction.onNext(gotToUpdate)
            }.disposed(by: self.disposeBag)
    }
    
    func updateGot(got: Got){
        let isLogin = UserDefaults.standard.bool(forDefines: .isLogined)
        
        self.storage.updateTask(taskObjectId: got.objectId!, toUpdate: got).bind { _ in
            self.updateList()
            self.updateTagList()
        }.disposed(by: self.disposeBag)
        
        
    }
    
    func deleteGot(got: Got){
        let isLogin = UserDefaults.standard.bool(forDefines: .isLogined)
        self.storage.deleteTask(taskObjectId: got.objectId!).subscribe { oncompleted in
            switch oncompleted{
            case .completed:
                self.updateList()
                self.updateTagList()
            case .error(let error):
                print(error.localizedDescription)
            }
        }.disposed(by: self.disposeBag)
        
    }
    
    func handleError(error: Error){
        if let error = error as? StorageError{
            switch error {
            case let .create(err):
                print(err)
            case let .read(err):
                print(err)
            case let .update(err):
                print(err)
            case let .delete(err):
                print(err)
            case let .sync(err):
                print(err)
            }
        }
    }
    
    func updateList(){
        self.storage.fetchTaskList()
            .map { $0.filter {!$0.isDone} }
            .map { $0.reversed() }
            .bind{ list in
                self.originGotList.accept(list)
            }.disposed(by: self.disposeBag)
    }
    
    func updateTagList(){
        self.storage.fetchTagList().bind { (tagList) in
            self.tagList.onNext(tagList)
        }.disposed(by: self.disposeBag)
    }
	
	func showSearchVC() {
		let movesearchVM = SearchBarViewModel(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .searchBar(movesearchVM), using: .fullScreen, animated: false)
	}
    
    func showShareList() {
        let shareListVM = ShareListViewModel(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .shareList(shareListVM), using: .modal, animated: true)
    }
	
    var aimToPlace = BehaviorSubject<Bool>(value: false)
    var placeSubject = BehaviorSubject<CLLocationCoordinate2D?>(value: nil)
    var beforeGotSubject = BehaviorRelay<Got?>(value: nil)
    private var originGotList = BehaviorRelay<[Got]>(value: [])
    
    override init(sceneCoordinator: SceneCoordinatorType) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        filteredTagSubject
            .subscribe(onNext: {[weak self] filteredTag in
                guard let self = self else { return }
                
                let gotList = self.originGotList.value
                let filterdList = gotList.filter ({ got -> Bool in
                    guard let tag = got.tag else { return true }
                    
                    return filteredTag.contains(tag) ? false : true
                })
                print("filteredTag: ",filteredTag)
                print(filterdList)
                self.gotList.onNext(filterdList)
            })
            .disposed(by: disposeBag)
        
        originGotList
            .subscribe(onNext: { [weak self] gotList in
                self?.gotList.onNext(gotList)
            })
            .disposed(by: disposeBag)
        
        tagListCellSelect
            .subscribe(onNext: {[weak self] in self?.showShareList()})
            .disposed(by: disposeBag)
    }
}
