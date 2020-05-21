//
//  AlarmViewModel.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

protocol AlarmViewModelInputs {
    
}

protocol AlarmViewModelOutputs {
    var dataSource: Observable<[AlarmSectionModel]> { get }
}

protocol AlarmViewModelType {
    var inputs: AlarmViewModelInputs { get }
    var outputs: AlarmViewModelOutputs { get }
}


class AlarmViewModel: CommonViewModel, AlarmViewModelType, AlarmViewModelInputs, AlarmViewModelOutputs {
    
    
    // MARK: Inputs
    
    // MARK: Outputs
    
    var dataSource = Observable<[AlarmSectionModel]>.just([])
    

    var inputs: AlarmViewModelInputs { return self }
    var outputs: AlarmViewModelOutputs { return self }
    var storage: AlarmStorageType!
    
    //let got = Got(id: Int64(arc4random()), tag: nil, title: "멍게", content: "test", latitude: .zero, longitude: .zero, radius: .zero, isDone: false, place: "맛집", insertedDate: Date())
    
    init(sceneCoordinator: SceneCoordinatorType, storage: AlarmStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
        
        //storage.createAlarm(Alarm(id: Int64(arc4random()), type: .arrive, createdDate: Date(), checkedDate: nil, isChecked: false, got: <#T##Got?#>))
        
        //storage.fetchAlarmList()
        
        dataSource = configureDataSource()
    }
    
    func configureDataSource() -> Observable<[AlarmSectionModel]> {
       return Observable<[AlarmSectionModel]>.just([
           .TodaySection(title: "오늘", items: [
                //.ArriveItem(got: self.got)
           ]),
           .YesterdaySection(title: "어제", items: []),
           .WeekSection(title: "이번주", items: []),
           .MonthSection(title: "이번달", items: [])
        ])
   }
}



enum AlarmSectionModel {
    case TodaySection(title: String, items: [AlarmItem])
    case YesterdaySection(title: String, items: [AlarmItem])
    case WeekSection(title: String, items: [AlarmItem])
    case MonthSection(title: String, items: [AlarmItem])
}

enum AlarmItem {
    case ArriveItem(got: Got)
    case LeaveItem
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
        }
    }
}
