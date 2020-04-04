//
//  CommonViewModel.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

class CommonViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    let sceneCoordinator: SceneCoordinatorType
    let storage: GotStorageType
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        self.sceneCoordinator = sceneCoordinator
        self.storage = storage
    }
}
