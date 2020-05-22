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
    var checkAlarm: PublishSubject<Alarm> { get set }
}

protocol AlarmViewModelOutputs {
    var currentAlarm: BehaviorSubject<AlarmCategoryType> { get }
    var activeBadgeCount: BehaviorRelay<Int> { get }
    var sharedBadgeCount: BehaviorRelay<Int> { get }
    var activeDataSource: BehaviorRelay<[AlarmSectionModel]> { get }
    var sharedDataSource: BehaviorRelay<[AlarmSectionModel]> { get }
}

protocol AlarmViewModelType {
    var inputs: AlarmViewModelInputs { get }
    var outputs: AlarmViewModelOutputs { get }
}


class AlarmViewModel: CommonViewModel, AlarmViewModelType, AlarmViewModelInputs, AlarmViewModelOutputs {
    
    
    // MARK: Inputs
    
    func fetchAlarmList() {
        alarmStorage.fetchAlarmList()
            .subscribe(onNext: { [weak self] alarmList in
                //self?.alarmList.onNext(alarms)
                let activeAlarmList = alarmList.filter { $0.type != .share }
                self?.activeAlarmList.accept(activeAlarmList)
                //self?.activeAlarmList.onNext()
                
                let sharedAlarmList = alarmList.filter { $0.type == .share }
                self?.sharedAlarmList.accept(sharedAlarmList)
            })
            .disposed(by: disposeBag)
    }
    
    var checkAlarm = PublishSubject<Alarm>()
    
    // MARK: Outputs
    
    var currentAlarm = BehaviorSubject<AlarmCategoryType>(value: .active)
    var activeBadgeCount = BehaviorRelay<Int>(value: 0)
    var sharedBadgeCount = BehaviorRelay<Int>(value: 0)
    var activeDataSource = BehaviorRelay<[AlarmSectionModel]>(value: [])
    var sharedDataSource = BehaviorRelay<[AlarmSectionModel]>(value: [])
    
    
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
    
    var inputs: AlarmViewModelInputs { return self }
    var outputs: AlarmViewModelOutputs { return self }
    var alarmStorage: AlarmStorageType!
    var gotStorage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, alarmStorage: AlarmStorageType, gotStorage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.alarmStorage = alarmStorage
        self.gotStorage = gotStorage
        
//        gotStorage.fetchGotList()
//            .compactMap { [weak self] in self?.makeAlarm($0) }
//            .subscribe(onNext: { [weak self] alarmList in
//                for alarm in alarmList {
//                    self?.alarmStorage.createAlarm(alarm)
//
//                }
//            })
//            .disposed(by: disposeBag)
        
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
        
        
//        alarmList
//            .subscribe(onNext: { [unowned self] alarmList in
//
//                let activeCount = activeAlarmList.filter { $0.isChecked == false }.count
//                self.activeDataSource.accept( self.configureDataSource(activeAlarmList))
//                self.activeBadgeCount.accept(activeCount)
//
//
//
//                let sharedCount = sharedAlarmList.filter { $0.isChecked == false }.count
//                self.sharedDataSource.accept(self.configureDataSource(sharedAlarmList))
//                self.sharedBadgeCount.accept(sharedCount)
//            })
//            .disposed(by: disposeBag)
//
//        storage.createAlarm(Alarm(id: Int64(arc4random()), type: .arrive, createdDate: Date(), checkedDate: nil, isChecked: false, got: <#T##Got?#>))
        
        //storage.fetchAlarmList()
        
    }
    
    func configureDataSource(_ alarmList: [Alarm]) -> [AlarmSectionModel] {
        
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
        } else if !yesterdayItems.isEmpty {
            let section: AlarmSectionModel = .YesterdaySection(title: "어제", items: yesterdayItems)
            alarmSection.append(section)
        } else if !weekItems.isEmpty {
            let section: AlarmSectionModel = .WeekSection(title: "이번주", items: weekItems)
            alarmSection.append(section)
        } else if !monthItems.isEmpty {
            let section: AlarmSectionModel = .WeekSection(title: "이번달", items: monthItems)
            alarmSection.append(section)
        } else {
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

enum AlarmItem: Equatable {
    case ArriveItem(alarm: Alarm)
    case DepartureItem(alarm: Alarm)
    case ShareItem(alarm: Alarm)
    
    init(alarm: Alarm) {
        switch alarm.type {
        case .arrive: self = .ArriveItem(alarm: alarm)
        case .departure: self = .DepartureItem(alarm: alarm)
        case .share: self = .ShareItem(alarm: alarm)
        }
    }
}

extension AlarmSectionModel: SectionModelType {
    
    typealias Item = AlarmItem
    
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
        case .YesterdaySection(let title, let items):
            self = .YesterdaySection(title: title, items: items)
        case .WeekSection(let title, let items):
            self = .WeekSection(title: title, items: items)
        case .MonthSection(let title, let items):
            self = .MonthSection(title: title, items: items)
        case .BeforeSection(let title, let items):
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
