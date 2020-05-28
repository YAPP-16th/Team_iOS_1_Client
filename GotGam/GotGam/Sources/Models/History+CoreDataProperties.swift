//
//  History+CoreDataProperties.swift
//  GotGam
//
//  Created by 김삼복 on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
//

import Foundation
import CoreData

//enum HistoryType: Int {
//	case search = 0
//	case got
//	
//	var image: UIImage {
//		switch self {
//			case .search:
//			UIImage(named: "icSearch222")
//			default:
//			<#code#>
//		}
//	}
//}

extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var keyword: String?
	
}
