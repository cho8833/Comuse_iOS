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
    
    //singleton pattern
    public static let userDataViewModel = UserDataViewModel()
    
    
    // Firestore Communication Object
    private var fireStoreManager = UserDataFireStoreManager()
    
    // UserDefaults(Local) Communication Object
    private var localManager = UserDataDefaults()
    
    public var userDataForView = ReplaySubject<Member>.create(bufferSize: 1)
    private let disposebag = DisposeBag()
    
    public func getUserData() {
        // get User Data from Local
        localManager.getUserDataInLocal()
        localManager.userDataSubject.subscribe(onNext: { userData in
            if let userData = userData {
                self.userDataForView.onNext(userData)
            }
        }).disposed(by: self.disposebag)
        
        // get UserData from FireStore
        fireStoreManager.getUserDataFromFireStore(onSuccess: localManager.addUserDataInLocal)
        fireStoreManager.userDataSubject.subscribe(
            onNext: { userData in
                self.userDataForView.onNext(userData)
            },
            onError: { error in
                self.userDataForView.onError(error)
            }
        ).disposed(by: self.disposebag)
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
