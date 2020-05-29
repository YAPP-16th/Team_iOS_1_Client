//
//  AddViewModel.swift
//  GotGam
//
//  Created by woong on 30/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa
import RxDataSources

protocol AddPlantViewModelInputs {
    
    var nameText: BehaviorRelay<String> { get set }
    var dateText: BehaviorRelay<String> { get set }
    var arriveText: BehaviorRelay<String> { get set }
    var leaveText: BehaviorRelay<String> { get set }
    var insertedDateRelay: BehaviorRelay<Date?> { get set }
    
    var isOnDate: BehaviorRelay<Bool> { get set }
    var isOnArrive: BehaviorRelay<Bool> { get set }
    var isOnLeave: BehaviorRelay<Bool> { get set }
    
    var save: PublishSubject<Void> { get set }
    var close: PublishSubject<Void> { get set }
    var tapTag: PublishSubject<Void> { get set }
    var editPlace: PublishSubject<Void> { get set }
}

protocol AddPlantViewModelOutputs {
    var currentGot: BehaviorRelay<Got?> { get }
    var placeText: BehaviorRelay<String> { get }
    var tag: BehaviorRelay<Tag?> { get }
    var sectionsSubject: BehaviorRelay<[InputSectionModel]> { get }
    var placeSubject: BehaviorRelay<CLLocationCoordinate2D?> { get }
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
    var insertedDateRelay = BehaviorRelay<Date?>(value: nil)
    
    var isOnDate = BehaviorRelay<Bool>(value: false)
    var isOnArrive = BehaviorRelay<Bool>(value: true)
    var isOnLeave = BehaviorRelay<Bool>(value: false)
    
    var save = PublishSubject<Void>()
    var close = PublishSubject<Void>()
    var tapTag = PublishSubject<Void>()
    var editPlace = PublishSubject<Void>()
    
    // MARK: - Output
    
    var currentGot = BehaviorRelay<Got?>(value: nil)
    var placeText = BehaviorRelay<String>(value: "")
    var tag = BehaviorRelay<Tag?>(value: nil)
    var sectionsSubject = BehaviorRelay<[InputSectionModel]>(value: [])
    
    // MARK: - Private
    
