//
//  AddViewModel.swift
//  GotGam
//
//  Created by woong on 30/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol AddPlantViewModelInputs {
    
    var nameText: BehaviorRelay<String> { get set }
    var dateText: BehaviorRelay<String> { get set }
    var arriveText: BehaviorRelay<String> { get set }
    var leaveText: BehaviorRelay<String> { get set }
    
    var isOnDate: BehaviorSubject<Bool> { get set }
    var isOnArrive: BehaviorSubject<Bool> { get set }
    var isOnLeave: BehaviorSubject<Bool> { get set }
    
    var close: BehaviorSubject<Void> { get set }
    var tapTag: BehaviorSubject<Void> { get set }
}

protocol AddPlantViewModelOutputs {
    
    // 테이블 뷰, 지도, 이미지, 이름, 주소 초기값

    var placeText: BehaviorRelay<String> { get set }
    var tag: BehaviorRelay<String?> { get set }
    var sectionsSubject: BehaviorSubject<[InputSectionModel]> { get }
}

protocol AddPlantViewModelType {
    var inputs: AddPlantViewModelInputs { get }
    var outputs: AddPlantViewModelOutputs { get }
}

class AddPlantViewModel: CommonViewModel, AddPlantViewModelType, AddPlantViewModelInputs, AddPlantViewModelOutputs {
    
    // MARK: - Input
    
    var nameText = BehaviorRelay<String>(value: "")
    var dateText = BehaviorRelay<String>(value: "")
    var arriveText = BehaviorRelay<String>(value: "")
    var leaveText = BehaviorRelay<String>(value: "")
    
    var isOnDate = BehaviorSubject<Bool>(value: true)
    var isOnArrive = BehaviorSubject<Bool>(value: true)
    var isOnLeave = BehaviorSubject<Bool>(value: false)
    
    var close = BehaviorSubject<Void>(value: ())
    var tapTag = BehaviorSubject<Void>(value: ())
    
    // MARK: - Output
    
    var placeText = BehaviorRelay<String>(value: "")
    var tag = BehaviorRelay<String?>(value: nil)
    var sectionsSubject = BehaviorSubject<[InputSectionModel]>(value: [])

    // MARK: - Methods
    
    func pushAddTagVC() {
        // TODO: tag 가져오기
        let addTagViewModel = AddTagViewModel(sceneCoordinator: sceneCoordinator, storage: storage, tag: tag.value)
        sceneCoordinator.transition(to: .addTag(addTagViewModel), using: .push, animated: true)
    }
    
    func fetchGot(got: Got?) {
        guard let got = got else { return }
        
        nameText.accept(got.title)
        //placeText.accept(got.place)
        tag.accept(got.tag)
        
    }
   
    
    // MARK: - Initializing
    var inputs: AddPlantViewModelInputs { return self }
    var outputs: AddPlantViewModelOutputs { return self }
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, got: Got?) {
        super.init(sceneCoordinator: sceneCoordinator, storage: storage)
        
        fetchGot(got: got)
        
        let sectionOb = configureDataSource(got: got)
        sectionOb
            .bind(to: sectionsSubject)
            .disposed(by: disposeBag)
        
        close.asObserver()
            .subscribe(onNext: { _ in
                sceneCoordinator.close(animated: true)
            })
            .disposed(by: disposeBag)
        
        tapTag.asObserver()
            .subscribe(onNext: { [unowned self] _ in
                self.pushAddTagVC()
            })
            .disposed(by: disposeBag)
    }
    
    func configureDataSource(got: Got?) -> Observable<[InputSectionModel]> {
        return Observable.combineLatest([isOnDate, isOnArrive, isOnLeave])
                .map ({ [unowned self] (type) -> [InputSectionModel] in
                    var section: [InputSectionModel] = [.TagSection(section: 0, title: " ", items: [.TagItem(title: "태그", tag: self.tag.value)])]

                    if type[0] {
                        print("in append: \(self.nameText.value)")
                        section.append(
                            .ToggleableSection(
                                section: section.count,
                                title: " ",
                                items: [
                                    .ToggleableItem(title: "마감일시", enabled: got?.insertedDate != nil),
                                    .TextFieldItem(text: self.dateText.value, placeholder: "마감 일시를 알려주세요", enabled: false, isDate: true)
                                    ]))
                    } else {
                        section.append(
                            .ToggleableSection(
                                section: section.count,
                                title: " ",
                                items: [.ToggleableItem(title: "마감일시", enabled: got?.insertedDate != nil)]))
                    }

                    if type[1] {
                        section.append(
                            .ToggleableSection(
                                section: section.count,
                                title: " ",
                                items: [
                                    .ToggleableItem(title: "도착할 때 알리기", enabled: got?.insertedDate != nil),
                                    .TextFieldItem(text: self.arriveText.value, placeholder: "도착할 때 알려드릴 메시지를 알려주세요", enabled: false)
                                ])
                        )
                    } else {
                        section.append(
                            .ToggleableSection(
                                section: section.count,
                                title: " ",
                                items: [.ToggleableItem(title: "도착할 때 알리기", enabled: got?.insertedDate != nil)
                            ])
                        )
                    }

                    if type[2] {
                        section.append(
                            .ToggleableSection(
                                section: section.count,
                                title: " ",
                                items: [
                                    .ToggleableItem(title: "떠날할 때 알리기", enabled: got?.insertedDate != nil),
                                    .TextFieldItem(text: self.leaveText.value, placeholder: "떠날할 때 알려드릴 메시지를 알려주세요", enabled: false)
                                ])
                        )
                    } else {
                        section.append(
                            .ToggleableSection(
                                section: section.count,
                                title: " ",
                                items: [.ToggleableItem(title: "떠날할 때 알리기", enabled: got?.insertedDate != nil),])
                        )
                    }
                    return section
                })
        
    }
    
    
}

