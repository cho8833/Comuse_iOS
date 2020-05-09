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
    private let backgroundColors = [ 0xecc369, 0xa7ca70, 0x7dd1c1, 0x7aa5e9, 0xfbaa68, 0x9f86e1, 0x78cb87, 0xd397ed ]
    private var colorIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeTable.delegate = self
        timeTable.dataSource = self
        timeTable.roundCorner = .none
        timeTable.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.1)
        timeTable.borderWidth = 1
        // Do any additional setup after loading the view.
        Schedule.getSchedules(reload: timeTable.reloadData, addFunc: addCourse, removeFunc: removeCourse)
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "editSegue" {
            if let sender: ElliottEvent = sender as? ElliottEvent {
                guard let nextViewController: EditAddScheduleViewController = segue.destination as? EditAddScheduleViewController else {
                    return
                }
                nextViewController.selectedDay = sender.courseDay.rawValue
                nextViewController.classTitle = sender.courseName
                nextViewController.startTime = sender.startTime
                nextViewController.endTime = sender.endTime
                
                
            }
        }
    }

    

}
//MARK: -DataSource Methods
extension TimeTableViewController {
    
    func elliotable(elliotable: Elliotable, at dayPerIndex: Int) -> String {
        return day[dayPerIndex]
    }
    
    func numberOfDays(in elliotable: Elliotable) -> Int {
        return day.count
    }
}
//MARK: -Delegate Methods
extension TimeTableViewController {
    func addCourse(schedule: Schedule) -> Void {
        let startTimeHour: String = String(format: "%02d", schedule.startTime.hour)
        let endTimeHour = String(format: "%02d", schedule.endTime.hour)
        let startTimeMinute: String = String(format: "%02d", schedule.startTime.minute)
        let endTimeMinute: String = String(format: "%02d", schedule.endTime.minute)
        let startTime = startTimeHour + ":" + startTimeMinute
        let endTime = endTimeHour + ":" + endTimeMinute
        let id = startTimeHour + startTimeMinute + endTimeHour + endTimeMinute + String(schedule.day)
        if let rawDay = ElliotDay(rawValue: schedule.day+1) {
            let course = ElliottEvent(courseId: id, courseName: schedule.classTitle, roomName: "", professor: schedule.professorName, courseDay: rawDay, startTime: startTime, endTime: endTime, backgroundColor: getBackgroundColor())
            items.append(course)
        }
        
    }
    func removeCourse(id: String) -> Void {
        if let removeIndex = items.firstIndex(where: { $0.courseId == id}) {
            items.remove(at: removeIndex)
        }
    }
    func courseItems(in elliotable: Elliotable) -> [ElliottEvent] {
        return items
    }
    func elliotable(elliotable: Elliotable, didSelectCourse selectedCourse: ElliottEvent) {
        if let user = FirebaseVar.user {
            if selectedCourse.professor == user.uid {
                let alert = UIAlertController(title: nil, message: "Manage Schedule", preferredStyle: .actionSheet)
                let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
                    self.performSegue(withIdentifier: "editSegue", sender: selectedCourse)
                }
                let removeAction = UIAlertAction(title: "Remove", style: .default) { (action) in
                    Schedule.removeSchedule(documentID: selectedCourse.courseId)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(editAction)
                alert.addAction(removeAction)
                alert.addAction(cancelAction)
                present(alert, animated: false, completion: nil)
            }
            else { return }
        }
        return
    }
    
    func elliotable(elliotable: Elliotable, didLongSelectCourse longSelectedCourse: ElliottEvent) {
        return
    }
}
//MARK: Privates
extension TimeTableViewController {
    private func getBackgroundColor() -> UIColor {
        if self.colorIndex == backgroundColors.count {
            colorIndex = 0
        } else { colorIndex += 1}
        return UIColor.colorWithRGBHex(hex: backgroundColors[colorIndex])
    }
}
extension UIColor {
    class func colorWithRGBHex(hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue:CGFloat(b / 255.0), alpha: CGFloat(alpha))
    }
}
