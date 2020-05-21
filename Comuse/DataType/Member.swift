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
/*
    유저의 정보를 담는 class
    FireStore/Members Collection 에 저장됨
 */

struct Member {
    //MARK:- properties
    var name: String        // from FirebaseVar,user, can't be nil
    var inoutStatus: Bool   // addMember 되어 새로운 멤버 데이터가 생성된 경우 초기값은 false 이다.
    var position: String?   // Setting 에서 유저가 직접 edit 해야한다.
    var email: String         // from FirebaseVar.user, can't be nil
    
    
}

//MARK: - JSON -> Member Methods
/*
    FireStore 은 커스텀 객체 저장을 지원하지 않는다. 따라서 JSON 형식으로 바꾼 후 데이터를 전송한다.
 */
extension Member: Mappable {
    init?(map: Map) {
        if let name = map.JSON["name"] {
            self.name = name as! String
        } else { return nil }
        if let inoutStatus = map.JSON["inoutStatus"] {
            self.inoutStatus = inoutStatus as! Bool
        } else { return nil }
        self.position = map.JSON["position"] as? String
        if let uid = map.JSON["email"] {
            self.email = uid as! String
        } else { return nil }
    }
    mutating func mapping(map: Map) {
        name<-map["name"]
        inoutStatus<-map["inoutStatus"]
        position<-map["position"]
        email<-map["email"]
    }
}
//MARK: - My Member Database Data Control
/*
    user 의 Member Data 는 Member 타입의 me 객체에 저장된다. 그리고 FireStore/Members Collection 에 문서 이름은 Member.email 로 저장된다.
    me 객체는 데이터 통신의 지연을 없애기 위해 UserDefaults 를 이용하여 Local 에 저장한다.
    me 객체의 데이터가 변경 되면, FireStore/Members Collection 에 Member.email 를 이용하여 접근하여 데이터를 변경한다.
    데이터 변경은 FireStore 의 데이터를 먼저 변경 후 콜백 함수인 completion 이 호출되면 Local 데이터를 변경한다.
 */
extension Member {
    public static var me: Member?               // user 의 데이터를 저장하는 객체
    
    /*
        user 의 멤버 데이터는 로컬에 저장되어 먼저 Local 을 검사하여 데이터가 없으면 Database 에서 받아온다.
        만약 Database 에서 데이터를 받아오면 Local 에 데이터를 새로 덮어쓴다.
        받아오는 작업이 완료되면 completion 함수를 호출하여 updateUI 한다.
     */
    public static func getMyMemberData(completion:@escaping () -> Void) -> Void {
        if let myData = self.getMyStoredData() {
            self.me = myData
            completion()
        }
        else {
            if let user = FirebaseVar.user {
                if let db = FirebaseVar.db {
                    db.collection("Members").document(user.email!)
                        .getDocument() { (document, error) in
                            if let document = document {
                                // save me data in me(Member)
                                if let data = document.data() {
                                    let memberData = Member(JSON: data)
                                    self.me = memberData
                                    self.storeData(value: memberData, key: nil)
                                    completion()
                                }
                                else {
                                    //get func success, but document.data() = nil
                                    //case: no user's member data in server
                                    self.addMemberData()
                                }
                            } else {
                                
                            }
                    }
                }
            }
        }
        
    }
    /*
        FireStore 에 데이터 추가 후 Local 에도 데이터를 저장한다
        getMemberData 를 호출하였을 때 Database 에 user Data 가 없는 경우 호출된다.( error code : 5(FirestoreErrorCode.notFound)
     */
    public static func addMemberData() -> Void {
        if let user = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("Members").document(user.email!)
                    .setData(optionalData:
                        [
                            "name": user.displayName,
                            "inoutStatus": false,
                            "position": nil,
                            "email": user.email
                    ]) { error in
                        if let error = error {
                            print("\(error)")
                        } else {
                            if let user = FirebaseVar.user {
                                let memberData = Member(name: user.displayName! , inoutStatus: false, position: nil, email: user.email!)
                                self.me = memberData
                                self.storeData(value: memberData, key: nil)
                            }
                        }
                }
                
            }
        }
    }
    
    // FireStore 의 user.email 문서 이름의 문서를 삭제한다.
    public static func removeMemberData() -> Void {
        if let user = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("Members").document(user.email!)
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
    
    /*
        FireSotre 의 user.email 이름을 가진 문서의 inoutStatus 를 변경하고 변경에 성공하면 Local data 도 변경한다.
        변경이 완료되면 updateUI 가 필요하다.
     */
    public static func updateInout(inoutStatus: Bool, completion: @escaping() -> Void) -> Void {
        if let user = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("Members").document(user.email!)
                    .updateData([
                        "inoutStatus": inoutStatus
                    ]){ err in
                        if let err = err {
                            // error occured updating inout
                            // case 1 : no document
                            print("\(err.localizedDescription)")
                            if (err as NSError).code == FirestoreErrorCode.notFound.rawValue {
                                Member.addMemberData();
                            }
                            
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
    
    /*
        FireStore 의 user.email 이름을 가진 문서의 position 을 변경하고 변경에 성공하면 Local data 도 변경한다.
        변경이 완료되면 updateUI 가 필요하다.
     */
    public static func editPosition(position: String, completion:@escaping ()-> Void) -> Void {
        if let user = FirebaseVar.user {
            if let db = FirebaseVar.db {
                db.collection("Members").document(user.email!)
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
/*
    FireStore/Members Collection 에서 데이터를 실시간(SnapShot Listener)으로 받아온다.
    데이터는 members 객체에 저장되고 Local 에는 저장하지 않는다.
    데이터가 변경되어 querySnapshot 이 전달되면 TableView 에 notify 해줘야한다.
 */
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
                                if let index = members.firstIndex(where: { $0.email == modified.email}) {
                                    members.remove(at: index)
                                    members.insert(modified, at: index)
                                    
                                }
                            }
                        }
                        if (diff.type == .removed) {
                            if let removed = Member(JSON: diff.document.data()) {
                                if let indexOfElement = members.firstIndex(where: { $0.email == removed.email }) {
                                    members.remove(at: indexOfElement)
                                    
                                }
                            }
                        }
                    }
                    reload()            // Notify TableView
                }
            }
        }
    }
}
//MARK: - My Member Local Data Control
extension Member {
    /*
        Local 에는 key-value 형식으로 저장된다.
        Member property 를 모두 저장한다.
     */
    public static func storeData(value: Any, key: String?) -> Void {
        if let memberData = value as? Member {
            UserDefaults.standard.set(memberData.name, forKey: "name")
            if let position = memberData.position {
                UserDefaults.standard.set(position, forKey: "position")
            }
            UserDefaults.standard.set(memberData.email, forKey: "email")
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
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "inoutStatus")
        } else {
            if let forKey = key {
                UserDefaults.standard.removeObject(forKey: forKey)
            }
        }
    }
    public static func getMyStoredData() -> Member? {
        if let name = UserDefaults.standard.string(forKey: "name"), let email = UserDefaults.standard.string(forKey: "email") {
            return Member(name: name, inoutStatus: UserDefaults.standard.bool(forKey: "inoutStatus"), position: UserDefaults.standard.string(forKey: "position"), email: email)
        } else { return nil }
    }
}
