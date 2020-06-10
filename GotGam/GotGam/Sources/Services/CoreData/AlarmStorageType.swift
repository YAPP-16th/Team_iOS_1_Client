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
    func createAlarm(_ alarm: ManagedAlarm) -> Observable<ManagedAlarm>
    
    @discardableResult
    func fetchAlarmList() -> Observable<[ManagedAlarm]>
    
    @discardableResult
    func fetchAlarm(id: NSManagedObjectID) -> Observable<ManagedAlarm>
    
//    @discardableResult
//    func fetchAlarm(date: Date) -> Observable<[Alarm]>
    
    @discardableResult
    func updateAlarm(to alarm: ManagedAlarm) -> Observable<ManagedAlarm>
    
    @discardableResult
    func deleteAlarm(id: NSManagedObjectID) -> Observable<ManagedAlarm>
    
    @discardableResult
    func deleteAlarm(alarm: ManagedAlarm) -> Observable<ManagedAlarm>
    
}

