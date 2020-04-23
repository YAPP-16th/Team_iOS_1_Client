//
//  TaskStorageType.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

protocol GotStorageType {
    @discardableResult
    func createMemo(title: String) -> Observable<GotGam>
    
    @discardableResult
    func memoList() -> Observable<[GotGam]>
    
    @discardableResult
    func update(title: GotGam, updatedtitle: String) -> Observable<GotGam>
    
    @discardableResult
    func delete(title: GotGam) -> Observable<GotGam>
}
