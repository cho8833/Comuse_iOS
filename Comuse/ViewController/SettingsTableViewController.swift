//
//  SettingsViewController.swift
//  Comuse
//
//  Created by 조현빈 on 2020/06/08.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBAction func touchUpEditPositionButton(_ sender: Any) {
        if let _ = FirebaseVar.user {
            let alert = UIAlertController(title: "Edit Position", message: "Input Position", preferredStyle: .alert)
            // ok button
            let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
                if let position = alert.textFields?[0].text {
                    self.userDataViewModel.updatePosition(position: position)
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
        
    }
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    private var userDataViewModel = UserDataViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDataViewModel.getUserData().subscribe(onNext: { userData in
            self.positionLabel.text = userData.position
            self.nameLabel.text     = userData.name
            self.emailLabel.text    = userData.email
        })
        // Do any additional setup after loading the view.
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
