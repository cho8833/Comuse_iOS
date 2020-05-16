//
//  Member.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseFirestore
struct Member {
    //MARK:- properties
    var name: String
    var inoutStatus: Bool
    var position: String?
    var uid: String
    
    
}

//MARK: - JSON -> Member Methods
extension Member: Mappable {
    init?(map: Map) {
        if let name = map.JSON["name"] {
            self.name = name as! String
        } else { return nil }
        if let inoutStatus = map.JSON["inoutStatus"] {
            self.inoutStatus = inoutStatus as! Bool
        } else { return nil }
        self.position = map.JSON["position"] as? String
        if let uid = map.JSON["uid"] {
            self.uid = uid as! String
        } else { return nil }
    }
    mutating func mapping(map: Map) {
        name<-map["name"]
        inoutStatus<-map["inoutStatus"]
        position<-map["position"]
        uid<-map["uid"]
    }
}
//MARK: - MyMemberDataControl
extension Member {
    public static var me: Member?
    public static func addMemberData() -> Void {
        if let user = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("Members").document(user.uid)
                    .setData(optionalData:
                        [
                            "name": user.displayName,
                            "inoutStatus": false,
                            "position": nil,
                            "uid": user.uid
                    ]) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            if let user = FirebaseVar.user {
                                let memberData = Member(name: user.displayName! , inoutStatus: false, position: nil, uid: user.uid)
                                self.me = memberData
                                self.storeData(value: memberData, key: nil)
                            }
                        }
                }
                
            }
        }
    }
    public static func removeMemberData() -> Void {
        if let user = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("Members").document(user.uid)
                    .delete() {error in
                        if let error = error {
                            print("Error removing document: \(error)")
                        } else {
                            //Success removing member data
                            self.removeStoredData(value: self.me, key: nil)
                            self.me = nil
                        }
                }
            }
        }
    }
    public static func updateInout(inoutStatus: Bool, completion: @escaping() -> Void) -> Void {
        if let user = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("Members").document(user.uid)
                    .updateData([
                        "inoutStatus": inoutStatus
                    ]) { err in
                        if let err = err {
                            print("Error updateing inoutStatus: \(err)")
                        } else {
                            
                            if(inoutStatus == true) {
                                self.me?.inoutStatus = true
                                self.updateStoredData(value: true, key: "inoutStatus")
                                completion()
                            } else {
                                self.me?.inoutStatus = false
                                self.updateStoredData(value: false, key: "inoutStatus")
                                completion()
                            }
                        }
                }
            }
        }
    }
    public static func getMyMemberData(completion:@escaping () -> Void) -> Void {
        if let myData = self.getMyStoredData() {
            self.me = myData
            completion()
        }
        else {
            if let user = FirebaseVar.user {
                if let db = FirebaseVar.db {
                    db.collection("Members").document(user.uid)
                        .getDocument() { (document, error) in
                            if let document = document {
                                // save me data in me(Member)
                                if let member = Member(JSON: document.data()!) {
                                    self.me = member
                                    self.storeData(value: member, key: nil)
                                    completion()
                                }
                            } else {
                                //get func success, but document = nil
                                //case: no user's member data in server
                                self.addMemberData()
                            }
                    }
                }
            }
        }
        
    }
    public static func editPosition(position: String, completion:@escaping ()-> Void) -> Void {
        if let user = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("Members").document(user.uid)
                    .updateData(["position": position]) { error in
                        if let error = error {
                            print("error update position: \(error)")
                        } else {
                            self.me?.position = position
                            self.updateStoredData(value: position, key: "position")
                            
                            completion()
                        }
                }
            }
        }
    }
}
//MARK: - Get Members
extension Member {
    public static var members: [Member] = []
    
    public static func getMembers(reload:@escaping () -> Void) -> Void {
        if let _ = FirebaseVar.user {
            if let db = FirebaseVar.db {
                FirebaseVar.memberListener = db.collection("Members")
                .addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            if let member = Member(JSON: diff.document.data()) {
                                self.members.append(member)
                                
                            }
                        }
                        if (diff.type == .modified) {
                            if let modified = Member(JSON: diff.document.data()) {
                                if let index = members.firstIndex(where: { $0.uid == modified.uid}) {
                                    members.remove(at: index)
                                    members.insert(modified, at: index)
                                    
                                }
                            }
                        }
                        if (diff.type == .removed) {
                            if let removed = Member(JSON: diff.document.data()) {
                                if let indexOfElement = members.firstIndex(where: { $0.uid == removed.uid }) {
                                    members.remove(at: indexOfElement)
                                    
                                }
                            }
                        }
                    }
                    reload()
                }
            }
        }
    }
}
//MARK: -Privates
extension Member {
    public static func storeData(value: Any, key: String?) -> Void {
        if let memberData = value as? Member {
            UserDefaults.standard.set(memberData.name, forKey: "name")
            if let position = memberData.position {
                UserDefaults.standard.set(position, forKey: "position")
            }
            UserDefaults.standard.set(memberData.uid, forKey: "uid")
            UserDefaults.standard.set(memberData.inoutStatus, forKey: "inoutStatus")
        } else {
            if let forKey = key {
                UserDefaults.standard.set(value, forKey: forKey)
            }
        }
        
    }
    public static func updateStoredData(value: Any?, key: String) -> Void {
        UserDefaults.standard.set(value, forKey: key)
    }
    public static func removeStoredData(value: Any?, key: String?) -> Void {
        if let _ = value as? Member {
            UserDefaults.standard.removeObject(forKey: "name")
            UserDefaults.standard.removeObject(forKey: "position")
            UserDefaults.standard.removeObject(forKey: "uid")
            UserDefaults.standard.removeObject(forKey: "inoutStatus")
        } else {
            if let forKey = key {
                UserDefaults.standard.removeObject(forKey: forKey)
            }
        }
    }
    public static func getMyStoredData() -> Member? {
        if let name = UserDefaults.standard.string(forKey: "name"), let uid = UserDefaults.standard.string(forKey: "uid") {
            return Member(name: name, inoutStatus: UserDefaults.standard.bool(forKey: "inoutStatus"), position: UserDefaults.standard.string(forKey: "position"), uid: uid)
        } else { return nil }
    }
}
