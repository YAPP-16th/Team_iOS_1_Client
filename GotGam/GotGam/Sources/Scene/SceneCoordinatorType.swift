//
//  SceneCoordinatorType.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

protocol SceneCoordinatorType {
    
    @discardableResult
    func transition(to scene: Scene, using style: Transition, animated: Bool) -> Completable
    
    @discardableResult
    func close(animated: Bool, completion: (() -> Void)?) -> Completable
    
    @discardableResult
    func pop(animated: Bool) -> Completable
    
    @discardableResult
    func createTabBar() -> Completable
}
