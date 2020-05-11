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
    
    var seedState = PublishSubject<SeedState>()
    
    func showAddVC() {
        let got = Got(id: Int64(arc4random()), tag: .init(id: Int64(arc4random()), name: "tag1", color: "#123123"), title: "멍게비빔밥", content: "test", latitude: .zero, longitude: .zero, isDone: false, place: "맛집", insertedDate: Date())
        let addVM = AddPlantViewModel(sceneCoordinator: sceneCoordinator, storage: storage, got: got)
        sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
    }
    
    func createGot(got: Got){
        self.storage.createGot(gotToCreate: got).subscribe { event in
            switch event{
            case .next:
                print("추가 성공")
            case .error(let error):
                self.handleError(error: error)
            case .completed:
                print("저장 완료 또는 실패")
                self.updateList()
                
            }
        }.disposed(by: disposeBag)
        
    }
    
    func updateGot(got: Got){
        self.storage.updateGot(gotToUpdate: got).subscribe { event in
            switch event{
            case .next:
                print("수정 성공")
            case .error(let error):
                self.handleError(error: error)
            case .completed:
                print("수정 완료 또는 실패")
                self.updateList()
            }
        }.disposed(by: disposeBag)
    }
    
    func deleteGot(got: Got){
        self.storage.deleteGot(id: got.id!).subscribe({ event in
            switch event{
            case .next:
                print("제거 성공")
            case .error(let error):
                self.handleError(error: error)
            case .completed:
                print("제거 완료 또는 실패")
                self.updateList()
            }
            }).disposed(by: disposeBag)
        
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
        self.storage.fetchGotList().subscribe { (event) in
            switch event{
            case .next(let gotList):
                self.gotList.onNext(gotList)
            case .completed:
                print("조회 성공 또는 실패")
            case .error(let error):
                self.handleError(error: error)
            }
        }.disposed(by: self.disposeBag)
    }
}
