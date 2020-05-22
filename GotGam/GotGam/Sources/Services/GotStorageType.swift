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
    func create(tag: Tag) -> Observable<Tag>
    
    @discardableResult
    func fetchGotList() -> Observable<[Got]>
    
    @discardableResult
    func fetchTagList() -> Observable<[Tag]>

    @discardableResult
    func fetchGot(id: Int64) -> Observable<Got>
    
    @discardableResult
    func fetchTag(hex: String) -> Observable<Tag>
    
    @discardableResult
    func updateGot(gotToUpdate: Got) -> Observable<Got>
    
    @discardableResult
    func updateTag(_ tag: Tag) -> Observable<Tag>
    
    @discardableResult
    func update(tag origin: Tag, to updated: Tag) -> Observable<Tag>
    
    @discardableResult
    func deleteGot(id: Int64) -> Observable<Got>
    
    @discardableResult
    func deleteGot(got: Got) -> Observable<Got>
    
    @discardableResult
    func deleteTag(hex: String) -> Observable<Tag>
    
    @discardableResult
    func deleteTag(tag: Tag) -> Observable<Tag>
    
}
