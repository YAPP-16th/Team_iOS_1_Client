//
//  AlarmStorageType.swift
//  GotGam
//
//  Created by woong on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

enum AlarmStorageError: Error{
    case fetchError(String)
    case createError(String)
    case updateError(String)
    case deleteError(String)
}

protocol AlarmStorageType {
    
    @discardableResult
    func createAlarm(_ alarm: Alarm) -> Observable<Alarm>
    
    @discardableResult
    func fetchAlarmList() -> Observable<[Alarm]>
    
    @discardableResult
    func fetchAlarm(id: NSManagedObjectID) -> Observable<Alarm>
    
//    @discardableResult
//    func fetchAlarm(date: Date) -> Observable<[Alarm]>
    
    @discardableResult
    func updateAlarm(to alarm: Alarm) -> Observable<Alarm>
    
    @discardableResult
    func deleteAlarm(id: NSManagedObjectID) -> Observable<Alarm>
    
    @discardableResult
    func deleteAlarm(alarm: Alarm) -> Observable<Alarm>
    
}

