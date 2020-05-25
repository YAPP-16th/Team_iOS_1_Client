//
//  FrequentsStorageType.swift
//  GotGam
//
//  Created by 김삼복 on 23/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

protocol FrequentsStorageType{
	@discardableResult
	func createFrequents(frequent: Frequent) -> Observable<Frequent>
	
	@discardableResult
	func fetchFrequents() -> Observable<[Frequent]>
	
//	@discardableResult
//	func fetchFrequents(name: String) -> Observable<Frequent>
//
//	@discardableResult
//	func updateFrequents(Frequent: Frequent) -> Observable<Frequent>
//
//	@discardableResult
//	func deleteFrequents(name: String) -> Observable<Frequent>
//
//	@discardableResult
//	func deleteFrequents(Frequent: Frequent) -> Observable<Frequent>
}
