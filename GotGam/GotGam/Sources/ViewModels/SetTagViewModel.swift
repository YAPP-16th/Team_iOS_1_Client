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


struct Tag {
    var name: String
    var color: String // hex. ex) "#FFFFFF"
}

protocol SetTagViewModelInputs {
    var selectedTag: BehaviorRelay<String> { get set }
    var createTag: PublishSubject<Void> { get set }
    var back: BehaviorSubject<Void> { get set }
    var save: BehaviorSubject<Void> { get set }
}

protocol SetTagViewModelOutputs {
    var sections: Observable<[AddTagSectionModel]> { get }
    
}

protocol SetTagViewModelType {
    var inputs: SetTagViewModelInputs { get }
    var outputs: SetTagViewModelOutputs { get }
}

class SetTagViewModel: CommonViewModel, SetTagViewModelType, SetTagViewModelInputs, SetTagViewModelOutputs {
    
    // MARK: - Inputs
    
    var selectedTag = BehaviorRelay<String>(value: "") // tag
    var createTag = PublishSubject<Void>()
    var back = BehaviorSubject<Void>(value: ())
    var save = BehaviorSubject<Void>(value: ())
    
    // MARK: - Outputs
    
    var sections = Observable<[AddTagSectionModel]>.just([])
    
    // MARK: - Initializing
    
    var inputs: SetTagViewModelInputs { return self }
    var outputs: SetTagViewModelOutputs { return self }
    
    // MARK: - Methods
    
    func pushCreateVC() {

        let createTagVM = CreateTagViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
        sceneCoordinator.transition(to: .createTag(createTagVM), using: .push, animated: true)
    }
    
    // MARK: - Initializing
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, tag: String?) {
        super.init(sceneCoordinator: sceneCoordinator, storage: storage)
        if let tag = tag {
            selectedTag.accept(tag)
        }
        sections = configureDataSource(tags: ["#FFFFFF", "#ffa608", "#6bb4e2"])
        
        createTag.asObserver()
            .subscribe(onNext: {[unowned self] _ in self.pushCreateVC()})
            .disposed(by: disposeBag)
        
    }
    
    func configureDataSource(tags: [String]) -> Observable<[AddTagSectionModel]> {
        return Observable<[AddTagSectionModel]>.just(
            [
                .SelectedSection(title: "", items: [
                    .SelectedTagItem(title: "선택된 태그", tag: selectedTag.value)
                ]),
                .ListSection(title: "태그 목록", items: tags.map{
                    AddTagItem.TagListItem(tag: $0, selected: selectedTag.value == $0)
                }),
                .NewSection(title: "새 태그 만들기", items: [
                    .CreateTagItem(title: "새로운 태그를 생성합니다")
                ])
            ]
        )
    }
}

// MARK: - for DataSources

enum AddTagSectionModel {
    case SelectedSection(title: String, items: [AddTagItem])
    case ListSection(title: String, items: [AddTagItem])
    case NewSection(title: String, items: [AddTagItem])
}

enum AddTagItem {
    case SelectedTagItem(title: String, tag: String?)
    case TagListItem(tag: String, selected: Bool = false)
    case CreateTagItem(title: String)
}


extension AddTagSectionModel: SectionModelType {
    typealias Item = AddTagItem
    
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
