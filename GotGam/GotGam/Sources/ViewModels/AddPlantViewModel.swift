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
    
    var isOnDate: BehaviorRelay<Bool> { get set }
    var isOnArrive: BehaviorRelay<Bool> { get set }
    var isOnLeave: BehaviorRelay<Bool> { get set }
    
    var close: PublishSubject<Void> { get set }
    var tapTag: PublishSubject<Void> { get set }
}

protocol AddPlantViewModelOutputs {
    
    // 테이블 뷰, 지도, 이미지, 이름, 주소 초기값

    var placeText: BehaviorRelay<String> { get set }
    var tag: BehaviorRelay<String?> { get set }
    var sectionsSubject: BehaviorRelay<[InputSectionModel]> { get }
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
    
    var isOnDate = BehaviorRelay<Bool>(value: false)
    var isOnArrive = BehaviorRelay<Bool>(value: true)
    var isOnLeave = BehaviorRelay<Bool>(value: false)
    
    var close = PublishSubject<Void>()
    var tapTag = PublishSubject<Void>()
    
    // MARK: - Output
    
    var placeText = BehaviorRelay<String>(value: "")
    var tag = BehaviorRelay<String?>(value: nil)
    var sectionsSubject = BehaviorRelay<[InputSectionModel]>(value: [])

    // MARK: - Methods
    
    private func pushAddTagVC() {
        // TODO: tag 가져오기
        let addTagViewModel = SetTagViewModel(sceneCoordinator: sceneCoordinator, storage: storage, tag: tag.value ?? nil)
        sceneCoordinator.transition(to: .setTag(addTagViewModel), using: .push, animated: true)
    }
    
    private func fetchGot(got: Got?) {
        guard let got = got else { return }
        
        nameText.accept(got.title ?? "")
        //placeText.accept(got.place)
        //tag.accept(got.tag)
        tag.accept("#123123")
    }
    
    private func removeItem(section: InputItemType) {
        var sections = sectionsSubject.value
        guard sections.count > section.rawValue else { return }
        var items = sections[section.rawValue].items
        
        switch section {
        case .tag: return
        default:
            if items.count >= 2 {
                items.removeLast()
            }
        }
        
        sections[section.rawValue] = InputSectionModel(original: sections[section.rawValue], items: items)
        sectionsSubject.accept(sections)
    }
    
    private func insertItem(section: InputItemType) {
        var sections = sectionsSubject.value
        guard sections.count > section.rawValue else { return }
        var items = sections[section.rawValue].items
        
        var item: InputItem = .TextFieldItem(text: "", placeholder: "", enabled: false, isDate: false)
        
        switch section {
        case .tag: return
        case .date:
            item = InputItem.TextFieldItem(text: dateText.value, placeholder: section.placeholder, enabled: false, isDate: true)
        case .arrive:
            item = InputItem.TextFieldItem(text: arriveText.value, placeholder: section.placeholder, enabled: false, isDate: false)
        case .leave:
            item = InputItem.TextFieldItem(text: leaveText.value, placeholder: section.placeholder, enabled: false, isDate: false)
        }
        items.append(item)
        sections[section.rawValue] = InputSectionModel(original: sections[section.rawValue], items: items)
        sectionsSubject.accept(sections)
    }
   
    
    // MARK: - Initializing
    var inputs: AddPlantViewModelInputs { return self }
    var outputs: AddPlantViewModelOutputs { return self }
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, got: Got?) {
        super.init(sceneCoordinator: sceneCoordinator, storage: storage)
        
        fetchGot(got: got)
        sectionsSubject.accept(configureDataSource(got: got))
        configureBind(sceneCoordinator: sceneCoordinator)
    }
    
    func configureBind(sceneCoordinator: SceneCoordinatorType) {
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
        
        isOnDate
            .subscribe(onNext: { [unowned self] b in
                b ? self.insertItem(section: .date) : self.removeItem(section: .date)
            })
            .disposed(by: disposeBag)
        
        isOnArrive
            .subscribe(onNext: { [unowned self] b in
                b ? self.insertItem(section: .arrive) : self.removeItem(section: .arrive)
            })
            .disposed(by: disposeBag)
        
        isOnLeave
            .subscribe(onNext: { [unowned self] b in
                b ? self.insertItem(section: .leave) : self.removeItem(section: .leave)
            })
            .disposed(by: disposeBag)
    }
    
    func configureDataSource(got: Got?) -> [InputSectionModel] {
        return [
            .TagSection(section: InputItemType.tag.rawValue, title: " ", items: [.TagItem(title: InputItemType.tag.title, tag: self.tag.value)]),
            .ToggleableSection(
                section: InputItemType.date.rawValue,
                title: " ",
                items: [
                    .ToggleableItem(title: InputItemType.date.title, enabled: got?.insertedDate != nil)
                ]),
            .ToggleableSection(
                section: InputItemType.arrive.rawValue,
                title: " ",
                items: [
                    .ToggleableItem(title: InputItemType.arrive.title, enabled: got?.insertedDate != nil)
                ]),
            .ToggleableSection(
                section: InputItemType.leave.rawValue,
                title: " ",
                items: [
                    .ToggleableItem(title: InputItemType.leave.title, enabled: got?.insertedDate != nil)
                ])
        ]
    }
}

enum InputItemType: Int {
    case tag = 0
    case date
    case arrive
    case leave
    
    var title: String {
        switch self {
        case .tag:      return "태그"
        case .date:     return "마감일시"
        case .arrive:   return "도착할 때 알리기"
        case .leave:    return "떠날 때 알리기"
        }
    }
    
    var placeholder: String {
        switch self {
        case .date:     return "마감 일시를 알려주세요"
        case .arrive:   return "도착할 때 알려드릴 메시지를 알려주세요"
        case .leave:    return "떠날할 때 알려드릴 메시지를 알려주세요"
        default:        return ""
        }
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
    
    typealias Identity = Int
    typealias Item = InputItem
    
    var identity: Int {
        switch self {
        case let .TagSection(section, _, _): return section
        case let .ToggleableSection(section, _, _): return section
        }
    }
    
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
        case let .TagSection(_, title, _):
            return title
        case let .ToggleableSection(_, title, _):
            return title
        }
    }
}
