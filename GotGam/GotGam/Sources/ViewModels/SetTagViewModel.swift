//
//  AddTagViewModel.swift
//  GotGam
//
//  Created by woong on 30/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol SetTagViewModelInputs {
    var back: PublishSubject<Void> { get set }
    var save: PublishSubject<Void> { get set }
    var selectedTag: BehaviorRelay<Tag> { get set }
    var createTag: PublishSubject<Void> { get set }
    func fetcTagList()
    func removeTag(indexPath: IndexPath, tag: Tag)
    func updateTag(indexPath: IndexPath)
}

protocol SetTagViewModelOutputs {
    var sections: BehaviorRelay<[AddTagSectionModel]> { get }
    
}

protocol SetTagViewModelType {
    var inputs: SetTagViewModelInputs { get }
    var outputs: SetTagViewModelOutputs { get }
}

class SetTagViewModel: CommonViewModel, SetTagViewModelType, SetTagViewModelInputs, SetTagViewModelOutputs {

    // MARK: - Inputs
    
    var back = PublishSubject<Void>()
    var save = PublishSubject<Void>()
    var selectedTag = BehaviorRelay<Tag>(value: Tag(name: "미지정", hex: "#cecece")) // tag
    var createTag = PublishSubject<Void>()
    
    func removeTag(indexPath: IndexPath, tag: Tag) {
        let isLogin = UserDefaults.standard.bool(forDefines: .isLogined)
        if isLogin{
            NetworkAPIManager.shared.deleteTag(tag: tag) {
                self.storage.deleteTag(tag: tag)
                .subscribe(onNext: { [unowned self] _ in
                    var updateSections = self.sections.value
                    var items = updateSections[indexPath.section].items
                    items.remove(at: indexPath.row)
                    updateSections[indexPath.section] = AddTagSectionModel(original: updateSections[indexPath.section], items: items)
                    self.sections.accept(updateSections)
                })
                    .disposed(by: self.disposeBag)
            }
        }else{
            storage.deleteTag(tag.objectId!)
            .subscribe(onNext: { [unowned self] _ in
                var updateSections = self.sections.value
                var items = updateSections[indexPath.section].items
                items.remove(at: indexPath.row)
                updateSections[indexPath.section] = AddTagSectionModel(original: updateSections[indexPath.section], items: items)
                self.sections.accept(updateSections)
            })
            .disposed(by: disposeBag)
        }
        
    }
    
    func updateTag(indexPath: IndexPath) {
        let item = sections.value[indexPath.section].items[indexPath.row]
        
        if case let .TagListItem(tag) = item {
            let createTagVM = CreateTagViewModel(sceneCoordinator: sceneCoordinator, storage: storage, tag: tag)
            sceneCoordinator.transition(to: .createTag(createTagVM), using: .push, animated: true)
        }
    }
    
    func fetcTagList() {
        storage.fetchTagList()
            .subscribe(onNext: { [weak self] in self?.tagList.onNext($0) })
            .disposed(by: disposeBag)
    }
    
    
    
    // MARK: - Outputs
    
    var sections = BehaviorRelay<[AddTagSectionModel]>(value: [])
    
    
    // MARK: - Methods
    
    func pushCreateVC() {
        let createTagVM = CreateTagViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
        sceneCoordinator.transition(to: .createTag(createTagVM), using: .push, animated: true)
    }
    
    func pop() {
        sceneCoordinator.pop(animated: true)
    }
    
    // MARK: - Initializing
    
    //private var tagList = PublishSubject<[Tag]>()
    private var tagList = PublishSubject<[Tag]>()
    
    var inputs: SetTagViewModelInputs { return self }
    var outputs: SetTagViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
        
        tagList
            .map { [Tag(name: "미지정", hex: "#cecece")] + $0 }
            .subscribe(onNext: { [unowned self] tagList in
                self.sections.accept(self.configureDataSource(tags: tagList))
            })
            .disposed(by: disposeBag)
        
        createTag.asObserver()
            .subscribe(onNext: {[weak self] _ in self?.pushCreateVC()})
            .disposed(by: disposeBag)
        
        save
            .subscribe(onNext: {
                [weak self] _ in self?.pop()
            })
            .disposed(by: disposeBag)
        
    }
    
    func configureDataSource(tags: [Tag]) -> [AddTagSectionModel] {
        return [
                .SelectedSection(title: "", items: [
                    .SelectedTagItem(title: "선택된 태그")
                ]),
                .ListSection(title: "태그 목록", items: tags.map {
                    AddTagItem.TagListItem(tag: $0)
                }),
                .NewSection(title: "새 태그 만들기", items: [
                    .CreateTagItem(title: "새로운 태그를 생성합니다")
                ])
            ]
    }
}

// MARK: - for DataSources

enum AddTagItem {
    case SelectedTagItem(title: String)
    case TagListItem(tag: Tag)
    case CreateTagItem(title: String)
}

extension AddTagItem: IdentifiableType, Equatable {
    typealias Identity = String
    var identity: Identity {
        switch self {
        case let .SelectedTagItem(title): return title
        case let .TagListItem(tag): return tag.hex
        case let .CreateTagItem(title): return title
        }
    }
    
    static func == (lhs: AddTagItem, rhs: AddTagItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

enum AddTagSectionModel {
    case SelectedSection(title: String, items: [AddTagItem])
    case ListSection(title: String, items: [AddTagItem])
    case NewSection(title: String, items: [AddTagItem])
}

extension AddTagSectionModel: AnimatableSectionModelType {
    
    typealias Identity = String
    typealias Item = AddTagItem
    
    var identity: String {
        switch self {
        case let .SelectedSection(title, _): return title
        case let .ListSection(title, _): return title
        case let .NewSection(title, _): return title
        }
    }
    
    var items: [AddTagItem] {
        switch self {
        case .SelectedSection(title: _, items: let items):
            return items.map { $0 }
        case .ListSection(title: _, items: let items):
            return items.map { $0 }
        case .NewSection(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: AddTagSectionModel, items: [Item]) {
        switch original {
        case let .SelectedSection(title: title, items: _):
            self = .SelectedSection(title: title, items: items)
        case let .ListSection(title: title, items: _):
            self = .ListSection(title: title, items: items)
        case let .NewSection(title: title, items: _):
            self = .NewSection(title: title, items: items)
        }
    }
}


extension AddTagSectionModel {
    var title: String {
        switch self {
        case .SelectedSection(title: let title, items: _):
            return title
        case .ListSection(title: let title, items: _):
            return title
        case .NewSection(title: let title, items: _):
            return title
        }
    }
}
