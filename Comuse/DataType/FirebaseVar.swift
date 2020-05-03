//
//  FirebaseVar.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/02.
//  Copyright © 2020 hyunbin. All rights reserved.
//


import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth
import ObjectMapper
struct FirebaseVar {
    public static var user: User?
    public static var db: Firestore?
}
//MARK: save as [String:Any?]
extension DocumentReference {
    func setData(optionalData: [String: Any?], completion: @escaping (Error?) -> Void) {
        let documentDataWithNullObject = optionalData.mapValues {
            return $0 ?? NSNull()
        }
        self.setData(documentDataWithNullObject) { error in
            completion(error)
        }
    }
}

