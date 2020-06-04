//
//  ListViewModel.swift
//  GotGam
//
//  Created by woong on 17/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa
import RxDataSources

protocol GotListViewModelInputs {
    func fetchRequest()
    func removeGot(indexPath: IndexPath, got: Got)
    func editGot(got: Got?)
    func updateFinish(of got: Got)
    var filteredGotSubject: BehaviorRelay<String> { get set }
    var filteredTagSubject: BehaviorRelay<[Tag]> { get set }
    var gotBoxSubject: PublishSubject<Void> { get set }
    var tagListCellSelect: PublishSubject<Void> { get set }
    func changeIndex(at origin: IndexPath, to destination: IndexPath)
    
}

protocol GotListViewModelOutputs {
    var gotSections: BehaviorRelay<[ListSectionModel]> { get }
    //var gotList: BehaviorRelay<[Got]> { get }
    var tagList: BehaviorRelay<[Tag]> { get }
    var emptyTagList: BehaviorRelay<[Tag]> { get }
}

protocol GotListViewModelType {
    var inputs: GotListViewModelInputs { get }
    var outputs: GotListViewModelOutputs { get }
}


class GotListViewModel: CommonViewModel, GotListViewModelType, GotListViewModelInputs, GotListViewModelOutputs {
    
    // MARK: - Inputs
    
    func fetchRequest() {
       storage.fetchTagList()
            .bind(to: tagList)
            .disposed(by: disposeBag)
        
        storage.fetchEmptyTagList()
            .bind(to: emptyTagList)
            .disposed(by: disposeBag)
       
       storage.fetchTaskList()
           .map { $0.filter { $0.isDone != true }}
            .bind(to: gotList)
           .disposed(by: disposeBag)
    }
    
    func removeGot(indexPath: IndexPath, got: Got) {
        storage.deleteTask(taskObjectId: got.objectId!).subscribe { [weak self] got in
                if var list = self?.gotList.value {
                    list.remove(at: indexPath.row)
                    self?.gotList.accept(list)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    func editGot(got: Got? = nil) {
        let addVM = AddPlantViewModel(sceneCoordinator: sceneCoordinator, got: got)
        sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
    }
    
    func updateFinish(of got: Got) {
        storage.updateTask(taskObjectId:got.objectId!, toUpdate: got)
    }
    
    var filteredGotSubject = BehaviorRelay<String>(value: "")
    var filteredTagSubject = BehaviorRelay<[Tag]>(value: [])
    
    var gotBoxSubject = PublishSubject<Void>()
    var tagListCellSelect = PublishSubject<Void>()
    
    func changeIndex(at origin: IndexPath, to destination: IndexPath) {
        var orderedList = gotList.value
        
        let originGot = orderedList[origin.row]
        let destGot = orderedList[destination.row]
        orderedList[destination.row] = originGot
        orderedList[origin.row] = destGot
        gotList.accept(orderedList)
        storage.reorderTask(toObjectID: destGot.objectId!, fromObjectID: originGot.objectId!)
    }
    
    // MARK: - Outputs
    
    var gotSections = BehaviorRelay<[ListSectionModel]>(value: [])
    var gotList = BehaviorRelay<[Got]>(value: [])
    var tagList = BehaviorRelay<[Tag]>(value: [])
    var emptyTagList = BehaviorRelay<[Tag]>(value: [])
    
    // MARK: - Methods
    
    func showGotBox() {
        let gotBoxViewModel = GotBoxViewModel(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .gotBox(gotBoxViewModel), using: .push, animated: true)
    }
    
    func showShareList() {
        let shareListVM = ShareListViewModel(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .shareList(shareListVM), using: .push, animated: true)
    }
    
    // MARK: - Initializing
    
    var inputs: GotListViewModelInputs { return self }
    var outputs: GotListViewModelOutputs { return self }
    
    override init(sceneCoordinator: SceneCoordinatorType) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        gotBoxSubject
            .subscribe(onNext: { [weak self] in self?.showGotBox() })
            .disposed(by: disposeBag)
        
        gotList
            .subscribe(onNext: { [unowned self] gotList in
                self.gotSections.accept(self.configureDataSource(gotList: gotList))
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(filteredGotSubject, filteredTagSubject)
            .subscribe(onNext: { [weak self] (searchText, filteredTag) in
                guard let gotList = self?.gotList.value else { return }
                let filteredList = gotList.filter ({ got -> Bool in
                    if let tag = got.tag, filteredTag.contains(tag) {
                        return false
                    }
                    if searchText != "", !got.title.lowercased().contains(searchText.lowercased()) {
                        return false
                    }
                    return true
                })
                let filteredDataSources = self?.configureDataSource(gotList: filteredList)
                self?.gotSections.accept(filteredDataSources ?? [])
            })
            .disposed(by: disposeBag)
        
        tagListCellSelect
            .subscribe(onNext: {[weak self] in self?.showShareList()})
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
   typealias Identity = NSManagedObjectID

   var identity: Identity {
       switch self {
       case let .gotItem(got): return got.objectId!
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
