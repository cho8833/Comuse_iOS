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
    
    /*
        position edit button 을 누르면 Position 을 입력하는 textField 를 가진 Alert 가 발생한다.
     */
    @IBAction func touchUpEditPosition(_ sender: UIButton) {
        if let _ = FirebaseVar.user {
            let alert = UIAlertController(title: "Edit Position", message: "Input Position", preferredStyle: .alert)
            // ok button
            let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
                if let position = alert.textFields?[0].text {
                    Member.editPosition(position: position) { () in
                        self.positionLabel.text = position
                        Member.me?.position = position
                    }
                }
            }
            // cancel button
            let cancel = UIAlertAction(title: "cancel", style: .cancel) { (cancel) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addTextField()
            
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func touchUpSignIn_Out(_ sender: UIButton) {
        // user 의 nil 여부로 로그인 여부를 검사한다.
        if let user = FirebaseVar.user {
            // sign out
            user.delete { error in
                if let error = error {
                    // error occured
                    // case: require reauthenticate
                    print(error.localizedDescription)
                    
                    // create get password alert
                    let alert = UIAlertController(title: "Delete Account", message: "Input password", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { ok in
                        if let pwd = alert.textFields?[0].text {
                            let credential: AuthCredential = EmailAuthProvider.credential(withEmail: (FirebaseVar.user?.email)!, password: pwd)
                            FirebaseVar.user?.reauthenticate(with: credential) { authDataResult, error in
                                if let error = error {
                                    // error occuered when reauthenticating
                                    self.generateSimpleAlert(title: "Error", message: error.localizedDescription)
                                } else {
                                    // deleting user complete
                                    FirebaseVar.user?.delete()
                                    FirebaseVar.memberListener?.remove()
                                    FirebaseVar.scheduleListener?.remove()
                                    Member.removeStoredData(value: Member.me, key: nil)
                                    self.generateSimpleAlert(title: "Complete", message: "Sign Out Success")
                                }
                            }
                        }
                    }
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { cancel in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(okAction)
                    alert.addAction(cancel)
                    alert.addTextField()
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // deleting user complete without error(reauthenticate..)
                    FirebaseVar.memberListener?.remove()
                    FirebaseVar.scheduleListener?.remove()
                    Member.removeStoredData(value: Member.me, key: nil)
                    self.generateSimpleAlert(title: "Complete", message: "Sign Out Success")
                }
            }
        } else {
            // sign in
            performSegue(withIdentifier: "signInSegue", sender: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Member.getMyMemberData {
            self.updateUI()
        }
    }
    
    //MARK: - Refresh Control
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
    
    //MARK: -Privates
    private func generateSimpleAlert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { ok in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
