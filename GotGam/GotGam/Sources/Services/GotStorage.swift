//
//  TaskStorage.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class GotStorage: GotStorageType {
   
   private var list = [
      GotGam(title:"1번", latitude: 100.0 , longitude: 100.0 , isDone: false,  insertDate: Date().addingTimeInterval(-10))
        ]
        
        private lazy var store = BehaviorSubject<[GotGam]>(value: list)
       
        
        @discardableResult
        func createMemo(title: String) -> Observable<GotGam> {
            let memo = GotGam(title: title)
            list.insert(memo, at: 0)
            
            store.onNext(list)
            
            return Observable.just(memo)
        }
        
        @discardableResult
        func memoList() -> Observable<[GotGam]> {
            return store.title
        }
        
        
        @discardableResult
        func update(original: GotGam, updatedTitle: String) -> Observable<GotGam> {
            let updated = GotGam(original: memo, updatedTitle: title)
            
            
            if let index = list.firstIndex(where: { $0 == memo}) {
                list.remove(at: index)
                list.insert(updated, at: index)
            }
            
            
            store.onNext(list)
            
            
            return Observable.just(updated)
        }
        
        
        @discardableResult
        func delete(title: GotGam) -> Observable<GotGam> {
            if let index = list.firstIndex(where: { $0 == memo}) {
                list.remove(at: index)
            }
    
            store.onNext(list)
    
            return Observable.just(memo)
        }
        
}
