//
//  AddViewModel.swift
//  GotGam
//
//  Created by woong on 30/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

protocol AddPlantViewModelInputs {
    func close()
    // tap tag
    func pushAddTagVC()
    // tap save
    // tap image
}

protocol AddPlantViewModelOutputs {
    //var detailItem: DetailItem { get }
    var sections: Observable<[InputSectionModel]> { get }
    var cellType: Observable<[InputItemType]> { get }
}

protocol AddPlantViewModelType {
    var inputs: AddPlantViewModelInputs { get }
    var outputs: AddPlantViewModelOutputs { get }
}

class AddPlantViewModel: CommonViewModel, AddPlantViewModelType, AddPlantViewModelInputs, AddPlantViewModelOutputs {
    
    // MARK: - Constants
    
    // MARK: - Variables
    
    var inputs: AddPlantViewModelInputs { return self }
    var outputs: AddPlantViewModelOutputs { return self }
    
    // MARK: - Input
    
    func close() {
        sceneCoordinator.close(animated: true)
    }
    
    func pushAddTagVC() {
        // TODO: tag 가져오기
        let addTagViewModel = AddTagViewModel(sceneCoordinator: sceneCoordinator, storage: storage, tag: "미지정")
        sceneCoordinator.transition(to: .addTag(addTagViewModel), using: .push, animated: true)
    }
    
    // MARK: - Output
    
    var sections = Observable<[InputSectionModel]>.just([])
    var cellType: Observable<[InputItemType]> = Observable.of([.tag(nil), .endDate(nil), .alramMsg(nil)])
    
    //let cellType: Observable<[InputItemType]> = Observable.of([.tag(1), .endDate, .alramMsg])
    
    // MARK: - Initializing
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, got: Got?) {
        super.init(sceneCoordinator: sceneCoordinator, storage: storage)
        sections = configureDataSource(got: got)
    }
    
    func configureDataSource(got: Got?) -> Observable<[InputSectionModel]> {
        return Observable.just(
            [
                .TagSection(title: " ", items: [.TagItem(title: "태그", tag: got?.tag)]),
                .ToggleableSection(
                    title: " ",
                    items: [
                        .ToggleableItem(title: "마감일시", enabled: got?.insertedDate != nil),
                        .TextFieldItem(text: "", placeholder: "마감 일시를 알려주세요", enabled: false)
                    ]),
                .ToggleableSection(
                    title: " ",
                    items: [
                        .ToggleableItem(title: "도착할 때 알리기", enabled: got?.insertedDate != nil),
                        .TextFieldItem(text: "", placeholder: "도착할 때 알려드릴 메시지를 알려주세요", enabled: false)
                    ]),
                .ToggleableSection(
                    title: " ",
                    items: [
                        .ToggleableItem(title: "떠날할 때 알리기", enabled: got?.insertedDate != nil),
                        .TextFieldItem(text: "", placeholder: "떠날할 때 알려드릴 메시지를 알려주세요", enabled: false)
                    ])
            ]
        )
    }
}

enum InputSectionModel {
    case TagSection(title: String, items: [InputItem])
    case ToggleableSection(title: String, items: [InputItem])
}

enum InputItem {
    case TagItem(title: String, tag: String?) // String -> Tag
    case ToggleableItem(title: String, enabled: Bool)
    case TextFieldItem(text: String, placeholder: String, enabled: Bool)
}


extension InputSectionModel: SectionModelType {
    typealias Item = InputItem
    
    var items: [InputItem] {
        switch self {
        case .TagSection(title: _, items: let items):
            return items.map { $0 }
        case .ToggleableSection(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: InputSectionModel, items: [Item]) {
        switch original {
        case let .TagSection(title: title, items: _):
            self = .TagSection(title: title, items: items)
        case let .ToggleableSection(title: title, items: _):
            self = .ToggleableSection(title: title, items: items)
        }
    }
}


extension InputSectionModel {
    var title: String {
        switch self {
        case .TagSection(title: let title, items: _):
            return title
        case .ToggleableSection(title: let title, items: _):
            return title
        }
    }
}
