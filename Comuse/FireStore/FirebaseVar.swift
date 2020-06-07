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
struct FirebaseVar {
    /*
        user 객체는 앱이 실행 될 때 Auth.currentUser(AppDelegate) 을 통해 초기화한다. 로그인 기록이 있으면 데이터가 들어오고, 로그인 기록이 없으면 nil 로 초기화 된다.
        이 앱 내에서는 로그인 유무로 사용되는데, FireStore 와 데이터 통신을 하려면 이 객체는 nil 값이어서는 안된다.
     */
    public static var user: User?
    
    public static var dbFIB: Firestore?                            // FireStore 와 통신하기 위한 객체
    
    /*
        Member.getMembers 에서 생성되는 SnapShot Listener 를 저장하는 객체이다.
        MemberTableViewController.viewWillAppear 에서 이 객체를 검사하여 snapShot Listener 가 활성화 되어있지 않으면 활성화 시킨다. user는 검사하지 않아도 된다.
        로그인이 되어있지 않거나 Listener가 활성화 되어있지 않은 경우 nil 이다.
     */
    public static var memberListener: ListenerRegistration?
    
    /*
        Schedule.getSchedules 에서 생성되는 SnapShot Listener 를 저장하는 객체이다.
        TimeTableViewController.viewWillAppear 에서 이 객체를 검사하여 SnapShot Listener 가 활성화 되어잇지 않으면 활성화 시킨다. user는 검사하지 않아도 된다.
        로그인 되어있지 않거나 Listener 가 활성화 되어있지 않은 경우 nil 이다.
     */
    public static var scheduleListener: ListenerRegistration?
}



