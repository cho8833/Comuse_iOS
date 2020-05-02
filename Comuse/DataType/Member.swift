//
//  Member.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
struct Member {
    //MARK:- properties
    let name: String
    var inoutStatus: Bool
    var position: String?
    let uid: String
    
    
}
extension Member {
    public static var members: [Member] = []
    
}
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
                        }
                }
            }
        }
    }
}
