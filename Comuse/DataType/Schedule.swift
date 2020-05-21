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
/*
    TimeTable 에서 일정의 정보를 담는 class
    FireStore/timeTable Collection 에 저장됨
    시간은 9:00 ~ 24:00 까지만 지원한다.
    Schedule Data 는 시작시간|종료시간|요일 이름의 문서로 저장된다.
    ex) 213023306 = 시작시간 21:30 ~ 종료시간 23:30 일요일
 */
struct Schedule {
    var day: Int                    // 요일 인덱스는 월(0) ~ 일(6) 까지이다.
    var startTime: Time             // 시작 시간
    var endTime: Time               // 종료 시간
    var classPlace: String?         // TimeTable 의 Schedule 에서 생성될 때 classTitle 하단에 표시되는 문자열
                                    // 현재는 쓰지 않아 nil 로 저장하지만 추후에 작성자의 이름을 저장할까 고려중
    var professorName: String       // 작성자의 email 저장. TimeTable 내에서 touchUp 되었을 때 자신이 작성한 Schedule 인지 확인하기 위해 사용한다.
    var classTitle: String          // Schedule 의 Title, TimeTable 내에서 생성될 때 Schedule 내에 표시된다.
}
//MARK: - JSON -> Schedule Methods
/*
   FireStore 은 커스텀 객체 저장을 지원하지 않는다. 따라서 JSON 형식으로 바꾼 후 데이터를 전송한다.
*/
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
/*
    FireStore/TimeTable Collection 에서 데이터를 실시간(SnapShot Listener)으로 받아온다.
    데이터는 schedules 객체에 저장되고 Local 에는 저장하지 않는다.
    데이터가 변경되어 querySnapshot 이 전달되면 TimeTableView 에 notify 해줘야한다.
*/
extension Schedule {
    public static var schedules: [Schedule] = []
    public static func getSchedules(reload:@escaping () -> Void, addToTimeTable:@escaping (Schedule) -> Void, removeSchedule:@escaping (String) -> Void) -> Void {
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
                                addToTimeTable(added)       // add schedule to timeTable
                            }
                        }
                        if (diff.type == .removed) {
                            if let removed = Schedule(JSON: diff.document.data()) {
                                if let indexOfElement = schedules.firstIndex(where:{ self.isEqualSchedule(s1: removed, s2: $0) }) {
                                    schedules.remove(at: indexOfElement)
                                    let id = getDocumentID(schedule: removed)
                                    removeSchedule(id)      // remove schedule in timeTable
                                }
                            }
                        }
                    }
                    reload()     // notify TimeTable
                }
            }
        }
    }
}
//MARK: My Schedule Control
/*
    Schedule 을 FireStore/TimeTable Collection 에 약속된 문서 이름으로 저장된다.
    데이터를 추가/변경/제거 하였을 때 TimeTableView 에 notify 해주지 않아도 된다.
    -> snapshot listener 에서 처리한다.
 */
/*
    문서이름은 Schedule 의 데이터로 구성되기 때문에 데이터를 변경하면 문서의 이름도 변경해야하는 작업이 필요하다.
    하지만 FireStore 은 문서 이름 변경을 지원하지 않는 것으로 확인된다.
 
    ***따라서 데이터가 변경될 시, 변경되기 전의 데이터를 삭제하고, 변경된 후의 데이터를 추가하는 작업이 필요하다.***
 
 */
extension Schedule {
    // FIreStore/TimeTable Collection 에 문서를 추가한다.
    public static func addSchedule(schedule: Schedule) -> Void {
        if let _ = FirebaseVar.user {
            if let db = FirebaseVar.db {
                    let json = Mapper().toJSON(schedule)
                    let documentID = getDocumentID(schedule: schedule)
                    db.collection("TimeTable").document(documentID)
                        .setData(json)
            }
        }
    }
    // FireStore/TimeTable Collection 에 문서를 제거한다.
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
    public static func editSchedule(docNameBeforeEdit: String, editedSchedule: Schedule) -> Void {
        if let _ = FirebaseVar.user {
            if let _ = FirebaseVar.db {
                addSchedule(schedule: editedSchedule)
                removeSchedule(documentID: docNameBeforeEdit);
            }
        }
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
