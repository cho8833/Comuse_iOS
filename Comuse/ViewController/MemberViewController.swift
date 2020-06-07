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
class MemberViewController: UIViewController {
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inoutButton: UIButton!
    @IBAction func touchUpInoutButton(_ sender: UIButton) {
        if (sender.titleLabel?.text == "in") {
            userDataViewModel.updateInoutStatus(inoutStatus: false)
        } else {
            userDataViewModel.updateInoutStatus(inoutStatus: true)
        }
    }
    
    @IBOutlet weak var memberTable: UITableView!
    
    let nameLabelTag = 101
    let positionLabelTag = 102
    let inoutStatusLabelTag = 103
    private var memberViewModel = MemberViewModel()
    private var userDataViewModel = UserDataViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // bind members to TableView
        memberViewModel.getMembers().bind(to: memberTable.rx.items(cellIdentifier: "memberCell")) { row, element, cell in
            (cell.viewWithTag(self.nameLabelTag) as! UILabel).text = element.name
            (cell.viewWithTag(self.positionLabelTag) as! UILabel).text = element.position
            (cell.viewWithTag(self.inoutStatusLabelTag) as! UILabel).text = element.inoutStatus.description
        }
        
        // bind userData in User Info
        userDataViewModel.getUserData().subscribe(onNext: { userData in
            self.positionLabel.text = userData.position
            self.nameLabel.text = userData.name
            if (userData.inoutStatus == true) { self.inoutButton.titleLabel?.text = "in" }
            else { self.inoutButton.titleLabel?.text = "out" }
        })
        
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
