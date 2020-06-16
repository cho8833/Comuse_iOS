//
//  TimeTableViewController.swift
//  Comuse
//
//  Created by 조현빈 on 2020/06/03.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import Elliotable
import FirebaseAuth
import RxSwift

class TimeTableViewController: UIViewController, ElliotableDelegate, ElliotableDataSource {
    
    @IBOutlet weak var timeTable: Elliotable!
    private let backgroundColors = [ 0xecc369, 0xa7ca70, 0x7dd1c1, 0x7aa5e9, 0xfbaa68, 0x9f86e1, 0x78cb87, 0xd397ed ]
    private var colorIndex: Int = 0
    private var items: [ElliottEvent] = []
    private let day = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    private let disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TimeTable Setting
        timeTable.delegate = self
        timeTable.dataSource = self
        timeTable.roundCorner = .none
        timeTable.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.1)
        timeTable.borderWidth = 1
        
        // bind Schedule to TimeTable
        self.bindSchedules()
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in         // Login State Listener
            if let _ = user {
                ScheduleViewModel.scheduleViewModel.getSchedules()
            }
        }
    }
    //MARK: - bind Schedules to TimeTable Method
    private func bindSchedules() {
        ScheduleViewModel.scheduleViewModel.schedulesForView.subscribe(
            onNext: { schedules in
                self.items.removeAll()
                schedules.forEach { schedule in
                    self.addCourse(schedule: schedule)
                }
                self.timeTable.reloadData()
            },
            onError: { error in
                ErrorHandler.generateSnackBarWithAction(title: error.localizedDescription, actionTitle: "ReFresh", onAction: self.bindSchedules)
            }
        ).disposed(by: self.disposebag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue" {
            if let sender: ElliottEvent = sender as? ElliottEvent {
                guard let nextViewController: EditAddScheduleViewController = segue.destination as? EditAddScheduleViewController else {
                    return
                }
                // Edit/AddScheduleViewController 의 view 들의 초기 정보를 전달한다.
                nextViewController.selectedDay = sender.courseDay.rawValue
                nextViewController.classTitle = sender.courseName
                nextViewController.startTime = sender.startTime
                nextViewController.endTime = sender.endTime
                nextViewController.isEdit = true
                nextViewController.scheduleIdBeforeEdit = sender.courseId
                
            }
        }
    }
    
}
//MARK: TimeTable Delegate Methods
extension TimeTableViewController {
    func elliotable(elliotable: Elliotable, didSelectCourse selectedCourse: ElliottEvent) {
        if let user = FirebaseVar.user {
            if selectedCourse.professor == user.email {
                let alert = UIAlertController(title: nil, message: "Manage Schedule", preferredStyle: .actionSheet)
                
                // edit button
                let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
                    self.performSegue(withIdentifier: "editSegue", sender: selectedCourse)
                }
                
                // remove button
                let removeAction = UIAlertAction(title: "Remove", style: .default) { (action) in
                    ScheduleViewModel.scheduleViewModel.deleteSchedule(scheduleKey: selectedCourse.courseId)
                }
                
                // cancel button
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(editAction)
                alert.addAction(removeAction)
                alert.addAction(cancelAction)
                present(alert, animated: false, completion: nil)
            }
            else { return }
        }
    }
    
    func elliotable(elliotable: Elliotable, didLongSelectCourse longSelectedCourse: ElliottEvent) {
    
    }
    
}
//MARK: TimeTable DataSource Methods
extension TimeTableViewController {
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
// MARK: -TimeTable Course Control Methods
extension TimeTableViewController {
    func addCourse(schedule: Schedule) -> Void {
        let startTimeHour: String = String(format: "%02d", schedule.startTimeHour)
        let endTimeHour = String(format: "%02d", schedule.endTimeHour)
        let startTimeMinute: String = String(format: "%02d", schedule.startTimeMinute)
        let endTimeMinute: String = String(format: "%02d", schedule.endTimeMinute)
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
    // 0x000000 -> UIColor
    class func colorWithRGBHex(hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue:CGFloat(b / 255.0), alpha: CGFloat(alpha))
    }
}
