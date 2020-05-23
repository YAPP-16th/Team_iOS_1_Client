//
//  GotBoxViewModel.swift
//  GotGam
//
//  Created by woong on 22/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol GotBoxViewModelInputs {
    func fetchRequest()
}

protocol GotBoxViewModelOutputs {
    var boxSections: BehaviorRelay<[BoxSectionModel]> { get }
    //var gotList: BehaviorRelay<[Got]> { get }
    var tagList: BehaviorRelay<[Tag]> { get }
}

protocol GotBoxViewModelType {
    var inputs: GotBoxViewModelInputs { get }
    var outputs: GotBoxViewModelOutputs { get }
}


class GotBoxViewModel: CommonViewModel, GotBoxViewModelType, GotBoxViewModelInputs, GotBoxViewModelOutputs {
    
    
    // MARK: - Inputs
    
    func fetchRequest() {
        storage.fetchGotList()
            .subscribe(onNext: { [weak self] gotList in
                print(gotList)
                let boxList = gotList.filter { $0.isDone == true }
                self?.boxListRelay.accept(boxList)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Outpus
    
    var boxSections = BehaviorRelay<[BoxSectionModel]>(value: [])
    var tagList = BehaviorRelay<[Tag]>(value: [])
    
    // MARK: - Initializing
    
    private var boxListRelay = BehaviorRelay<[Got]>(value: [])
    
    var inputs: GotBoxViewModelInputs { return self }
    var outputs: GotBoxViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
        
        boxListRelay
            .subscribe(onNext: { [weak self] (boxList) in
                print(boxList)
                self?.boxSections.accept(self?.configureDataSource(boxList: boxList) ?? [])
            })
            .disposed(by: disposeBag)
    }
    
    func configureDataSource(boxList: [Got]) -> [BoxSectionModel] {
        return [
            .listSection(title: "", items: boxList.map { BoxItem.gotItem(got: $0)})
        ]
    }
}

enum BoxItem {
    case gotItem(got: Got)
}

extension BoxItem: IdentifiableType, Equatable {
   typealias Identity = Int64

   var identity: Identity {
       switch self {
       case let .gotItem(got): return got.id!
       }
   }
}

enum BoxSectionModel {
    case listSection(title: String, items: [BoxItem])
}

extension BoxSectionModel: AnimatableSectionModelType {
    
    typealias Identity = String
    typealias Item = BoxItem
    
    var identity: String {
        switch self {
        case let .listSection(title, _): return title
        }
    }

    var items: [Item] {
        switch self {
        case .listSection(_, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: BoxSectionModel, items: [Item]) {
        switch original {
        case let .listSection(title, items: _):
            self = .listSection(title: title, items: items)
        }
    }
}

extension BoxSectionModel {
    var title: String {
        switch self {
        case .listSection(title: let title, items: _):
            return title
        }
    }
}
