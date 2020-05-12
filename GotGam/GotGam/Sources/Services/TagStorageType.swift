//
//  TagStorageType.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/12.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

enum TagStorageError: Error{
    case fetchError(String)
    case createError(String)
    case updateError(String)
    case deleteError(String)
}

protocol TagStorageType{
    @discardableResult
    func fetchTagList() -> Observable<[Tag]>
    
    @discardableResult
    func createTag(tagToCreate: Tag) -> Observable<Tag>
}
