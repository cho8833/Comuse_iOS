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
    // singleton pattern
    public static let scheduleViewModel =  ScheduleViewModel()
    
    // FireStore Communication Object
    public let fireStoreManager: ScheduleFireStoreManager = ScheduleFireStoreManager()
    
    // Local Communication Object
    public let scheduleRealm: ScheduleRealm = ScheduleRealm()
    
    public var schedulesForView = PublishSubject<[Schedule]>()
    
    public let disposebag = DisposeBag()
    
    public func getSchedules() {
        // get schedules from local
        scheduleRealm.getSchedulesFromLocal()
        scheduleRealm.schedulesSubject.subscribe(onNext: { schedules in
            self.schedulesForView.onNext(schedules)
        }).disposed(by: self.disposebag)
        
        // get scheules from firestore
        fireStoreManager.getSchedulesFromFireStore()
        fireStoreManager.schedulesSubject.subscribe(onNext: { schedules in
            self.schedulesForView.onNext(schedules)
        }).disposed(by: self.disposebag)
    }
    public func getSchedulesFromGlobal() -> PublishSubject<[Schedule]> {
        fireStoreManager.getSchedulesFromFireStore()
        fireStoreManager.schedulesSubject.subscribe(onNext: { schedules in
            self.schedulesForView.onNext(schedules)
        }).disposed(by: self.disposebag)
        return self.schedulesForView
    }
    public func deleteSchedule(scheduleKey: String) {
        fireStoreManager.removeSchedule(documentID: scheduleKey)
        scheduleRealm.deleteScheduleFromLocal(scheduleKey: scheduleKey)
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
