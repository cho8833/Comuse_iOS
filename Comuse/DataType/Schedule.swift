//
//  Schedule.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import ObjectMapper
import RxCocoa
import RxSwift

struct Schedule {
    var day: Int
    var startTime: Time
    var endTime: Time
    var classPlace: String?
    var professorName: String
    var classTitle: String
}
//MARK: - JSON -> Schedule Methods
extension Schedule: Mappable {
    init?(map: Map) {
        if let day = map.JSON["day"] as? Int {
            self.day = day
        } else { return nil }
        if let startTime = Time(JSON: map.JSON["startTime"] as! [String : Any]) {
            self.startTime = startTime
        } else { return nil }
        if let endTime = Time(JSON: map.JSON["endTime"] as! [String : Any]) {
            self.endTime = endTime
        } else { return nil }
        if let professorName = map.JSON["professorName"] as? String {
            self.professorName = professorName
        } else { return nil }
        if let classTitle = map.JSON["classTitle"] as? String {
            self.classTitle = classTitle
        } else { return nil }
        self.classPlace = nil
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
    public static func getSchedules(reload:@escaping () -> Void, addFunc:@escaping (Schedule) -> Void, removeFunc:@escaping (String) -> Void) -> Void {
        if let _ = FirebaseVar.user {
            if let db = FirebaseVar.db {
                FirebaseVar.scheduleListener = db.collection("TimeTable").addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            if let added = Schedule(JSON: diff.document.data()) {
                                schedules.append(added)
                                
                                
                                addFunc(added)
                            }
                        }
                        if (diff.type == .removed) {
                            if let removed = Schedule(JSON: diff.document.data()) {
                                if let indexOfElement = schedules.firstIndex(where:{ self.isEqualSchedule(s1: removed, s2: $0) }) {
                                    schedules.remove(at: indexOfElement)
                                    let id = getDocumentID(schedule: removed)
                                    removeFunc(id)
                                }
                            }
                        }
                    }
                    reload()
                }
            }
        }
    }
}
//MARK: MyScheduleControl
extension Schedule {
    public static func addSchedule(schedule: Schedule) -> Bool {
        if let _ = FirebaseVar.user {
            if let db = FirebaseVar.db {
                    let json = Mapper().toJSON(schedule)
                    let documentID = getDocumentID(schedule: schedule)
                    db.collection("TimeTable").document(documentID)
                        .setData(json)
                    return true
            }
        }
        return false
    }
    public static func removeSchedule(documentID: String) -> Bool {
        if let _ = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("TimeTable").document(documentID)
                .delete()
                return true
            }
        }
        return false
    }
}
//MARK: Privates
extension Schedule {
    public static func getDocumentID(schedule: Schedule) -> String {
        let document_part1 = String(format: "%02d", schedule.startTime.hour) + String(format: "%02d", schedule.startTime.minute)
        let document_part2 = String(format: "%02d", schedule.endTime.hour) + String(format: "%02d", schedule.endTime.minute) + String(schedule.day)
        
        return document_part1 + document_part2
    }
    public static func isEqualSchedule(s1: Schedule, s2: Schedule) -> Bool {
        if(s1.classTitle==s2.classTitle && s1.day==s2.day && s1.startTime==s2.startTime && s1.endTime==s2.endTime) {
            return true
        } else { return false }
    }
    
}
