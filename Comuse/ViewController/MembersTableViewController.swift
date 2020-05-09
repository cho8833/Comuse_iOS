//
//  MembersTableViewController.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit

class MembersTableViewController: UITableViewController {
    
    @IBOutlet weak var updateInoutButton: UIBarButtonItem!
    @IBAction func udpateInout(_ sender: UIBarButtonItem) {
        if updateInoutButton.title == "out" {
            Member.updateInout(inoutStatus: true, completion: updateUI)
        } else {
            Member.updateInout(inoutStatus: false, completion: updateUI)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Member.getMembers(reload: self.tableView.reloadData)
        Member.getMyMemberData() {
            self.updateInoutStatus()
        }
        self.configureRefreshControl()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Member.members.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
        guard indexPath.row < Member.members.count else { return cell }
        
        let member: Member = Member.members[indexPath.row]
        cell.textLabel?.text = member.name
        if member.inoutStatus == true { cell.detailTextLabel?.text = "in" }
        else { cell.detailTextLabel?.text = "out" }

        return cell
    }


}
//MARK: - Refresh Control
extension MembersTableViewController {
    private func configureRefreshControl() {
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.addTarget(self, action: #selector(updateUI), for: .valueChanged)
    }
    @objc private func updateInoutStatus() {
        if let myData = Member.me {
            if myData.inoutStatus == true {
                self.updateInoutButton.title = "in"
            } else {
                self.updateInoutButton.title = "out"
            }
        }
    }
    @objc private func updateUI() {
        Member.getMyMemberData {
            self.updateInoutStatus()
        }
        Member.getMembers {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}
