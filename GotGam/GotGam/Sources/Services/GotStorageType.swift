//
//  TaskStorageType.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

enum GotStorageError: Error{
    case fetchError(String)
    case createError(String)
    case updateError(String)
    case deleteError(String)
}

protocol GotStorageType {
    
    @discardableResult
    func createGot(gotToCreate: Got) -> Observable<Got>
    
    @discardableResult
    func fetchGotList() -> Observable<[Got]>
    
    @discardableResult
    func fetchTagList() -> Observable<[Tag]>

    @discardableResult
    func fetchGot(id: Int64) -> Observable<Got>
    
    @discardableResult
    func updateGot(gotToUpdate: Got) -> Observable<Got>
    
    @discardableResult
    func deleteGot(id: Int64) -> Observable<Got>
    
}
