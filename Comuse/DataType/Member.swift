//
//  Member.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import ObjectMapper
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
    // MARK: - Control myMemberData Methods
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
                        return
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
                        }
                }
            }
        }
    }
    public static func updateInout(inoutStatus: Bool, completion: @escaping(String) -> Void) -> Void {
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
                                completion("in")
                            } else {
                                completion("out")
                            }
                        }
                }
            }
        }
    }
    public static func getMyMemberData() -> Void {
        if let user = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("Members").document(user.uid)
                    .getDocument() { (document, error) in
                        if let document = document {
                            // save me data in me(Member)
                            if let member = Member(JSON: document.data()!) {
                                self.me = member
                            }
                        }
                }
            }
        }
    }
}
//MARK: - Get Members
extension Member {
    public static var members: [Member] = []
    
    public static func getMembers() -> Void {
        if let _ = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("Members")
                .addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            if let member = Member(JSON: diff.document.data()) {
                                self.members.append(member)
                                print(member)
                                //notify tableView
                            }
                        }
                        if (diff.type == .modified) {
                            if let modified = Member(JSON: diff.document.data()) {
                                if let index = members.firstIndex(where: { $0.uid == modified.uid}) {
                                    members.remove(at: index)
                                    members.insert(modified, at: index)
                                    // notify tableView
                                }
                            }
                        }
                        if (diff.type == .removed) {
                            if let removed = Member(JSON: diff.document.data()) {
                                if let indexOfElement = members.firstIndex(where: { $0.uid == removed.uid }) {
                                    members.remove(at: indexOfElement)
                                    //notify tableView
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

