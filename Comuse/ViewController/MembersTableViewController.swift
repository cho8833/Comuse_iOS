//
//  MembersTableViewController.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import Firebase

class MembersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let nameLabelTag = 101
    let positionLabelTag = 102
    let inoutStatusLabelTag = 103
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    // MARK: -Properties
    
    @IBOutlet weak var updateInoutButton: UIButton!
    
    @IBAction func touchUpInoutStatusButton(_ sender: Any) {
        if let me = Member.me {
            if me.inoutStatus == false {
                Member.updateInout(inoutStatus: true) {
                    if let user = FirebaseVar.user {
                        Analytics.logEvent("updated_Inout", parameters: [
                            "MemberName": user.displayName! as NSObject,
                            "Status": "in" as NSObject
                        ])
                    }
                    self.updateUserInfo()
                }
            } else {
                Member.updateInout(inoutStatus: false) {
                    if let user = FirebaseVar.user {
                        Analytics.logEvent("updated_Inout", parameters: [
                            "MemberName": user.displayName! as NSObject,
                            "Status": "out" as NSObject
                        ])
                    }
                    self.updateUserInfo()
                }
            }
        } else {
            Member.getMyMemberData {
                self.updateUserInfo()
            }
        }
    }
    @IBOutlet weak var tableView: UITableView!
    // MARK: -Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.configureRefreshControl()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Member.getMyMemberData {
            self.updateUserInfo()
        }
        if FirebaseVar.memberListener == nil {
            Member.getMembers(reload: tableView.reloadData)
        }
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Member.members.count
    }

    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
            guard indexPath.row < Member.members.count else { return cell }
            
            let member: Member = Member.members[indexPath.row]
            (cell.viewWithTag(nameLabelTag) as! UILabel).text = member.name
            if let position = member.position {
                (cell.viewWithTag(positionLabelTag) as! UILabel).text = position
            } else {
                (cell.viewWithTag(positionLabelTag) as! UILabel).text = ""
            }
            
            cell.textLabel?.text = member.name
            if member.inoutStatus == true { (cell.viewWithTag(inoutStatusLabelTag) as! UILabel).text = "in" }
            else { (cell.viewWithTag(inoutStatusLabelTag) as! UILabel).text = "out" }

        return cell
    }


}
//MARK: - Refresh Control
extension MembersTableViewController {
    private func configureRefreshControl() {
        self.tableView.refreshControl = UIRefreshControl()
        
        self.tableView.refreshControl?.addTarget(self, action: #selector(getData), for: .valueChanged)
    }
    @objc private func updateUserInfo() {
        if let myData = Member.me {
            if myData.inoutStatus == true {
                self.updateInoutButton.setTitle("in", for: .normal)
            } else {
                self.updateInoutButton.setTitle("out", for: .normal)
            }
            positionLabel.text = myData.position
            nameLabel.text = myData.name
        }
    }
    
    @objc private func getData() {
        if Member.me == nil {
            Member.getMyMemberData {
                self.updateUserInfo()
            }
        }
        
        if let _ = FirebaseVar.memberListener {
            self.tableView.refreshControl?.endRefreshing()
        }
        else {
            Member.getMembers {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
        
    }
}
