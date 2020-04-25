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
      func createMemo(title: String) -> Observable<Got>
      
      @discardableResult
      func memoList() -> Observable<[Got]>
      
      @discardableResult
      func update(title: Got, updatedtitle: String) -> Observable<Got>
      
      @discardableResult
      func delete(title: Got) -> Observable<Got>
    
}
