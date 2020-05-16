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
        if let _ = FirebaseVar.user {
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

    }
    @IBAction func touchUpSignIn_Out(_ sender: UIButton) {
        if let user = FirebaseVar.user {
            user.delete { error in
                if let error = error {
                    //error occured
                    print(error.localizedDescription)
                    let alert = UIAlertController(title: "Delete Account", message: "Input password", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { ok in
                        if let pwd = alert.textFields?[0].text {
                            let credential: AuthCredential = EmailAuthProvider.credential(withEmail: (FirebaseVar.user?.email)!, password: pwd)
                            FirebaseVar.user?.reauthenticate(with: credential) { authDataResult, error in
                                if let error = error {
                                    // error occuered when reauthenticating
                                    self.generateSimpleAlert(message: error.localizedDescription)
                                } else {
                                    // deleting user complete
                                    FirebaseVar.user?.delete()
                                    FirebaseVar.memberListener?.remove()
                                    FirebaseVar.scheduleListener?.remove()
                                    Member.removeStoredData(value: Member.me, key: nil)
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
                    // deleting user complete
                }
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
    private func generateSimpleAlert(message: String) -> Void {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { ok in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
