//
//  Alarm.swift
//  GotGam
//
//  Created by woong on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

enum AlarmType: Int16 {
    case arrive = 0
    case departure = 1
    case share = 2
    case date = 3
}

struct Alarm: Equatable {
    var id: Int64
    var type: AlarmType
    var createdDate: Date?
    var isChecked: Bool
    var checkedDate: Date?
    var got: Got?
    
    init(
        id: Int64,
        type: AlarmType,
        createdDate: Date? = Date(),
        checkedDate: Date? = nil,
        isChecked: Bool = false,
        got: Got?
    ) {
        self.id = id
        self.type = type
        self.createdDate = createdDate
        self.checkedDate = checkedDate
        self.isChecked = isChecked
        self.got = got
    }
}

//
//YesterdaySection(
//    title: "어제", items: [
//        GotGam.AlarmItem.ArriveItem(alarm: GotGam.Alarm(id: 244913826, type: GotGam.AlarmType.arrive, createdDate: Optional(2020-05-27 11:32:53 +0000), isChecked: true, checkedDate: nil, got: Optional(GotGam.Got(id: Optional(1549160322), createdDate: Optional(2020-05-27 11:32:28 +0000), title: Optional("Rd"), latitude: Optional(37.566407799201336), longitude: Optional(126.97787363088995), radius: Optional(100.0), place: Optional("서울 중구 태평로1가 31"), arriveMsg: Optional("도도착함"), deparetureMsg: Optional("떠남"), insertedDate: nil, onArrive: true, onDeparture: true, onDate: false, tag: Optional([GotGam.Tag(name: "할일", hex: "#ff3b3b")]), isDone: false)))),
//        GotGam.AlarmItem.ArriveItem(alarm: GotGam.Alarm(id: 1604354600, type: GotGam.AlarmType.arrive, createdDate: Optional(2020-05-27 11:35:21 +0000), isChecked: true, checkedDate: nil, got: Optional(GotGam.Got(id: Optional(1046008635), createdDate: Optional(2020-05-27 11:30:35 +0000), title: Optional("0000"), latitude: Optional(37.566407799201336), longitude: Optional(126.97787363088995), radius: Optional(100.0), place: Optional("서울 중구 태평로1가 31"), arriveMsg: Optional("9999"), deparetureMsg: Optional(""), insertedDate: nil, onArrive: true, onDeparture: false, onDate: false, tag: Optional([]), isDone: false)))),
//        GotGam.AlarmItem.ArriveItem(alarm: GotGam.Alarm(id: 893890102, type: GotGam.AlarmType.arrive, createdDate: Optional(2020-05-27 11:35:21 +0000), isChecked: true, checkedDate: nil, got: Optional(GotGam.Got(id: Optional(1549160322), createdDate: Optional(2020-05-27 11:32:28 +0000), title: Optional("Rd"), latitude: Optional(37.566407799201336), longitude: Optional(126.97787363088995), radius: Optional(100.0), place: Optional("서울 중구 태평로1가 31"), arriveMsg: Optional("도도착함"), deparetureMsg: Optional("떠남"), insertedDate: nil, onArrive: true, onDeparture: true, onDate: false, tag: Optional([GotGam.Tag(name: "할일", hex: "#ff3b3b")]), isDone: false)))),
//        GotGam.AlarmItem.ArriveItem(alarm: GotGam.Alarm(id: 3458719854, type: GotGam.AlarmType.arrive, createdDate: Optional(2020-05-27 11:37:55 +0000), isChecked: true, checkedDate: nil, got: Optional(GotGam.Got(id: Optional(1046008635), createdDate: Optional(2020-05-27 11:30:35 +0000), title: Optional("0000"), latitude: Optional(37.566407799201336), longitude: Optional(126.97787363088995), radius: Optional(100.0), place: Optional("서울 중구 태평로1가 31"), arriveMsg: Optional("9999"), deparetureMsg: Optional(""), insertedDate: nil, onArrive: true, onDeparture: false, onDate: false, tag: Optional([]), isDone: false)))),
//        GotGam.AlarmItem.ArriveItem(alarm: GotGam.Alarm(id: 3357947500, type: GotGam.AlarmType.arrive, createdDate: Optional(2020-05-27 11:37:55 +0000), isChecked: false, checkedDate: nil, got: Optional(GotGam.Got(id: Optional(1549160322), createdDate: Optional(2020-05-27 11:32:28 +0000), title: Optional("Rd"), latitude: Optional(37.566407799201336), longitude: Optional(126.97787363088995), radius: Optional(100.0), place: Optional("서울 중구 태평로1가 31"), arriveMsg: Optional("도도착함"), deparetureMsg: Optional("떠남"), insertedDate: nil, onArrive: true, onDeparture: true, onDate: false, tag: Optional([GotGam.Tag(name: "할일", hex: "#ff3b3b")]), isDone: false))))])
//
//Expected it should return items: [
//    GotGam.AlarmItem.ArriveItem(alarm: GotGam.Alarm(id: 1604354600, type: GotGam.AlarmType.arrive, createdDate: Optional(2020-05-27 11:35:21 +0000), isChecked: true, checkedDate: nil, got: Optional(GotGam.Got(id: Optional(1046008635), createdDate: Optional(2020-05-27 11:30:35 +0000), title: Optional("0000"), latitude: Optional(37.566407799201336), longitude: Optional(126.97787363088995), radius: Optional(100.0), place: Optional("서울 중구 태평로1가 31"), arriveMsg: Optional("9999"), deparetureMsg: Optional(""), insertedDate: nil, onArrive: true, onDeparture: false, onDate: false, tag: Optional([]), isDone: false)))),
//GotGam.AlarmItem.ArriveItem(alarm: GotGam.Alarm(id: 893890102, type: GotGam.AlarmType.arrive, createdDate: Optional(2020-05-27 11:35:21 +0000), isChecked: true, checkedDate: nil, got: Optional(GotGam.Got(id: Optional(1549160322), createdDate: Optional(2020-05-27 11:32:28 +0000), title: Optional("Rd"), latitude: Optional(37.566407799201336), longitude: Optional(126.97787363088995), radius: Optional(100.0), place: Optional("서울 중구 태평로1가 31"), arriveMsg: Optional("도도착함"), deparetureMsg: Optional("떠남"), insertedDate: nil, onArrive: true, onDeparture: true, onDate: false, tag: Optional([GotGam.Tag(name: "할일", hex: "#ff3b3b")]), isDone: false)))),
//GotGam.AlarmItem.ArriveItem(alarm: GotGam.Alarm(id: 3458719854, type: GotGam.AlarmType.arrive, createdDate: Optional(2020-05-27 11:37:55 +0000), isChecked: true, checkedDate: nil, got: Optional(GotGam.Got(id: Optional(1046008635), createdDate: Optional(2020-05-27 11:30:35 +0000), title: Optional("0000"), latitude: Optional(37.566407799201336), longitude: Optional(126.97787363088995), radius: Optional(100.0), place: Optional("서울 중구 태평로1가 31"), arriveMsg: Optional("9999"), deparetureMsg: Optional(""), insertedDate: nil, onArrive: true, onDeparture: false, onDate: false, tag: Optional([]), isDone: false)))),
//GotGam.AlarmItem.ArriveItem(alarm: GotGam.Alarm(id: 3357947500, type: GotGam.AlarmType.arrive, createdDate: Optional(2020-05-27 11:37:55 +0000), isChecked: false, checkedDate: nil, got: Optional(GotGam.Got(id: Optional(1549160322), createdDate: Optional(2020-05-27 11:32:28 +0000), title: Optional("Rd"), latitude: Optional(37.566407799201336), longitude: Optional(126.97787363088995), radius: Optional(100.0), place: Optional("서울 중구 태평로1가 31"), arriveMsg: Optional("도도착함"), deparetureMsg: Optional("떠남"), insertedDate: nil, onArrive: true, onDeparture: true, onDate: false, tag: Optional([GotGam.Tag(name: "할일", hex: "#ff3b3b")]), isDone: false))))]
