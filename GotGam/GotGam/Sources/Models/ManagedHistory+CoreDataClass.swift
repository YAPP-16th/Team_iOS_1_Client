//
//  ManagedHistory+CoreDataClass.swift
//  GotGam
//
//  Created by 김삼복 on 10/06/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedHistory)
public class ManagedHistory: NSManagedObject {
	func toHistory() -> History {
		var history = History(keyword: keyword)
		history.objectId = objectID
		return history
	}
	
	func fromHistory(history: History) {
		self.keyword = history.keyword
	}
}
