//
//  SettingsViewController.swift
//  Comuse
//
//  Created by 조현빈 on 2020/06/08.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import FirebaseAuth
import RxSwift

class SettingsTableViewController: UITableViewController {
    
    @IBAction func touchUpEditPositionButton(_ sender: Any) {
        if let _ = FirebaseVar.user {
            let alert = UIAlertController(title: "Edit Position", message: "Input Position", preferredStyle: .alert)
            // ok button
            let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
                if let position = alert.textFields?[0].text {
                    UserDataViewModel.userDataViewModel.updatePosition(position: position)
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
    
    @IBAction func touchUpSignButton(_ sender: UIButton) {
        if ( sender.titleLabel?.text == "Sign In" ) {
            performSegue(withIdentifier: "signInSegue", sender: nil)
        } else {
            do {
                try Auth.auth().signOut()
                FirebaseVar.memberListener?.remove()
                FirebaseVar.scheduleListener?.remove()
                FirebaseVar.dbFIB = nil
            } catch {
                // signout falied
            }
        }
    }
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    private let disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // bind User Info
        self.bindUserInfo()
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in             // Login State Listener
            if let _ = user {
                // signed in
                self.signButton.setTitle("Sign Out", for: .normal)
                UserDataViewModel.userDataViewModel.getUserData()
            } else {
                // signed out
                self.signButton.setTitle("Sign In", for: .normal)
                UserDataViewModel.userDataViewModel.userDataForView.onNext(Member(name: "", email: "", inoutStatus: false, position: ""))
            }
            
        }
    }
    // MARK: - bind User Info Method
    private func bindUserInfo() {
        UserDataViewModel.userDataViewModel.userDataForView.subscribe(
        onNext: { userData in
            self.positionLabel.text = userData.position
            self.nameLabel.text     = userData.name
            self.emailLabel.text    = userData.email
        }, onError: { error in
            ErrorHandler.generateSnackBarWithAction(title: error.localizedDescription, actionTitle: "ReFresh", onAction: self.bindUserInfo)
        }).disposed(by: self.disposebag)
    }
}