    var placeSubject = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)

    // MARK: - Methods
    
    private func pushAddTagVC() {
        let addTagViewModel = SetTagViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
        
        if let tag = tag.value {
            addTagViewModel.selectedTag.accept(tag)
        }
        
        addTagViewModel.save
            .subscribe(onNext: { [weak self] _ in
                self?.tag.accept(addTagViewModel.selectedTag.value)
            })
            .disposed(by: disposeBag)
        
        sceneCoordinator.transition(to: .setTag(addTagViewModel), using: .push, animated: true)
    }
    
    private func saveGot() {
        guard let location = placeSubject.value else {
            print("🚨 위치정보가 없습니다.")
            return
        }
        let isLogin = UserDefaults.standard.bool(forDefines: .isLogined)
        if var currentGot = currentGot.value {
            currentGot.title = nameText.value
            currentGot.place = placeText.value
            currentGot.insertedDate = insertedDateRelay.value
            currentGot.tag = tag.value == nil ? [] : [tag.value!]
            currentGot.latitude = location.latitude
            currentGot.longitude = location.longitude
            // TODO: Radius 추가
            currentGot.radius = 100
            currentGot.arriveMsg = arriveText.value
            currentGot.deparetureMsg = leaveText.value
            currentGot.insertedDate = insertedDateRelay.value
            currentGot.onArrive = isOnArrive.value
            currentGot.onDeparture = isOnLeave.value
            currentGot.onDate = isOnDate.value
            currentGot.tag = tag.value == nil ? [] : [tag.value!]
            
            if isLogin{
                NetworkAPIManager.shared.updateGot(got: currentGot) {
                    self.storage.updateGot(gotToUpdate: currentGot)
                    .subscribe(onNext: { [weak self] _ in
                        self?.sceneCoordinator.close(animated: true, completion: nil)
                    })
                        .disposed(by: self.disposeBag)
                }
            }else{
                storage.updateGot(currentGot)
                .subscribe(onNext: { [weak self] _ in
                    self?.sceneCoordinator.close(animated: true, completion: nil)
                })
                .disposed(by: disposeBag)
            }
            
            
        } else {
            
            let got = Got(
                id: "",
                createdDate: Date(),
                title: nameText.value,
                latitude: location.latitude,
                longitude: location.longitude,
                radius: 100,
                place: placeText.value,
                arriveMsg: arriveText.value,
                deparetureMsg: leaveText.value,
                insertedDate: insertedDateRelay.value,
                onArrive: isOnArrive.value,
                onDeparture: isOnLeave.value,
                onDate: isOnDate.value,
                tag: tag.value == nil ? [] : [tag.value!],
                isDone: false)
            if isLogin{
                NetworkAPIManager.shared.createTask(got: got) { (got) in
                    if let got = got{
                        self.storage.createGot(gotToCreate: got)
                        .subscribe(onNext: { [weak self] _ in
                            self?.sceneCoordinator.close(animated: true, completion: nil)
                        })
                            .disposed(by: self.disposeBag)
                    }else{
                        
                    }
                }
            }else{
                storage.createGot(gotToCreate: got)
                .subscribe(onNext: { [weak self] _ in
                    self?.sceneCoordinator.close(animated: true, completion: nil)
                })
                .disposed(by: disposeBag)
            }
        }
    }
    
    private func showMap() {
        
        let mapVM = MapViewModel(sceneCoordinator: sceneCoordinator, storage: storage)
        mapVM.seedState.onNext(.seeding)
        mapVM.aimToPlace.onNext(true)
        
        if let got = currentGot.value {
            mapVM.beforeGotSubject.accept(got)
        }
        if let location = placeSubject.value {
            mapVM.placeSubject.onNext(location)
        }
        mapVM.placeSubject
            .bind(to: placeSubject)
            .disposed(by: disposeBag)
        sceneCoordinator.transition(to: .map(mapVM), using: .push, animated: true)
    }
   
    
    // MARK: - Initializing
    
    var inputs: AddPlantViewModelInputs { return self }
    var outputs: AddPlantViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType, got: Got? = nil) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage

        configureBind(sceneCoordinator: sceneCoordinator)
        currentGot.accept(got)
    }
    
    private func configureBind(sceneCoordinator: SceneCoordinatorType) {
        
        currentGot
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] got in
                if let lat = got.latitude, let long = got.longitude {
                    self?.placeSubject.accept(.init(latitude: lat, longitude: long))
                }
                
                self?.nameText.accept(got.title ?? "")
                self?.placeText.accept(got.place ?? "")
                self?.tag.accept(got.tag?.first)
                self?.isOnDate.accept(got.onDate)
                self?.isOnArrive.accept(got.onArrive)
                self?.isOnLeave.accept(got.onDeparture)
                
                if let insertedDate = got.insertedDate {
                    self?.insertedDateRelay.accept(insertedDate)
                }
                if let arriveMsg = got.arriveMsg, arriveMsg != "" {
                    self?.arriveText.accept(arriveMsg)
                }
                if let departureMsg = got.deparetureMsg, departureMsg != "" {
                    self?.leaveText.accept(departureMsg)
                }
                self?.sectionsSubject.accept(self?.configureDataSource() ?? [])
            })
            .disposed(by: disposeBag)
        
        close
            .subscribe(onNext: { _ in
                sceneCoordinator.close(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        save
            .subscribe(onNext: { [weak self] _ in
                self?.saveGot()
            })
            .disposed(by: disposeBag)
        
        tapTag
            .subscribe(onNext: { [unowned self] _ in
                self.pushAddTagVC()
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(isOnDate, isOnArrive, isOnLeave)
            .subscribe(onNext: { [weak self] onDate, onArrive, onLeave in
                self?.sectionsSubject.accept(self?.configureDataSource() ?? [])
            })
            .disposed(by: disposeBag)
        
        editPlace
            .subscribe(onNext: { [weak self] in
                self?.showMap()
            })
            .disposed(by: disposeBag)
        
        placeSubject
            .subscribe(onNext: { [weak self] location in
                guard let location = location else { return }
                print(location)
                
                APIManager.shared.getPlace(longitude: Double(location.longitude), latitude: Double(location.latitude)) { (place) in
                    self?.placeText.accept(place?.address?.addressName ?? "")
                }
            })
            .disposed(by: disposeBag)   
    }
    
    private func configureDataSource() -> [InputSectionModel] {
        
        var dateItems = [InputItem.ToggleableItem(title: InputItemType.date.title)]
        var arriveItems = [InputItem.ToggleableItem(title: InputItemType.arrive.title)]
        var departureItems = [InputItem.ToggleableItem(title: InputItemType.leave.title)]
        
        if isOnDate.value {
            let item = InputItem.TextFieldItem(text: dateText.value, placeholder: InputItemType.date.placeholder, enabled: false, isDate: true)
            dateItems.append(item)
        }
        if isOnArrive.value {
            let item = InputItem.TextFieldItem(text: arriveText.value, placeholder: InputItemType.arrive.placeholder, enabled: false, isDate: false)
            arriveItems.append(item)
        }
        if isOnLeave.value {
            let item = InputItem.TextFieldItem(text: leaveText.value, placeholder: InputItemType.leave.placeholder, enabled: false, isDate: false)
            departureItems.append(item)
        }
        print(dateItems)
        print(arriveItems)
        print(departureItems)
        return [
            .TagSection(section: InputItemType.tag.rawValue, title: " ", items: [.TagItem(title: InputItemType.tag.title)]),
            .ToggleableSection(
                section: InputItemType.date.rawValue,
                title: " ",
                items: dateItems),
            .ToggleableSection(
                section: InputItemType.arrive.rawValue,
                title: " ",
                items: arriveItems),
            .ToggleableSection(
                section: InputItemType.leave.rawValue,
                title: " ",
                items: departureItems)
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
    case TagItem(title: String)
    case ToggleableItem(title: String)
    case TextFieldItem(text: String, placeholder: String, enabled: Bool, isDate: Bool = false)
}

extension InputItem: IdentifiableType, Equatable {
    typealias Identity = String
    var identity: Identity {
        switch self {
        case let .TagItem(title): return title
        case let .ToggleableItem(title): return title
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
