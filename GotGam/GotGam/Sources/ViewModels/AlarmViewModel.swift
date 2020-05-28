//
//  AlarmViewModel.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum AlarmCategoryType {
    case active
    case share
}

protocol AlarmViewModelInputs {
    func fetchAlarmList()
    func removeAlarm(indexPath: IndexPath, alarm: Alarm)
    var checkAlarm: PublishSubject<Alarm> { get set }
    var tappedActive: PublishSubject<Void> { get set }
    var tappedShare: PublishSubject<Void> { get set }
}

protocol AlarmViewModelOutputs {
    var currentAlarm: BehaviorRelay<AlarmCategoryType> { get }
    var activeBadgeCount: BehaviorRelay<Int> { get }
    var sharedBadgeCount: BehaviorRelay<Int> { get }
    var currentDataSource: BehaviorRelay<[AlarmSectionModel]> { get }
//    var activeDataSource: BehaviorRelay<[AlarmSectionModel]> { get }
//    var sharedDataSource: BehaviorRelay<[AlarmSectionModel]> { get }
}

protocol AlarmViewModelType {
    var inputs: AlarmViewModelInputs { get }
    var outputs: AlarmViewModelOutputs { get }
}


class AlarmViewModel: CommonViewModel, AlarmViewModelType, AlarmViewModelInputs, AlarmViewModelOutputs {
    
    
    // MARK: Inputs
    
    var tappedActive = PublishSubject<Void>()
    var tappedShare = PublishSubject<Void>()
    func fetchAlarmList() {
        alarmStorage.fetchAlarmList()
            .subscribe(onNext: { [weak self] alarmList in
                let activeAlarmList = alarmList.filter { $0.type != .share }
                self?.activeAlarmList.accept(activeAlarmList)
                
                let sharedAlarmList = alarmList.filter { $0.type == .share }
                self?.sharedAlarmList.accept(sharedAlarmList)
            })
            .disposed(by: disposeBag)
    }
    
    func removeAlarm(indexPath: IndexPath, alarm: Alarm) {
        
//        if alarm.type != .share
//             {
//            var list = self.activeAlarmList.value
//            if let index = list.firstIndex(of: alarm) {
//                    list.remove(at: index)
//            }
//            self.activeAlarmList.accept(list)
//        } else if alarm.type == .share {
//            var list = self.sharedAlarmList.value
//            if let index = list.firstIndex(of: alarm) {
//                list.remove(at: index)
//            }
//            self.sharedAlarmList.accept(list)
//        }
        
        alarmStorage.deleteAlarm(alarm: alarm)
            .subscribe(onNext: { [weak self] alarm in
                if alarm.type != .share,
                    var list = self?.activeAlarmList.value,
                    let index = list.firstIndex(of: alarm) {
                    list.remove(at: index)
                    self?.activeAlarmList.accept(list)
                } else if alarm.type == .share,
                    var list = self?.sharedAlarmList.value,
                    let index = list.firstIndex(of: alarm) {
                    list.remove(at: index)
                    self?.sharedAlarmList.accept(list)
                }
            })
            .disposed(by: disposeBag)
    
    }
    
    var checkAlarm = PublishSubject<Alarm>()
    
    // MARK: Outputs
    
    var currentDataSource = BehaviorRelay<[AlarmSectionModel]>(value: [])
    var currentAlarm = BehaviorRelay<AlarmCategoryType>(value: .active)
    var activeBadgeCount = BehaviorRelay<Int>(value: 0)
    var sharedBadgeCount = BehaviorRelay<Int>(value: 0)
    
    
    
    // MARK: - Methods
    
    func makeAlarm(_ gotList: [Got]) -> [Alarm] {
        var alarmList = [Alarm]()
        for got in gotList {
            if got.onArrive == true {
                alarmList.append(Alarm(id: Int64(arc4random()), type: .arrive, got: got))
            }
            
            if got.onDeparture == true {
                alarmList.append(Alarm(id: Int64(arc4random()), type: .departure, got: got))
            }
        }
        return alarmList
    }
    
    func setCheckAlarm() {
        
    }
    
    // MARK: Initializing
    
