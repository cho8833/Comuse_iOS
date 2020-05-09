//
//  SettingsViewController.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
class SettingsViewController: UITableViewController {
    
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBAction func touchUpEditPosition(_ sender: UIButton) {
        let alert = UIAlertController(title: "Edit Position", message: "Input Position", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
            if let position = alert.textFields?[0].text {
                Member.editPosition(position: position) { () in
                    self.positionLabel.text = position
                    Member.me?.position = position
                }
            }
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel) { (cancel) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addTextField()

        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)

    }
    @IBAction func touchUpSignIn_Out(_ sender: UIButton) {
        if let user = FirebaseVar.user {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                user.delete { error in
                    if let error = error {
                        print("delete user error: \(error)")
                    } else {
                        Member.removeMemberData()
                        Member.removeStoredData(value: Member.me, key: nil)
                        Member.me = nil
                        Member.members.removeAll()
                        Schedule.schedules.removeAll()
                        FirebaseVar.memberListener?.remove()
                        FirebaseVar.scheduleListener?.remove()
                        FirebaseVar.user = nil
                        FirebaseVar.db = nil
                        self.updateUI()
                    }
                }
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }

        } else {
            performSegue(withIdentifier: "signInSegue", sender: nil)
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    private func configureRefreshControl() {
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.addTarget(self, action: #selector(updateUI), for: .valueChanged)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc private func updateUI() {
        //set email, name, position label, sign In/Out button
        if let user = FirebaseVar.user {
            emailLabel.text = user.email
            nameLabel.text = user.displayName
        } else {
            emailLabel.text = "nil"
            nameLabel.text = "nil"
        }
        if let me = Member.me, let position = me.position {
            positionLabel.text = position
        } else {
            positionLabel.text = "nil"
        }
        self.refreshControl?.endRefreshing()
    }
}
