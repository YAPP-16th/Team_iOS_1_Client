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

enum TagColor: CaseIterable {
    case veryLightPink
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
        case .veryLightPink:    return "#cecece"
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
        case .veryLightPink,
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
    var newTagHex: BehaviorRelay<String?> { get set }
    var tagName: BehaviorRelay<String> { get set }
}

protocol CreateTagViewModelOutputs {
    var sections: Observable<[CreateTagSectionModel]> { get }
    var tagColors: Observable<[TagColor]> { get }
}

protocol CreateTagViewModelType {
    var inputs: CreateTagViewModelInputs { get }
    var outputs: CreateTagViewModelOutputs { get }
}


class CreateTagViewModel: CommonViewModel, CreateTagViewModelType, CreateTagViewModelInputs, CreateTagViewModelOutputs {
    
    
    // MARK: - Inputs
    
    var save = PublishSubject<Void>()
    var newTagHex = BehaviorRelay<String?>(value: nil)
    var tagName = BehaviorRelay<String>(value: "")
    
    // MARK: - Outputs
    
    var sections = Observable<[CreateTagSectionModel]>.just([])
    var tagColors = Observable<[TagColor]>.just(TagColor.allCases)
    
    // MARK: - Methods
    
    func createTag() {
        print(tagName.value)
    }
    
    // MARK: - Initializing
    
    var inputs: CreateTagViewModelInputs { return self }
    var outputs: CreateTagViewModelOutputs { return self }
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, tag: Tag? = nil) {
        super.init(sceneCoordinator: sceneCoordinator, storage: storage)
        
        newTagHex.accept(tag?.hex)
        if let tag = tag {
            tagName.accept(tag.name)
        }
        sections = configureDataSource()
        
        save.asObserver()
            .subscribe(onNext: { [unowned self] _ in
                self.createTag()
            })
            .disposed(by: disposeBag)
    }
    
    func configureDataSource() -> Observable<[CreateTagSectionModel]> {
        return Observable<[CreateTagSectionModel]>.just([
            .NameSection(title: "태그 이름", items: [.TextFieldItem(text: "", placeholder: "태그 이름을 적어주세요")]),
            .ColorSection(title: "태그 색상", items: [.GridItem])
        ])
    }
    
    
}

enum CreateTagSectionModel {
    case NameSection(title: String, items: [CreateTagItem])
    case ColorSection(title: String, items: [CreateTagItem])
}

enum CreateTagItem {
    case TextFieldItem(text: String, placeholder: String)
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
