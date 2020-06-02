//
//  Scene+instantiate.swift
//  GotGam
//
//  Created by woong on 23/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

extension Scene {
    var target: UIViewController {
		switch self {
			case .map:        return instantiate(from: "Map")
			case .list:       return instantiate(from: "List")
			case .gotBox:      return instantiate(from: "List")
			case .shareList:   return instantiate(from: "List")
			case .add:        return instantiate(from: "Map")
            case .addMap:      return instantiate(from: "Map")
			case .setTag:      return instantiate(from: "Map")
			case .createTag:   return instantiate(from: "Map")
			case .login:       return instantiate()
			case .tabBar:      return instantiate(from: "Main")
			case .settingAlarm: return instantiate(from: "Setting")
			case .settingOther: return instantiate(from: "Setting")
			case .settingPlace: return instantiate(from: "Setting")
			case .settingLogin: return instantiate(from: "Setting")
			case .searchBar:    return instantiate(from: "SearchBar")
			case .frequents:    return instantiate(from: "Setting")
			case .frequentsSearch:    return instantiate(from: "Setting")
			case .frequentsMap:		return instantiate(from: "Setting")
			case .settingDetail:	return instantiate(from: "Setting")
            case .tutorial: return instantiate(from: "Tutorial")
		}
    }
}

