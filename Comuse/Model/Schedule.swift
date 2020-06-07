//
//  Schedule.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/29.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import ObjectMapper
import RxSwift
import RealmSwift
class Schedule: Object, Mappable {
    @objc dynamic var day: Int              = 0     // 요일 인덱스는 월(0) ~ 일(6) 까지이다.
    @objc dynamic var classPlace: String    = ""    // TimeTable 의 Schedule 에서 생성될 때 classTitle 하단에 표시되는 문자열
                                                    // 현재는 쓰지 않아 ""로 저장하지만 추후에 작성자의 이름을 저장할까 고려중
    @objc dynamic var professorName: String = ""    // 작성자의 email 저장. TimeTable 내에서 touchUp 되었을 때 자신이 작성한 Schedule 인지 확인하기 위해 사용한다.
    @objc dynamic var classTitle: String    = ""    // Schedule 의 Title, TimeTable 내에서 생성될 때 Schedule 내에 표시된다.
    
    @objc dynamic var startTimeHour: Int    = 0     // 시작 시각
    @objc dynamic var startTimeMinute: Int  = 0
    
    @objc dynamic var endTimeHour: Int      = 0     // 종료 시각
    @objc dynamic var endTimeMinute: Int    = 0
    
    @objc dynamic var key: String           = ""    // schedule key @Primary
    
    override static func primaryKey() -> String? {
        return "key"
    }
    required init?(map: Map) {
        if let day = map.JSON["day"] as? Int {
            self.day = day
        } else { return nil }
        if let startTimeHour = map.JSON["startTimeHour"] as? Int {
            self.startTimeHour = startTimeHour
        } else { return nil }
        if let startTimeMinute = map.JSON["startTimeMinute"] as? Int {
            self.startTimeMinute = startTimeMinute
        } else { return nil }
        if let endTimeHour = map.JSON["endTimeHour"] as? Int {
            self.endTimeHour = endTimeHour
        } else { return nil }
        if let endTimeMinute = map.JSON["endTimeMinute"] as? Int {
            self.endTimeMinute = endTimeMinute
        } else { return nil }
        if let professorName = map.JSON["professorName"] as? String {
            self.professorName = professorName
        } else { return nil }
        if let classTitle = map.JSON["classTitle"] as? String {
            self.classTitle = classTitle
        } else { return nil }
        self.classPlace = ""
    }
    
    required init() {
        
    }
    init(day: Int, classPlace: String, professorName: String, classTitle: String, startTimeHour: Int, startTimeMinute: Int, endTimeHour: Int, endTimeMinute: Int, key: String) {
        self.day = day
        self.classPlace = classPlace
        self.professorName = professorName
        self.classTitle = classTitle
        self.startTimeHour = startTimeHour
        self.startTimeMinute = startTimeMinute
        self.endTimeHour = endTimeHour
        self.endTimeMinute = endTimeMinute
        self.key = key
    }
    func mapping(map: Map) {
        day<-map["day"]
        startTimeHour<-map["startTimeHour"]
        startTimeMinute<-map["startTimeMinute"]
        endTimeHour<-map["endTimeHour"]
        endTimeMinute<-map["endTimeMinute"]
        classPlace<-map["classPlace"]
        professorName<-map["professorName"]
        classTitle<-map["classTitle"]
    }
}


