//
//  MemberFireStoreManager.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/29.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import RxSwift

class MemberFireStoreManager {
    private var membersList = Array<Member>()
    public var membersSubject = PublishSubject<[Member]>()
    
    private var memberRealm = MemberRealm()
}

// MARK: Get Members
/*
    FireStore/Members Collection 에서 데이터를 실시간(SnapShot Listener)으로 받아온다.
 */
extension MemberFireStoreManager {
    public func getMembersFromFireStore() -> Void {
        if let _ = FirebaseVar.user, let db = FirebaseVar.dbFIB {
            FirebaseVar.memberListener = db.collection("Members")
                .addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    snapshot.documentChanges.forEach { diff in
                        if let member = Member(JSON: diff.document.data()) {
                            if (diff.type == .added) {
                                if member.inoutStatus == true {
                                    self.membersList.insert(member, at: 0)
                                } else {
                                    self.membersList.append(member)
                                }
                                self.memberRealm.addMemberToLocal(member: member)
                            }
                            else if (diff.type == .modified) {
                                if let index = self.membersList.lastIndex(where: { member.email == $0.email}) {
                                    self.membersList.remove(at: index)
                                    self.membersList.insert(member, at: index)
                                    self.memberRealm.updateMemberToLocal(member: member)
                                }
                                
                            }
                            else if (diff.type == .removed) {
                                if let index = self.membersList.lastIndex(where: { member.email == $0.email}) {
                                    self.membersList.remove(at: index)
                                    self.memberRealm.removeMemberToLoal(member: member)
                                }
                                
                            }
                        }
                    }
                    self.membersSubject.onNext(self.membersList)
            }
        }
    }
}
