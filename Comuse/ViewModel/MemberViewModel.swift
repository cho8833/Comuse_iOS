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
    //singleton pattern
    public static let memberViewModel =  MemberViewModel()
    
    
    // FireStore Communication Object
    private let fireStoreManager = MemberFireStoreManager()
    
    // Local Communication Object
    private let memberRealm = MemberRealm()
    
    public var membersForView = PublishSubject<[Member]>()
    
    private let disposebag = DisposeBag()
    
    public func getMembers() {
        // get members from local
        memberRealm.getMembersFromLocal()
        memberRealm.membersSubject.subscribe(
            onNext: { members in
                self.membersForView.onNext(members)
            }
        ).disposed(by: self.disposebag)
        
        // get members from firestore
        fireStoreManager.getMembersFromFireStore()
        fireStoreManager.membersSubject.subscribe(
            onNext: { members in
                self.membersForView.onNext(members)
            },
            onError: { error in
                self.membersForView.onError(error)
            }
        ).disposed(by: self.disposebag)
    }
}
