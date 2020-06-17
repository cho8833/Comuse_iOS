//
//  MemberViewController.swift
//  Comuse
//
//  Created by 조현빈 on 2020/06/03.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import FirebaseAuth

class MemberViewController: UIViewController {
    
    //IBOutlet
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inoutButton: UIButton!
    @IBAction func touchUpInoutButton(_ sender: UIButton) {
        if (self.userData?.inoutStatus == true) {
            UserDataViewModel.userDataViewModel.updateInoutStatus(inoutStatus: false)
        } else {
            UserDataViewModel.userDataViewModel.updateInoutStatus(inoutStatus: true)
        }
    }
    @IBOutlet weak var memberTable: UITableView!
    
    // View Tag (User Info)
    let nameLabelTag = 101
    let positionLabelTag = 102
    let inoutStatusLabelTag = 103
    
    private let disposebag = DisposeBag()
    
    //User Data
    private var userData: Member?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memberTable.delegate = nil
        memberTable.dataSource = nil
        
        // bind members to TableView
        self.bindMembers()
        //bind userData to User Info
        self.bindUserData()
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in         // Login State Listener
            if let _ = user {
                // signed in
                UserDataViewModel.userDataViewModel.getUserData()
                MemberViewModel.memberViewModel.getMembers()
            } else {
                // signed out
                UserDataViewModel.userDataViewModel.userDataForView.onNext(Member(name: "", email: "", inoutStatus: false, position: ""))
                MemberViewModel.memberViewModel.membersForView.onNext([])
                self.userData = nil
            }
        }
    }
    
    // MARK: - bind User Data Method
    private func bindUserData() {
        UserDataViewModel.userDataViewModel.userDataForView.subscribe(
            onNext: { userData in
                self.userData = userData
                self.positionLabel.text = userData.position
                self.nameLabel.text = userData.name
                if (userData.inoutStatus == true) { self.inoutButton.setTitle("in", for: .normal) }
                else { self.inoutButton.setTitle("out",for: .normal) }
            },
            onError: { error in
                ErrorHandler.generateSnackBarWithAction(title: error.localizedDescription, actionTitle: "ReFresh", onAction: self.bindUserData)
            }
        ).disposed(by: self.disposebag)
    }
    
    // MARK: - bind Members Method
    private func bindMembers() {
        MemberViewModel.memberViewModel.membersForView.bind(to: memberTable.rx.items(cellIdentifier: "memberTableCell")) { row, element, cell in
            (cell.viewWithTag(self.nameLabelTag) as! UILabel).text = element.name
            (cell.viewWithTag(self.positionLabelTag) as! UILabel).text = element.position
            if (element.inoutStatus == true) { (cell.viewWithTag(self.inoutStatusLabelTag) as! UILabel).text = "in" }
            else { (cell.viewWithTag(self.inoutStatusLabelTag) as! UILabel).text = "out"}
        }.disposed(by: disposebag)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
