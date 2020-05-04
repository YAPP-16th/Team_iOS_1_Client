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

protocol MapViewModelInputs {
    func createGot(got: Got)
}

protocol MapViewModelOutputs {
    var gotList: BehaviorSubject<[Got]> { get }
}

protocol MapViewModelType {
    var input: MapViewModelInputs { get }
    var output: MapViewModelOutputs { get }
}

class MapViewModel: CommonViewModel, MapViewModelType, MapViewModelInputs, MapViewModelOutputs {
    var input: MapViewModelInputs { return self }
    var output: MapViewModelOutputs { return self }
    
    var gotList = BehaviorSubject<[Got]>(value: [])
    
    enum SeedState{
        case none
        case seeding
        case adding
    }
    
    var tag: [String] = ["맛집", "할일", "데이트할 곳", "일상", "집에서 할 일","학교에서 할 일"]
    
    var seedState = BehaviorSubject<SeedState>(value: .none)
    
    func showAddVC() {
        let addVM = AddViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
        sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
    }
    
    func createGot(got: Got){
        self.storage.createGot(gotToCreate: got).subscribe { event in
            switch event{
            case .next:
                self.storage.fetchGotList().bind(to: self.gotList).disposed(by: self.disposeBag)
            default:
                break
            }
        }.disposed(by: disposeBag)
        
    }
    
    func updateGot(got: Got){
        self.storage.updateGot(gotToUpdate: got).subscribe { event in
            switch event{
            case .next:
                self.storage.fetchGotList().bind(to: self.gotList).disposed(by: self.disposeBag)
            default:
                break
            }
        }.disposed(by: disposeBag)
    }
    
    func deleteGot(got: Got){
        self.storage.deleteGot(id: got.id!).subscribe({ event in
            switch event{
            case .next:
                self.storage.fetchGotList().bind(to: self.gotList).disposed(by: self.disposeBag)
            default:
                break
            }
            }).disposed(by: disposeBag)
        
    }
    
}
