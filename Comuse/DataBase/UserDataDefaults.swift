//
//  UserDataDefaults.swift
//  Comuse
//
//  Created by 조현빈 on 2020/06/06.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import Foundation
import RxSwift

class UserDataDefaults {
    private var userData: Member?
    public var userDataSubject = ReplaySubject<Member?>.create(bufferSize: 1)
}
extension  UserDataDefaults {
    public func addUserDataInLocal(value: Member) -> Void {
        UserDefaults.standard.set(value.name, forKey: "name")
        UserDefaults.standard.set(value.position, forKey:"position")
        UserDefaults.standard.set(value.email, forKey: "email")
        UserDefaults.standard.set(value.inoutStatus, forKey: "inoutStatus")
        self.userData = value
    }
    public func updatePositionInLocal(position: String) -> Void {
        UserDefaults.standard.set(position, forKey: "position")
        self.userData?.position = position
    }
    public func updateInoutStatusInLocal(inoutStatus: Bool) -> Void {
        UserDefaults.standard.set(inoutStatus, forKey: "inoutStatus")
        self.userData?.inoutStatus = inoutStatus
    }
    public func removeUserDataInLocal() -> Void {
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "position")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "inoutStatus")
        self.userData = nil
    }
    public func getUserDataInLocal() {
        if let name = UserDefaults.standard.string(forKey: "name"),
            let email = UserDefaults.standard.string(forKey: "email"),
            let position = UserDefaults.standard.string(forKey: "position") {
            
            self.userData = Member(name: name,
                                   email: email,
                                   inoutStatus: UserDefaults.standard.bool(forKey: "inoutStatus"),
                                   position: position)
            
            userDataSubject.onNext(self.userData)
        } else { return }
    }
}
