//
//  GGUserDefault.swift
//  GotGam
//
//  Created by 손병근 on 2020/04/26.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreLocation

enum GGUserDefaultKey: String{
    case location = "GGUSERDEFAULT_KEY_LOCATION"
    case userID = "GGUSERDEFAULT_KEY_USER_ID"
    case isLogined = "GGUSERDEFAULT_IS_LOGINED"
    case userToken = "GGUSERDEFAULT_USER_TOKEN"
    case nickname = "GGUSERDEFAULT_NICKNAME"
}

// MARK: - GGUserDefaultProtocol
protocol GGUserDefaultProtocol{
    // MARK: Set
    func set(_ value: Int, forDefines: GGUserDefaultKey)
    func set(_ value: Float, forDefines: GGUserDefaultKey)
    func set(_ value: Bool, forDefines: GGUserDefaultKey)
    func set(_ value: Any?, forDefines: GGUserDefaultKey)
    
    // MARK: Get
    func integer(forDefines: GGUserDefaultKey) -> Int
    func float(forDefines: GGUserDefaultKey) -> Float
    func bool(forDefines: GGUserDefaultKey) -> Bool
    func string(forDefines: GGUserDefaultKey) -> String?
}

extension UserDefaults: GGUserDefaultProtocol{
    // MARK: Set
    func set(_ value: Int, forDefines: GGUserDefaultKey) {
        set(value, forKey: forDefines.rawValue)
        synchronize()
    }
    
    func set(_ value: Float, forDefines: GGUserDefaultKey) {
        set(value, forKey: forDefines.rawValue)
        synchronize()
    }
    
    func set(_ value: Bool, forDefines: GGUserDefaultKey) {
        set(value, forKey: forDefines.rawValue)
        synchronize()
    }
    
    func set(_ value: Any?, forDefines: GGUserDefaultKey) {
        set(value, forKey: forDefines.rawValue)
        synchronize()
    }
    
    
    // MARK: Get
    func integer(forDefines: GGUserDefaultKey) -> Int {
        return integer(forKey: forDefines.rawValue)
    }
    
    func float(forDefines: GGUserDefaultKey) -> Float {
        return float(forKey: forDefines.rawValue)
    }
    
    func bool(forDefines: GGUserDefaultKey) -> Bool {
        return bool(forKey: forDefines.rawValue)
    }
    
    func string(forDefines: GGUserDefaultKey) -> String? {
        return string(forKey: forDefines.rawValue)
    }
    
    func object(forDefines: GGUserDefaultKey) -> Any? {
        return object(forKey: forDefines.rawValue)
    }
    
    func array(forDefines: GGUserDefaultKey) -> [Any]? {
        return array(forKey: forDefines.rawValue)
    }
}

extension UserDefaults{
    var location: CLLocationCoordinate2D {
        if let dictionary = object(forDefines: .location) as? [String: CLLocationDegrees] {
            return CLLocationCoordinate2D.init(dict: dictionary)
        }
        return CLLocationCoordinate2D(latitude: 37.538778, longitude: 126.89520)
    }
}
