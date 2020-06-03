//
//  ShareListViewModel.swift
//  GotGam
//
//  Created by woong on 24/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


protocol ShareListViewModelInputs {
    func fetchTagList()
    func remove(tag: Tag, at indexPath: IndexPath)
    func updateTag(at indexPath: IndexPath)
    func share(tag: Tag)
    var addTagSubject: PublishSubject<Void> { get set }
}

protocol ShareListViewModelOutputs {
    var shareListDataSources: BehaviorRelay<[ShareSectionModel]> { get }
}

protocol ShareListViewModelType {
    var inputs: ShareListViewModelInputs { get }
    var outputs: ShareListViewModelOutputs { get }
}


class ShareListViewModel: CommonViewModel, ShareListViewModelType, ShareListViewModelInputs, ShareListViewModelOutputs {
    
    // MARK: - Inputs
    
    func fetchTagList() {
        storage.fetchTagList()
            .subscribe(onNext: { [weak self] tagList in
                self?.tagListRelay.accept(tagList)
            })
            .disposed(by: disposeBag)
    }
    
    func remove(tag: Tag, at indexPath: IndexPath) {
        storage.delete(tagObjectId: tag.objectId!)
            .subscribe { [weak self] _ in
                guard var updatedDS = self?.shareListDataSources.value else { return }
                var items = updatedDS[indexPath.section].items
                items.remove(at: indexPath.row)
                updatedDS[indexPath.section] = ShareSectionModel(original: updatedDS[indexPath.section], items: items)
                self?.shareListDataSources.accept(updatedDS)
            }
            .disposed(by: disposeBag)
    }
    
    func updateTag(at indexPath: IndexPath) {
        let updatedTag = tagListRelay.value[indexPath.row]
        showCreateTag(tag: updatedTag)
    }
    
    func share(tag: Tag) {
        // TODO: Share 로직 추가
        
        let gotList = storage.fetchTaskList(with: tag)
        gotList
            .subscribe(onNext: { gotList in
                print("share \(gotList)")
            })
            .disposed(by: disposeBag)
    }
    
    var addTagSubject = PublishSubject<Void>()
    
    // MARK: - Outputs
    
    var shareListDataSources = BehaviorRelay<[ShareSectionModel]>(value: [])
    
    // MARK: - Methods
    
    func showCreateTag(tag: Tag? = nil) {
        let createTagVM = CreateTagViewModel(sceneCoordinator: sceneCoordinator, storage: storage, tag: tag)
        sceneCoordinator.transition(to: .createTag(createTagVM), using: .push, animated: true)
    }
    
    // MARK: - Initializing
    
    private var tagListRelay = BehaviorRelay<[Tag]>(value: [])
    
    var inputs: ShareListViewModelInputs { return self }
    var outputs: ShareListViewModelOutputs { return self }
    var storage: StorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: StorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
        
        tagListRelay
            .subscribe(onNext: { [weak self] tagList in self?.shareListDataSources.accept(self?.configureDataSource(tags: tagList) ?? [])
            })
            .disposed(by: disposeBag)
        
        addTagSubject
            .subscribe(onNext: { [weak self] in self?.showCreateTag() })
            .disposed(by: disposeBag)
    }
    
    func configureDataSource(tags: [Tag]) -> [ShareSectionModel] {
        let shareItems = tags.map { ShareItem.shareItem(tag: $0) }
        return [.shareSection(title: " ", items: shareItems)]
    }
}

enum ShareItem {
    case shareItem(tag: Tag)
}

extension ShareItem: IdentifiableType, Equatable {
    
    typealias Identity = String
    
    var identity: Identity {
        switch self {
        case let .shareItem(tag): return tag.hex
        }
    }
    
    static func == (lhs: ShareItem, rhs: ShareItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

enum ShareSectionModel {
    case shareSection(title: String, items: [ShareItem])
}

extension ShareSectionModel: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = ShareItem
    
    var identity: String {
        switch self {
        case let .shareSection(title, _): return title
        }
    }
    
    var items: [ShareItem] {
        switch self {
        case let .shareSection(_, items): return items
        }
    }
    
    init(original: ShareSectionModel, items: [Item]) {
        switch original {
        case let .shareSection(title, _):
            self = .shareSection(title: title, items: items)
        }
    }
}

extension ShareSectionModel {
    var title: String {
        switch self {
        case let .shareSection(title, _): return title
        }
    }
}
