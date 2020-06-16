//
//  ScheduleFireStoreManager.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/29.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import RxSwift
import ObjectMapper

class ScheduleFireStoreManager {
    private var schedulesList: [Schedule] = []
    public var schedulesSubject: PublishSubject<[Schedule]> = PublishSubject()
    
    private var scheduleRealm = ScheduleRealm()
}
//MARK: - Get Schedules
/*
    FireStore/TimeTable Collection 에서 데이터를 실시간(SnapShot Listener)으로 받아온다.
    
*/
extension ScheduleFireStoreManager {
    
    public func getSchedulesFromFireStore() -> Void {
        if let db = FirebaseVar.dbFIB {
            FirebaseVar.scheduleListener = db.collection("TimeTable").addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    self.schedulesSubject.onError(error!)
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        if let added = Schedule(JSON: diff.document.data()) {
                            self.schedulesList.append(added)
                            self.scheduleRealm.addScheduleToLocal(schedule: added)
                        }
                    }
                    else if (diff.type == .modified) {
                        if let modified = Schedule(JSON: diff.document.data()) {
                            if let indexOfElement = self.schedulesList.firstIndex(where: { modified.key == $0.key}) {
                                self.schedulesList.remove(at: indexOfElement)
                                self.schedulesList.insert(modified, at: indexOfElement)
                                self.scheduleRealm.updateScheduleToLocal(schedule: modified)
                            }
                        }
                    }
                    else if (diff.type == .removed) {
                        if let removed = Schedule(JSON: diff.document.data()) {
                            if let indexOfElement = self.schedulesList.firstIndex(where:{ removed.key==$0.key }) {
                                self.schedulesList.remove(at: indexOfElement)
                                self.scheduleRealm.deleteScheduleFromLocal(scheduleKey: removed.key)
                            }
                        }
                    }
                }
                self.schedulesSubject.onNext(self.schedulesList)
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
extension ScheduleFireStoreManager {
    // FIreStore/TimeTable Collection 에 문서를 추가한다.
    public func addSchedule(schedule: Schedule) -> Void {
        if let db = FirebaseVar.dbFIB {
            let json = Mapper().toJSON(schedule)
            db.collection("TimeTable").document(schedule.key)
                    .setData(json)
        }
    }
    // FireStore/TimeTable Collection 에 문서를 제거한다.
    public func removeSchedule(documentID: String) -> Void {
        if let db = FirebaseVar.dbFIB {
            db.collection("TimeTable").document(documentID)
            .delete()
        }
    }
    // FireStore/TimeTable Collection 의 문서를 update 한다.
    public func updateSchedule(schedule: Schedule) -> Void {
        if let db = FirebaseVar.dbFIB {
            db.collection("TimeTable").document(schedule.key)
                .updateData(["classTitle":      schedule.classTitle,
                            "startTimeHour":   schedule.startTimeHour,
                            "startTimeMinute": schedule.startTimeMinute,
                            "endTimeHour":     schedule.endTimeHour,
                            "endTimeMinute":   schedule.endTimeMinute,
                            "day":             schedule.day])
        }
    }
}
//MARK: Privates
extension ScheduleFireStoreManager {
    private func generateKey() -> Int {
        return schedulesList.count+1
    }
    public static func isEqualSchedule(s1: Schedule, s2: Schedule) -> Bool {
        if(s1.classTitle==s2.classTitle && s1.day==s2.day && s1.startTimeHour==s2.startTimeHour && s1.endTimeHour==s2.endTimeHour && s1.startTimeMinute==s2.startTimeMinute && s1.endTimeMinute==s2.endTimeMinute) {
            return true
        } else { return false }
    }
}
