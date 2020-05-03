//
//  Schedule.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import ObjectMapper

struct Schedule {
    var day: Int
    var startTime: Time
    var endTime: Time
    var classPlace: String?
    var professorName: String
    var classTitle: String
    init(day: Int, startTime: Time, endTime: Time, professorName: String, classTitle: String) {
        self.day = day
        self.startTime = startTime
        self.endTime = endTime
        self.classPlace = nil
        self.professorName = professorName
        self.classTitle = classTitle
    }
    

}
//MARK: - JSON -> Schedule Methods
extension Schedule: Mappable {
    init?(map: Map) {
        self.day = map.JSON["day"] as! Int
        self.startTime = map.JSON["startTime"] as! Time
        self.endTime = map.JSON["endTime"] as! Time
        if let classPlace = map.JSON["classPlace"] as? String {
            self.classPlace = classPlace
        } else { self.classPlace = nil }
        self.professorName = map.JSON["professorName"] as! String
        self.classTitle = map.JSON["classTitle"] as! String
    }
    
    mutating func mapping(map: Map) {
        day<-map["day"]
        startTime<-map["startTime"]
        endTime<-map["endTime"]
        classPlace<-map["classPlace"]
        professorName<-map["professorName"]
        classTitle<-map["classTitle"]
    }
}
//MARK: - Get Schedules
extension Schedule {
    public static var schedules: [Schedule] = []
    public static func getSchedules() -> Void {
        if let _ = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("TimeTable").addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            if let added = Schedule(JSON: diff.document.data()) {
                                schedules.append(added)
                                //notify TimeTable
                            }
                        }
                        
                        if (diff.type == .removed) {
                            if let removed = Schedule(JSON: diff.document.data()) {
                                if let indexOfElement = schedules.firstIndex(where:{ self.compareSchedule(s1: removed, s2: $0) }) {
                                    schedules.remove(at: indexOfElement)
                                    //notify TimeTable
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    public static func compareSchedule(s1: Schedule, s2: Schedule) -> Bool {
        if(s1.classTitle==s2.classTitle && s1.day==s2.day && s1.startTime==s2.startTime && s1.endTime==s2.endTime) {
            return true
        } else { return false }
    }
}

