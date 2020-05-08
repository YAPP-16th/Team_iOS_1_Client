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
    
    var got = Got(title: "멍게비빔밥 맛집", id: 1, insertedDate: Date(), content: "꼭 방문하기", tag: "#123123", latitude: .zero, longitude: .zero, isDone: false, place: "맛집")
    
    override init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator, storage: storage)
        
        dataSource = configureDataSource()
    }
    
    func configureDataSource() -> Observable<[AlarmSectionModel]> {
       return Observable<[AlarmSectionModel]>.just([
           .AlarmSection(title: "오늘", items: [
                .ArriveItem(got: self.got)
           ])
        ])
   }
}



enum AlarmSectionModel {
    case AlarmSection(title: String, items: [AlarmItem])
}

enum AlarmItem {
    case ArriveItem(got: Got)
    case LeaveItem
}

extension AlarmSectionModel: SectionModelType {
    
    typealias Item = AlarmItem
    
    var items: [AlarmItem] {
        switch self {
        case .AlarmSection(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: AlarmSectionModel, items: [Item]) {
        switch original {
        case let .AlarmSection(title: title, items: _):
            self = .AlarmSection(title: title, items: items)
        }
    }
}


extension AlarmSectionModel {
    var title: String {
        switch self {
        case .AlarmSection(title: let title, items: _):
            return title
        }
    }
}
