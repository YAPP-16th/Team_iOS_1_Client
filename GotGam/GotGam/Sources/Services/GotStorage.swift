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
      Got(title:"1번", latitude: 100.0 , longitude: 100.0 , isDone: false)
        ]
        
        private lazy var store = BehaviorSubject<[Got]>(value: list)
       
        
        @discardableResult
        func createMemo(title: String) -> Observable<Got> {
            let memo = Got(title: title)
            list.insert(memo, at: 0)
            
            store.onNext(list)
            
            return Observable.just(memo)
        }
        
        @discardableResult
        func memoList() -> Observable<[Got]> {
            return store
        }
        
        
        @discardableResult
        func update(title: Got, updatedtitle: String) -> Observable<Got> {
         let updated = Got(original: title, updatedTitle: updatedtitle)
            
            
            if let index = list.firstIndex(where: { $0 == title}) {
                list.remove(at: index)
                list.insert(updated, at: index)
            }
            
            
            store.onNext(list)
            
            
            return Observable.just(updated)
        }
        
        
        @discardableResult
        func delete(title: Got) -> Observable<Got> {
            if let index = list.firstIndex(where: { $0 == title}) {
                list.remove(at: index)
            }
    
            store.onNext(list)
    
            return Observable.just(title)
        }
}
