//
//  SearchStorageType.swift
//  GotGam
//
//  Created by 김삼복 on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

protocol SearchStorageType{
	@discardableResult
	func createKeyword(history: History) -> Observable<History>
	
	@discardableResult
	func fetchKeyword() -> Observable<[History]>
	
	@discardableResult
	func deleteKeyword(historyObjectId: NSManagedObjectID) -> Completable
}
