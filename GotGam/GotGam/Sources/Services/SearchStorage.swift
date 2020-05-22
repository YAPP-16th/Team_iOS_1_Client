//
//  SearchStorage.swift
//  GotGam
//
//  Created by 김삼복 on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class SearchStorage: SearchStorageType{
	private let context = DBManager.share.context
	
	func createKeyword(keyword: String) -> Observable<String> {
		let history = History(context: self.context)
		history.keyword = keyword
		do{
			try self.context.save()
			return .just(keyword)
		}catch let error as NSError{
			print("history를 생성할 수 없습니다. error: ", error.userInfo)
			return .error(error)
		}
	}
	
	func fetchKeyword() -> Observable<[String]> {
		let fetchRequest = NSFetchRequest<History>(entityName: "History")
		do {
			let results = try self.context.fetch(fetchRequest)
			var keywords: [String] = []
			for h in results{
				keywords.append(h.keyword!)
			}
			return .just(keywords)
		}catch let error as NSError{
			print("history를 읽을 수 없습니다. error: ", error.userInfo)
			return .error(error)
		}
		
		
	}
	
	
}
