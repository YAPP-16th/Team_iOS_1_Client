//
//  TabBarViewModel.swift
//  GotGam
//
//  Created by woong on 18/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TabBarViewModel: CommonViewModel {
    
//    func switchTab(to index: Int) {
//        sceneCoordinator.switchTab(to: index).asObservable()
//        
//    }
    
    func updateBadge() {
        storage.fetchAlarmList()
            .subscribe(onNext: { [weak self] alarmList in
                let badgeCount = alarmList.filter { $0.isChecked == false }.count
                
                self?.alarmBadgeCount.accept(badgeCount)
            })
            .disposed(by: disposeBag)
    }
    
    var alarmBadgeCount = BehaviorRelay<Int>(value: 0)
    
    override init(sceneCoordinator: SceneCoordinatorType) {
        super.init(sceneCoordinator: sceneCoordinator)
        updateBadge()
//        alarmStorage.fetchAlarmList()
//            .subscribe(onNext: { [weak self] alarmList in
//                let badgeCount = alarmList.filter { $0.isChecked == false }.count
//
//                self?.alarmBadgeCount.accept(badgeCount)
//            })
//            .disposed(by: disposeBag)
    }
}
