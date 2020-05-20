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
import RxDataSources

protocol GotListViewModelInputs {
    func removeGot(indexPath: IndexPath, got: Got)
    func editGot(got: Got?)
    func updateFinish(of got: Got)
    var updatedGot: PublishSubject<Got> { get set }
    func fetchRequest()
}

protocol GotListViewModelOutputs {
    var gotSections: BehaviorRelay<[ListSectionModel]> { get }
    //var gotList: BehaviorRelay<[Got]> { get }
    var tagList: BehaviorRelay<[Tag]> { get }
}

protocol GotListViewModelType {
    var inputs: GotListViewModelInputs { get }
    var outputs: GotListViewModelOutputs { get }
}


class GotListViewModel: CommonViewModel, GotListViewModelType, GotListViewModelInputs, GotListViewModelOutputs {
    
    
    // Inputs
    
    func removeGot(indexPath: IndexPath, got: Got) {
        storage.deleteGot(got: got)
            .subscribe(onNext: { [weak self] got in
                if var list = self?.gotList.value {
                    list.remove(at: indexPath.row)
                    self?.gotList.accept(list)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func editGot(got: Got? = nil) {
        
        let addVM = AddPlantViewModel(sceneCoordinator: sceneCoordinator, storage: storage, got: got)
        sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
    }
    
    func updateFinish(of got: Got) {
        storage.updateGot(gotToUpdate: got)
    }
    
    var updatedGot = PublishSubject<Got>()
    
    func fetchRequest() {
        storage.fetchTagList()
            .subscribe(onNext: { [weak self] in
                self?.tagList.accept($0)
            })
            .disposed(by: disposeBag)
        
        storage.fetchGotList()
            .map { $0.filter { $0.isDone != true }}
            .subscribe(onNext: { list in
                self.gotList.accept(list)
            })
            .disposed(by: disposeBag)
    }
    
    // Outputs
    
    var gotSections = BehaviorRelay<[ListSectionModel]>(value: [])
    var gotList = BehaviorRelay<[Got]>(value: [])
    var tagList = BehaviorRelay<[Tag]>(value: [])
    
//    var gotList: Observable<[Got]> {
//        return storage.fetchGotList()
//    }
    
    
    
    var inputs: GotListViewModelInputs { return self }
    var outputs: GotListViewModelOutputs { return self }
    
    override init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator, storage: storage)
        
        gotList
            .subscribe(onNext: { [unowned self] gotList in
                self.gotSections.accept(self.configureDataSource(gotList: gotList))
            })
            .disposed(by: disposeBag)
    }
    
    func configureDataSource(gotList: [Got]) -> [ListSectionModel] {
        return [
            .listSection(title: "", items: gotList.map {
                ListItem.gotItem(got: $0)
            })
        ]
    }
}

enum ListItem {
    case gotItem(got: Got)
}

extension ListItem: IdentifiableType, Equatable {
   typealias Identity = Int64

   var identity: Identity {
       switch self {
       case let .gotItem(got): return got.id!
       }
   }
}

enum ListSectionModel {
    case listSection(title: String, items: [ListItem])
}

extension ListSectionModel: AnimatableSectionModelType {
    
    typealias Identity = String
    typealias Item = ListItem
    
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
    
    init(original: ListSectionModel, items: [Item]) {
        switch original {
        case let .listSection(title, items: _):
            self = .listSection(title: title, items: items)
        }
    }
}

extension ListSectionModel {
    var title: String {
        switch self {
        case .listSection(title: let title, items: _):
            return title
        }
    }
}
