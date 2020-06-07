//
//  ScheduleViewModel.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/29.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import RxSwift
struct ScheduleViewModel {
    
    // FireStore Communication Object
    public let fireStoreManager: ScheduleFireStoreManager = ScheduleFireStoreManager()
    
    // Local Communication Object
    public let scheduleRealm: ScheduleRealm = ScheduleRealm()
    
    public var schedulesForView = PublishSubject<[Schedule]>()
    
    public func getSchedules() -> PublishSubject<[Schedule]> {
        // get schedules from local
        scheduleRealm.getSchedulesFromLocal()
        
        // get scheules from firestore
        fireStoreManager.getSchedulesFromFireStore()
        
        scheduleRealm.schedulesSubject.subscribe(onNext: { schedules in
            self.schedulesForView.onNext(schedules)
        })
        
        fireStoreManager.schedulesSubject.subscribe(onNext: { schedules in
            self.schedulesForView.onNext(schedules)
        })
        return self.schedulesForView
    }
    public func deleteSchedule(schedule: Schedule) {
        fireStoreManager.removeSchedule(documentID: schedule.key)
        scheduleRealm.deleteScheduleFromLocal(schedule: schedule)
    }
    public func updateSchedule(schedule: Schedule) {
        fireStoreManager.updateSchedule(schedule: schedule)
        scheduleRealm.updateScheduleToLocal(schedule: schedule)
    }
    public func addSchedule(schedule: Schedule) {
        fireStoreManager.addSchedule(schedule: schedule)
        scheduleRealm.updateScheduleToLocal(schedule: schedule)
    }
}