enum InputItem {
    case TagItem(title: String, tag: String?) // String -> Tag
    case ToggleableItem(title: String, enabled: Bool)
    case TextFieldItem(text: String, placeholder: String, enabled: Bool, isDate: Bool = false)
}

extension InputItem: IdentifiableType, Equatable {
    typealias Identity = String
    var identity: Identity {
        switch self {
        case let .TagItem(title, _): return title
        case let .ToggleableItem(title, _): return title
        case let .TextFieldItem(_, placeholder, _, _): return placeholder
        }
    }
    
    static func == (lhs: InputItem, rhs: InputItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

enum InputSectionModel {
    case TagSection(section: Int, title: String, items: [InputItem])
    case ToggleableSection(section: Int, title: String, items: [InputItem])
}

extension InputSectionModel: AnimatableSectionModelType {
    var identity: Int {
        switch self {
        case let .TagSection(section, _, _): return section
        case let .ToggleableSection(section, _, _): return section
        }
    }
    
    typealias Identity = Int
    
    typealias Item = InputItem
    
    var items: [InputItem] {
        switch self {
        case .TagSection(_, _, items: let items):
            return items.map { $0 }
        case .ToggleableSection(_, _, items: let items):
            return items.map { $0 }
        }
    }
    
    
    init(original: InputSectionModel, items: [Item]) {
        switch original {
        case let .TagSection(section, title, items: _):
            self = .TagSection(section: section, title: title, items: items)
        case let .ToggleableSection(section, title, items: _):
            self = .ToggleableSection(section: section, title: title, items: items)
        }
    }
}


extension InputSectionModel {
    var title: String {
        switch self {
        case .TagSection(_, title: let title, items: _):
            return title
        case .ToggleableSection(_, title: let title, items: _):
            return title
        }
    }
}


//enum InputSectionModel {
//    case TagSection(title: String, items: [InputItem])
//    case ToggleableSection(title: String, items: [InputItem])
//}
//
//enum InputItem {
//    typealias Identity = String
//
//    case TagItem(title: String, tag: String?) // String -> Tag
//    case ToggleableItem(title: String, enabled: Bool)
//    case TextFieldItem(text: String, placeholder: String, enabled: Bool, isDate: Bool = false)
//}
//
////AnimatableSectionModel
//extension InputSectionModel: SectionModel<String, InputItem> {
//    typealias Item = InputItem
//
//    var items: [InputItem] {
//        switch self {
//        case .TagSection(title: _, items: let items):
//            return items.map { $0 }
//        case .ToggleableSection(title: _, items: let items):
//            return items.map { $0 }
//        }
//    }
//
//    init(original: InputSectionModel, items: [Item]) {
//        switch original {
//        case let .TagSection(title: title, items: _):
//            self = .TagSection(title: title, items: items)
//        case let .ToggleableSection(title: title, items: _):
//            self = .ToggleableSection(title: title, items: items)
//        }
//    }
//}
//
//
//extension InputSectionModel {
//    var title: String {
//        switch self {
//        case .TagSection(title: let title, items: _):
//            return title
//        case .ToggleableSection(title: let title, items: _):
//            return title
//        }
//    }
//}
