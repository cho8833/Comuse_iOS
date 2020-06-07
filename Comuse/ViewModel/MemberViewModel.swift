//
//  MemberViewModel.swift
//  Comuse
//
//  Created by 조현빈 on 2020/06/03.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import RxSwift
class MemberViewModel {
    // FireStore Communication Object
    private let fireStoreManager = MemberFireStoreManager()
    
    // Local Communication Object
    private let memberRealm = MemberRealm()
    
    public var membersForView = PublishSubject<[Member]>()
    
    public func getMembers() -> PublishSubject<[Member]> {
        // get members from local
        memberRealm.getMembersFromLocal()
        // get members from firestore
        fireStoreManager.getMembersFromFireStore()
        
        memberRealm.membersSubject.subscribe(onNext: { schedules in
            self.membersForView.onNext(schedules)
        })
        fireStoreManager.membersSubject.subscribe(onNext: { schedules in
            self.membersForView.onNext(schedules)
        })
        return self.membersForView
    }
    
}
