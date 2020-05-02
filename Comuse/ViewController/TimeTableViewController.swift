//
//  TimeTableViewController.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import Elliotable

class TimeTableViewController: UIViewController, ElliotableDelegate, ElliotableDataSource {

    @IBOutlet weak var timeTable: Elliotable!
    private let day = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    private var items: [ElliottEvent] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        timeTable.delegate = self
        timeTable.dataSource = self
        timeTable.roundCorner = .none
        timeTable.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
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
extension TimeTableViewController {
    func elliotable(elliotable: Elliotable, didSelectCourse selectedCourse: ElliottEvent) {
        return
    }
    
    func elliotable(elliotable: Elliotable, didLongSelectCourse longSelectedCourse: ElliottEvent) {
        return
    }
    
    func elliotable(elliotable: Elliotable, at dayPerIndex: Int) -> String {
        return day[dayPerIndex]
    }
    
    func numberOfDays(in elliotable: Elliotable) -> Int {
        return day.count
    }
    
    func courseItems(in elliotable: Elliotable) -> [ElliottEvent] {
        return items
    }
}