    private var activeAlarmList = BehaviorRelay<[Alarm]>(value: [])
    private var sharedAlarmList = BehaviorRelay<[Alarm]>(value: [])
    private var activeDataSource = BehaviorRelay<[AlarmSectionModel]>(value: [])
    private var sharedDataSource = BehaviorRelay<[AlarmSectionModel]>(value: [])
    
    var inputs: AlarmViewModelInputs { return self }
    var outputs: AlarmViewModelOutputs { return self }
    var alarmStorage: AlarmStorageType!
    var gotStorage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, alarmStorage: AlarmStorageType, gotStorage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.alarmStorage = alarmStorage
        self.gotStorage = gotStorage
        
        // MARK: Test Alarms 생성코드
        // 현재있는 곳으로 알람을 만듬
        
//        gotStorage.fetchGotList()
//            .compactMap { [weak self] in self?.makeAlarm($0) }
//            .subscribe(onNext: { [weak self] alarmList in
//                for alarm in alarmList {
//                    self?.alarmStorage.createAlarm(alarm)
//
//                }
//            })
//            .disposed(by: disposeBag)
        
        checkAlarm
            .subscribe(onNext: { [weak self] alarm in
                var newAlarm = alarm
                newAlarm.isChecked = true
                alarmStorage.updateAlarm(to: newAlarm)
                
                if alarm.type == .share {
                    guard var list = self?.sharedAlarmList.value else { return }
                    if let index = list.firstIndex(of: alarm) {
                        list[index].isChecked = true
                        self?.sharedAlarmList.accept(list)
                    }
                } else {
                    guard var list = self?.activeAlarmList.value else { return }
                    if let index = list.firstIndex(of: alarm) {
                        list[index].isChecked = true
                        self?.activeAlarmList.accept(list)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        activeAlarmList
            .compactMap { [weak self] in self?.configureDataSource($0) }
            .bind(to: activeDataSource)
            .disposed(by: disposeBag)

        sharedAlarmList
            .compactMap { [weak self] in self?.configureDataSource($0)}
            .bind(to: sharedDataSource)
            .disposed(by: disposeBag)
        
        activeAlarmList
            .map { $0.filter { $0.isChecked == false } }
            .map { $0.count }
            .bind(to: activeBadgeCount)
            .disposed(by: disposeBag)

        sharedAlarmList
            .map { $0.filter { $0.isChecked == false } }
            .map { $0.count }
            .bind(to: sharedBadgeCount)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(activeDataSource, sharedDataSource)
            .subscribe(onNext: { [weak self] activeDS, shareDS in
                if self?.currentAlarm.value == .active {
                    self?.currentDataSource.accept(activeDS)
                } else {
                    self?.currentDataSource.accept(shareDS)
                }
            })
            .disposed(by: disposeBag)

        tappedActive
            .subscribe(onNext: { [weak self] _ in
                self?.currentAlarm.accept(.active)
            })
            .disposed(by: disposeBag)
        
        tappedShare
            .subscribe(onNext: { [weak self] _ in
                self?.currentAlarm.accept(.share)
            })
            .disposed(by: disposeBag)
        
        currentAlarm
            .subscribe(onNext: { [weak self] type in
                if type == .active {
                    self?.currentDataSource.accept(self?.activeDataSource.value ?? [])
                } else {
                    self?.currentDataSource.accept(self?.sharedDataSource.value ?? [])
                }
            })
            .disposed(by: disposeBag)
    }
    
    func configureDataSource(_ alarmList: [Alarm]) -> [AlarmSectionModel] {
        alarmList.forEach { print($0)}
        
        var alarmSection = [AlarmSectionModel]()
        var todayItems = [AlarmItem]()
        var yesterdayItems = [AlarmItem]()
        var weekItems = [AlarmItem]()
        var monthItems = [AlarmItem]()
        var beforeItems = [AlarmItem]()
    
        for alarm in alarmList {
            guard let date = alarm.createdDate else { continue }
            
            if date.isInToday {
                todayItems.append(AlarmItem.init(alarm: alarm))
            } else if date.isInYesterday {
                yesterdayItems.append(AlarmItem.init(alarm: alarm))
            } else if date.isInThisWeek {
                weekItems.append(AlarmItem.init(alarm: alarm))
            } else if date.isInThisMonth {
                monthItems.append(AlarmItem.init(alarm: alarm))
            } else {
                beforeItems.append(AlarmItem.init(alarm: alarm))
            }
        }
        
        if !todayItems.isEmpty {
            let section: AlarmSectionModel = .TodaySection(title: "오늘", items: todayItems)
            alarmSection.append(section)
        }
        if !yesterdayItems.isEmpty {
            let section: AlarmSectionModel = .YesterdaySection(title: "어제", items: yesterdayItems)
            alarmSection.append(section)
        }
        if !weekItems.isEmpty {
            let section: AlarmSectionModel = .WeekSection(title: "이번주", items: weekItems)
            alarmSection.append(section)
        }
        if !monthItems.isEmpty {
            let section: AlarmSectionModel = .MonthSection(title: "이번달", items: monthItems)
            alarmSection.append(section)
        }
        if !beforeItems.isEmpty {
            let section: AlarmSectionModel = .BeforeSection(title: "이전활동", items: beforeItems)
            alarmSection.append(section)
        }

        return alarmSection
   }
}



enum AlarmSectionModel {
    case TodaySection(title: String, items: [AlarmItem])
    case YesterdaySection(title: String, items: [AlarmItem])
    case WeekSection(title: String, items: [AlarmItem])
    case MonthSection(title: String, items: [AlarmItem])
    case BeforeSection(title: String, items: [AlarmItem])
}

enum AlarmItem: IdentifiableType, Equatable {
    typealias Identity = Int64
    var identity: Identity {
        switch self {
        case let .ArriveItem(alarm): return alarm.id
        case let .DepartureItem(alarm): return alarm.id
        case let .ShareItem(alarm): return alarm.id
        }
    }
    
    case ArriveItem(alarm: Alarm)
    case DepartureItem(alarm: Alarm)
    case ShareItem(alarm: Alarm)
    
    init(alarm: Alarm) {
        switch alarm.type {
        case .arrive: self = .ArriveItem(alarm: alarm)
        case .departure: self = .DepartureItem(alarm: alarm)
        case .share: self = .ShareItem(alarm: alarm)
        case .date: self = .ArriveItem(alarm: alarm)
        }
    }
}

extension AlarmSectionModel: AnimatableSectionModelType {
    
    typealias Identify = String
    typealias Item = AlarmItem
    
    var identity: String {
        switch self {
        case let .TodaySection(title, _): return title
        case let .YesterdaySection(title, _): return title
        case let .WeekSection(title, _): return title
        case let .MonthSection(title, _): return title
        case let .BeforeSection(title, _): return title
        }
    }
    
    var items: [AlarmItem] {
        switch self {
        case .TodaySection(title: _, items: let items):
            return items.map { $0 }
        case .YesterdaySection(_, let items):
            return items.map { $0 }
        case .WeekSection(_, let items):
            return items.map { $0 }
        case .MonthSection(_, let items):
            return items.map { $0 }
        case .BeforeSection(_, let items):
            return items.map { $0 }
        }
    }
    
    init(original: AlarmSectionModel, items: [Item]) {
        switch original {
        case let .TodaySection(title: title, items: _):
            self = .TodaySection(title: title, items: items)
        case let .YesterdaySection(title, items: _):
            self = .YesterdaySection(title: title, items: items)
        case let .WeekSection(title, items: _):
            self = .WeekSection(title: title, items: items)
        case let .MonthSection(title, items: _):
            self = .MonthSection(title: title, items: items)
        case let .BeforeSection(title, items: _):
            self = .BeforeSection(title: title, items: items)
        }
    }
}


extension AlarmSectionModel {
    var title: String {
        switch self {
        case .TodaySection(title: let title, _):
            return title
        case .YesterdaySection(let title, _):
            return title
        case .WeekSection(let title, _):
            return title
        case .MonthSection(let title, _):
            return title
        case .BeforeSection(let title, _):
            return title
        }
    }
}
