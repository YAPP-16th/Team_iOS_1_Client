//
//  SearchStorageType.swift
//  GotGam
//
//  Created by 김삼복 on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

protocol SearchStorageType{
	@discardableResult
	func createKeyword(keyword: String) -> Observable<String>
	
	@discardableResult
	func fetchKeyword() -> Observable<[String]>
	
	@discardableResult
	func deleteKeyword(keyword: String) -> Observable<String>
}
