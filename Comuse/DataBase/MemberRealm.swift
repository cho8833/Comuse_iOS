
//
//  MemberRealm.swift
//  Comuse
//
//  Created by 조현빈 on 2020/06/03.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift

class MemberRealm {
    public var membersSubject = ReplaySubject<[Member]>.create(bufferSize: 100)
    private var membersList = Array<Member>()
    
    let realm = try! Realm()
    
    //MARK: Get All Members
    public func getMembersFromLocal() {
        do {
            try realm.write() {
                let schedules = realm.objects(Member.self)
                self.membersList.append(contentsOf: schedules)
                self.membersSubject.onNext(self.membersList)
            }
        } catch {
            // error
            self.membersSubject.onError(error)
        }
    }
    
    //MARK: Add Member
    public func addMemberToLocal(member: Member) {
        do {
            try realm.write() {
                realm.add(member, update: .all)
            }
        } catch {
            // error
            self.membersSubject.onError(error)
        }
    }
    
    //MARK: Update Member
    public func updateMemberToLocal(member: Member) {
        do {
            try realm.write() {
                realm.add(member, update: .all)
            }
        } catch {
            // error
            self.membersSubject.onError(error)
        }
    }
    
    //MARK: Remove Member
    public func removeMemberToLoal(member: Member) {
        do {
            try realm.write() {
                realm.delete(member)
            }
        } catch {
            // error
            self.membersSubject.onError(error)
        }
    }
}
