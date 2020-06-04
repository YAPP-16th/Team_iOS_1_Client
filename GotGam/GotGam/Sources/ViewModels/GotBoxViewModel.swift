//
//  GotBoxViewModel.swift
//  GotGam
//
//  Created by woong on 22/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa
import RxDataSources

protocol GotBoxViewModelInputs {
    func fetchRequest()
    func recover(got: Got, at indexPath: IndexPath)
    func delete(got: Got, at indexPath: IndexPath)
    var filteredTagSubject: BehaviorRelay<[Tag]> { get set }
    var tagListCellSelect: PublishSubject<Void> { get set }
}

protocol GotBoxViewModelOutputs {
    var boxSections: BehaviorRelay<[BoxSectionModel]> { get }
    //var gotList: BehaviorRelay<[Got]> { get }
    var tagListRelay: BehaviorRelay<[Tag]> { get }
    var emptyTagList: BehaviorRelay<[Tag]> { get }
}

protocol GotBoxViewModelType {
    var inputs: GotBoxViewModelInputs { get }
    var outputs: GotBoxViewModelOutputs { get }
}


class GotBoxViewModel: CommonViewModel, GotBoxViewModelType, GotBoxViewModelInputs, GotBoxViewModelOutputs {
    
    
    // MARK: - Inputs
    
    func fetchRequest() {
        storage.fetchTaskList()
            .map { $0.filter { $0.isDone == true }}
            .bind(to: boxListRelay )
            .disposed(by: disposeBag)
        
        storage.fetchTagList()
            .bind(to: tagListRelay)
            .disposed(by: disposeBag)
        
        storage.fetchEmptyTagList()
            .bind(to: emptyTagList)
            .disposed(by: disposeBag)
    }
    
    func recover(got: Got, at indexPath: IndexPath) {
        var updatedGot = got
        updatedGot.isDone = false
        storage.updateTask(taskObjectId: updatedGot.objectId!, toUpdate: updatedGot)
        
        var box = boxListRelay.value
        box.remove(at: indexPath.row)
        boxListRelay.accept(box)
        
    }
    
    func delete(got: Got, at indexPath: IndexPath) {
        storage.deleteTask(taskObjectId: got.objectId!)
        
        var box = boxListRelay.value
        box.remove(at: indexPath.row)
        boxListRelay.accept(box)
    }
    
    var filteredTagSubject = BehaviorRelay<[Tag]>(value: [])
    var tagListCellSelect = PublishSubject<Void>()
    
    // MARK: - Outpus
    
    var boxSections = BehaviorRelay<[BoxSectionModel]>(value: [])
    var tagListRelay = BehaviorRelay<[Tag]>(value: [])
    var emptyTagList = BehaviorRelay<[Tag]>(value: [])
    // MARK: - Methods
    
    func showShareList() {
        let shareListVM = ShareListViewModel(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .shareList(shareListVM), using: .push, animated: true)
    }
    
    // MARK: - Initializing
    
    private var boxListRelay = BehaviorRelay<[Got]>(value: [])
    
    var inputs: GotBoxViewModelInputs { return self }
    var outputs: GotBoxViewModelOutputs { return self }
    
    override init(sceneCoordinator: SceneCoordinatorType) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        boxListRelay
            .subscribe(onNext: { [weak self] (boxList) in
                self?.boxSections.accept(self?.configureDataSource(boxList: boxList) ?? [])
            })
            .disposed(by: disposeBag)
        
        filteredTagSubject
            .subscribe(onNext: {  [weak self] tags in
                if let filteredGot = self?.boxListRelay.value.filter ({ got in
                        guard let gotTag = got.tag else { return true }
                        return !tags.contains(gotTag)
                    }) {
                    
                    self?.boxSections.accept(self?.configureDataSource(boxList: filteredGot) ?? [])
                }
            })
            .disposed(by: disposeBag)
        
        tagListCellSelect
            .subscribe(onNext: {[weak self] in self?.showShareList()})
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
   typealias Identity = NSManagedObjectID

   var identity: Identity {
       switch self {
       case let .gotItem(got): return got.objectId!
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
