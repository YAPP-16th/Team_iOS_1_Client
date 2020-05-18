//
//  CreateTagViewModel.swift
//  GotGam
//
//  Created by woong on 06/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum TagColor: String, CaseIterable {
    case orangeRed
    case softBlue
    case heather
    case saffron
    case hospitalGreen
    case greenishBrown
    case coolBlue
    case paleMagenta
    case greyblue
    case dandelion
    case veryLightBrown
    case tiffanyBlue
    
    
    var hex: String {
        switch self {
        case .orangeRed:    return "#ff3b3b"
        case .softBlue:        return "#6bb4e2"
        case .heather:         return "#b579ba"
        case .saffron:         return "#ffa608"
        case .hospitalGreen:    return "#a1d89a"
        case .greenishBrown:    return "#6c6511"
        case .coolBlue:        return "#4a94af"
        case .paleMagenta:      return "#e26bb4"
        case .greyblue:        return "#7997ba"
        case .dandelion:       return "#ffe308"
        case .veryLightBrown:   return "#d8ce9a"
        case .tiffanyBlue:     return "#6bebd3"
        }
    }
    
    var color: UIColor {
        switch self {
        case .orangeRed,
             .softBlue,
             .heather,
             .saffron,
             .hospitalGreen,
             .greenishBrown,
             .coolBlue,
             .paleMagenta,
             .greyblue,
             .dandelion,
             .veryLightBrown,
             .tiffanyBlue:
        return hex.hexToColor()
        }
    }
}

protocol CreateTagViewModelInputs {
    var save: PublishSubject<Void> { get set }
    var tagSelected: PublishSubject<String> { get set }
    var tagName: BehaviorRelay<String> { get set }
}

protocol CreateTagViewModelOutputs {
    var sections: Observable<[CreateTagSectionModel]> { get }
    var tagColors: Observable<[TagColor]> { get }
    var newTagHex: BehaviorRelay<String?> { get }
    var duplicateOb: PublishSubject<Void> { get }
}

protocol CreateTagViewModelType {
    var inputs: CreateTagViewModelInputs { get }
    var outputs: CreateTagViewModelOutputs { get }
}


class CreateTagViewModel: CommonViewModel, CreateTagViewModelType, CreateTagViewModelInputs, CreateTagViewModelOutputs {
    
    
    // MARK: - Private Properties
    
    var editableTag = BehaviorRelay<Tag?>(value: nil)
    
    // MARK: - Inputs
    
    var save = PublishSubject<Void>()
    var tagSelected = PublishSubject<String>()
    var tagName = BehaviorRelay<String>(value: "")
    
    // MARK: - Outputs
    
    var sections = Observable<[CreateTagSectionModel]>.just([])
    var newTagHex = BehaviorRelay<String?>(value: nil)
    var duplicateOb = PublishSubject<Void>()
    var tagColors = Observable<[TagColor]>.just(TagColor.allCases)
    
    // MARK: - Methods
    
    func createTag() {
        guard let hex = newTagHex.value else { return }
        let newTag = Tag(name: tagName.value, hex: hex)
        
        if let tag = editableTag.value {
            storage.update(tag: tag, to: newTag)
        } else {
            storage.create(tag: newTag)
        }
        
        sceneCoordinator.pop(animated: true)
    }
    
    // MARK: - Initializing
    
    var inputs: CreateTagViewModelInputs { return self }
    var outputs: CreateTagViewModelOutputs { return self }
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, tag: Tag? = nil) {
        super.init(sceneCoordinator: sceneCoordinator, storage: storage)
        
        
        editableTag.accept(tag)
        
        editableTag
            .compactMap { $0?.hex }
            .bind(to: newTagHex)
            .disposed(by: disposeBag)
        
        editableTag
            .compactMap { $0?.name }
            .bind(to: tagName)
            .disposed(by: disposeBag)
        
        sections = configureDataSource()
        
        Observable
            .combineLatest(tagSelected, storage.fetchTagList())
            .subscribe(onNext: { [unowned self] selectedTag, tagList in
                let duplicated = tagList.map{$0.hex}.contains(selectedTag)
                if duplicated {
                    self.duplicateOb.onNext(())
                } else {
                    self.newTagHex.accept(selectedTag)
                }
            })
            .disposed(by: disposeBag)
        
        
        save.asObserver()
            .subscribe(onNext: { [unowned self] _ in
                self.createTag()
            })
            .disposed(by: disposeBag)
    }
    
    func configureDataSource() -> Observable<[CreateTagSectionModel]> {
        return Observable<[CreateTagSectionModel]>.just([
            .NameSection(title: "태그 이름", items: [.TextFieldItem]),
            .ColorSection(title: "태그 색상", items: [.GridItem])
        ])
    }
    
    
}

enum CreateTagSectionModel {
    case NameSection(title: String, items: [CreateTagItem])
    case ColorSection(title: String, items: [CreateTagItem])
}

enum CreateTagItem {
    case TextFieldItem
    case GridItem
}


extension CreateTagSectionModel: SectionModelType {
    
    typealias Item = CreateTagItem
    
    var items: [CreateTagItem] {
        switch self {
        case .NameSection(title: _, items: let items):
            return items.map { $0 }
        case .ColorSection(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: CreateTagSectionModel, items: [Item]) {
        switch original {
        case let .NameSection(title: title, items: _):
            self = .NameSection(title: title, items: items)
        case let .ColorSection(title: title, items: _):
            self = .ColorSection(title: title, items: items)
        }
    }
}


extension CreateTagSectionModel {
    var title: String {
        switch self {
        case .NameSection(title: let title, items: _):
            return title
        case .ColorSection(title: let title, items: _):
            return title
        }
    }
}
