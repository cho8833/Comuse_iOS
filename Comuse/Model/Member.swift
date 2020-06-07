//
//  Member.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/29.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseFirestore
import RealmSwift
/*
    유저의 정보를 담는 class
    FireStore/Members Collection 에 저장됨
 */

class Member: Object, Mappable {
    //MARK:- properties
    @objc dynamic var name: String      = ""      // from FirebaseVar,user, can't be nil
    @objc dynamic var inoutStatus: Bool = false   // addMember 되어 새로운 멤버 데이터가 생성된 경우 초기값은 false 이다.
    @objc dynamic var position: String  = ""      // Setting 에서 유저가 직접 edit 해야한다.
    @objc dynamic var email: String     = ""      // from FirebaseVar.user, can't be nil
    
    override class func primaryKey() -> String? {
        return "email"
    }
    required init?(map: Map) {
        if let name = map.JSON["name"] {
            self.name = name as! String
        } else { return nil }
        if let inoutStatus = map.JSON["inoutStatus"] {
            self.inoutStatus = inoutStatus as! Bool
        } else { return nil }
        if let position = map.JSON["position"] {
            self.position = position as! String
        } else { return nil }
        if let email = map.JSON["email"] {
            self.email = email as! String
        } else { return nil }
    }
    init(name: String, email: String, inoutStatus: Bool, position: String) {
        self.name = name
        self.email = email
        self.inoutStatus = inoutStatus
        self.position = position
    }
    required init() {
    }
    func mapping(map: Map) {
        name<-map["name"]
        inoutStatus<-map["inoutStatus"]
        position<-map["position"]
        email<-map["email"]
    }
}
