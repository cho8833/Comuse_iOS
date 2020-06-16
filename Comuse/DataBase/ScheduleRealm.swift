//
//  ScheduleRealm.swift
//  Comuse
//
//  Created by 조현빈 on 2020/06/02.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift

class ScheduleRealm {
    private var schedulesList: [Schedule] = Array()
    public var schedulesSubject = ReplaySubject<[Schedule]>.create(bufferSize: 20)
    let realm = try! Realm()
    
    // MARK: Get All Schedules
    public func getSchedulesFromLocal() {
        do {
            try realm.write() {
                let schedules = realm.objects(Schedule.self)
                schedulesList.append(contentsOf: schedules)
                schedulesSubject.onNext(schedulesList)
                print("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
            }
        } catch {
            self.schedulesSubject.onError(error)
        }
    }
    
    //MARK: Add Schedule
    public func addScheduleToLocal(schedule: Schedule) {
        do {
            try realm.write() {
                realm.add(schedule, update: .all)
            }
        } catch {
            self.schedulesSubject.onError(error)
        }
    }
    
    //MARK: Update Schedule
    public func updateScheduleToLocal(schedule: Schedule) {
        do {
            try realm.write() {
                realm.add(schedule, update: .all)
            }
        } catch {
            self.schedulesSubject.onError(error)
        }
    }
    
    //MARK: Delete Schedule
    public func deleteScheduleFromLocal(scheduleKey: String) {
        do {
            try realm.write() {
                let object = realm.objects(Schedule.self).filter("id == \(scheduleKey)")
                realm.delete(object)
            }
        } catch {
            self.schedulesSubject.onError(error)
        }
    }
}
