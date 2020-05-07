//
//  MapViewModel.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class MapViewModel: CommonViewModel {
    enum SeedState{
        case none
        case seeding
        case adding
    }
    var tag: [String] = ["맛집", "할일", "데이트할 곳", "일상", "집에서 할 일","학교에서 할 일"]
    
    var seedState = BehaviorSubject<SeedState>(value: .none)
    
    func showAddVC() {
        let got = Got(title: "멍게비빔밥", id: 1, content: "test", tag: "#123121", latitude: 0, longitude: 0, isDone: false)
        let addVM = AddPlantViewModel(sceneCoordinator: sceneCoordinator, storage: storage, got: got)
        sceneCoordinator.transition(to: .add(addVM), using: .fullScreen, animated: true)
        
    }
}
