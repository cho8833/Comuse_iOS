//
//  UserDataFireStoreManager.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/29.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import RxSwift

class UserDataFireStoreManager {
    private var userData: Member?
    public var userDataSubject = ReplaySubject<Member>.create(bufferSize: 1)
}

extension UserDataFireStoreManager {
    // MARK: Get UserData From FireStore
    public func getUserDataFromFireStore(onSuccess: @escaping(_ value: Member) -> Void) -> Void {
        if let db = FirebaseVar.dbFIB, let user = FirebaseVar.user {
            db.collection("Members").document(user.email!)
                .getDocument { document, error in
                    if let error = error {
                        self.userDataSubject.onError(error)
                    }
                    if let doc = document {
                        if let data = doc.data() {
                            let member = Member(JSON: data)
                            self.userData = member
                            self.userDataSubject.onNext(self.userData!)
                        }
                        else {
                            //get func success, but document.data() = nil
                            //case: no user's member data in server
                            self.addUserDataInFireStore(onSuccess: onSuccess)
                        }
                    }
            }
        }
    }
    
    // MARK: Add UserData In FireStore
    public func addUserDataInFireStore(onSuccess: @escaping(_ value: Member) -> Void) -> Void {
        if let db = FirebaseVar.dbFIB, let user = FirebaseVar.user {
            db.collection("Members").document(user.email!)
            .setData([
                "name": user.displayName!,
                "position": "",
                "email": user.email!,
                "inoutStatus": false
            ]) { error in
                if let error = error {
                    // notify error
                    self.userDataSubject.onError(error)
                } else {
                    self.userData = Member(name: user.displayName!, email: user.email!, inoutStatus: false, position: "")
                    onSuccess(self.userData!)
                    self.userDataSubject.onNext(self.userData!)
                }
            }
        }
    }
    
    // MARK: Update InOutStatus
    public func updateInOutStatusInFireStore(inoutStatus: Bool, onSuccess: @escaping(_ inoutStatus: Bool) -> Void) -> Void {
        if let db = FirebaseVar.dbFIB, let user = FirebaseVar.user {
            db.collection("Members").document(user.email!)
                .updateData(["inoutStatus": inoutStatus]) { error in
                    if let error = error {
                        // notify error
                        self.userDataSubject.onError(error)
                    } else {
                        self.userData?.inoutStatus = inoutStatus
                        onSuccess(inoutStatus)
                        self.userDataSubject.onNext(self.userData!)
                    }
            }
        }
    }
    
    // MARK: Update Position
    public func updatePositionInFireStore(position: String, onSuccess: @escaping(_ position: String) -> Void) -> Void {
        if let db = FirebaseVar.dbFIB, let user = FirebaseVar.user {
            db.collection("Members").document(user.email!)
                .updateData(["position": position]) { error in
                    if let error = error {
                        // notify error
                        self.userDataSubject.onError(error)
                    } else {
                        self.userData?.position = position
                        onSuccess(position)
                        self.userDataSubject.onNext(self.userData!)
                    }
            }
        }
    }
}
