//
//  ManagedGot+CoreDataClass.swift
//  
//
//  Created by 손병근 on 2020/05/04.
//
//

import Foundation
import CoreData
import CoreLocation

@objc(ManagedGot)
public class ManagedGot: NSManagedObject {
//    var id: Int64?
//    var title: String
//    var createedDate: Date
//    var dueDate: Date
//    var memo : String?
//    var tag : String?
//    var location: CLLocationCoordinate2D
//    var isFinished: Bool
//    var address: String?
    func toGot() -> Got{
        return Got(title: title!, dueDate: dueDate!, memo: memo!, tag: tag!, location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    
    func fromGot(got: Got){
        self.id = got.id!
        self.title = got.title
        self.createdDate = got.createedDate
        self.dueDate = got.dueDate
        self.memo = got.memo
        self.tag = got.tag
        self.latitude = got.location.latitude
        self.longitude = got.location.longitude
        self.isFinished = got.isFinished
        self.address = got.address
    }
}
