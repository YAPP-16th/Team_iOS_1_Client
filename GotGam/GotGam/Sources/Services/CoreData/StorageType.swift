//
//  StorageType.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/31.
//  Copyright © 2020 손병근. All rights reserved.
//

import CoreData
import RxSwift

enum StorageError: Error{
    case create(String)
    case read(String)
    case update(String)
    case delete(String)
    case sync(String)
}

protocol StorageType: TaskStorageType, TagStorageType, FrequentsStorageType, SearchStorageType{
    
}
