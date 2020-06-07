//
//  UserDataViewModel.swift
//  Comuse
//
//  Created by 조현빈 on 2020/06/06.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import Foundation
import RxSwift

class UserDataViewModel {
    // Firestore Communication Object
    private var fireStoreManager = UserDataFireStoreManager()
    
    // UserDefaults(Local) Communication Object
    private var localManager = UserDataDefaults()
    
    public var userDataForView = PublishSubject<Member>()
    
    public func getUserData() -> PublishSubject<Member> {
        localManager.getUserDataInLocal()
        localManager.userDataSubject.subscribe(onNext: { userData in
            if let userData = userData {
                self.userDataForView.onNext(userData)
            }
        })
        fireStoreManager.getUserDataFromFireStore(onSuccess: localManager.addUserDataInLocal)
        fireStoreManager.userDataSubject.subscribe(onNext: { userData in
            self.userDataForView.onNext(userData)
        })
        return self.userDataForView
    }
    public func updatePosition(position: String) {
        fireStoreManager.updatePositionInFireStore(position: position, onSuccess: localManager.updatePositionInLocal)
    }
    public func updateInoutStatus(inoutStatus: Bool) {
        fireStoreManager.updateInOutStatusInFireStore(inoutStatus: inoutStatus, onSuccess: localManager.updateInoutStatusInLocal)
    }
    public func removeUserData() {
        
    }
}
