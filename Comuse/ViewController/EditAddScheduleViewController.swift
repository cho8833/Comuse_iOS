//
//  EditAddScheduleViewController.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/06.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit

class EditAddScheduleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var dayPicker: UIPickerView!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBAction func touchUpCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func touchUpAddButton(_ sender: Any) {
        guard let classTitle = self.titleTextField.text, classTitle.isEmpty == false else {
            self.showAlert(message: "Input Title", control: titleTextField)
            return
        }
        if let user = FirebaseVar.user {
            let calendar = Calendar(identifier: .gregorian)
            let selectedHour_start = calendar.component(.hour, from: startTimePicker.date)
            let selectedMinute_start = calendar.component(.minute, from: startTimePicker.date)
            let selectedHour_end = calendar.component(.hour, from: endTimePicker.date)
            let selectedMinute_end = calendar.component(.minute, from: endTimePicker.date)
            
            let startTimeObject = Time(hour: selectedHour_start, minute: selectedMinute_start)
            let endTimeObject = Time(hour: selectedHour_end, minute: selectedMinute_end)
            
            let schedule = Schedule(day: selectedDay, startTime: startTimeObject, endTime: endTimeObject, classPlace: "", professorName: user.uid, classTitle: classTitle)
            
            if Schedule.addSchedule(schedule: schedule) == false {
                self.showAlert(message: "Wrong Schedule", control: nil)
            }
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    private let days: [String] = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    public var selectedDay: Int = 0
    public var startTime: String? = "00:00"
    public var endTime: String? = "00:00"
    public var classTitle: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        dayPicker.delegate = self
        dayPicker.dataSource = self
        // Do any additional setup after loading the view.
        
        timePickerSettings(timePicker: startTimePicker)
        timePickerSettings(timePicker: endTimePicker)
        dayPicker.selectRow(selectedDay-1, inComponent: 0, animated: true)
        if let title = classTitle {
            titleTextField.text = title
        }
        if let startTime = self.startTime {
            if let endTime = self.endTime {
                let startHour = Int(startTime.split(separator: ":")[0])!
                let startMinute = Int(startTime.split(separator: ":")[1])!
                let endHour = Int(endTime.split(separator: ":")[0])!
                let endMinute = Int(endTime.split(separator: ":")[1])!
                
                let current: NSDate = NSDate()
                let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
                
                let components: NSDateComponents = gregorian.components(([.day, .month, .year]), from: current as Date) as NSDateComponents
                components.hour = startHour
                components.minute = startMinute
                components.second = 0
                let startDate: NSDate = gregorian.date(from: components as DateComponents)! as NSDate
                
                components.hour = endHour
                components.minute = endMinute
                components.second = 0
                let endDate: NSDate = gregorian.date(from: components as DateComponents)! as NSDate
                startTimePicker.setDate(startDate as Date, animated: true)
                endTimePicker.setDate(endDate as Date, animated: true)
            }
        }
        
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
//MARK: DayPicker Settings
extension EditAddScheduleViewController {
    //DataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count
    }
    //Delegate Methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return days[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedDay = row
    }
    
}
//MARK: DatePicker Settings
extension EditAddScheduleViewController {
    func timePickerSettings(timePicker: UIDatePicker) -> Void {
        // set Maximum, minimum time
        let startHour: Int = 9
        let endHour: Int = 23
        let current: NSDate = NSDate()
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let components: NSDateComponents = gregorian.components(([.day, .month, .year]), from: current as Date) as NSDateComponents
        components.hour = startHour
        components.minute = 0
        components.second = 0
        let startDate: NSDate = gregorian.date(from: components as DateComponents)! as NSDate
        
        components.hour = endHour
        components.minute = 0
        components.second = 0
        let endDate: NSDate = gregorian.date(from: components as DateComponents)! as NSDate
        
        timePicker.datePickerMode = .time
        timePicker.minimumDate = startDate as Date
        timePicker.maximumDate = endDate as Date
        timePicker.reloadInputViews()
        
        // set action
        if timePicker == startTimePicker {
            timePicker.addTarget(self, action: #selector(timeChanged_startTime), for: .valueChanged)
        }
        else {
            timePicker.addTarget(self, action: #selector(timeChanged_endTime), for: .valueChanged)
        }
    }
    // set startTimePicker valueChanged Methods
    @objc func timeChanged_startTime() -> Void {
        let startDate = startTimePicker.date
        let endDate = endTimePicker.date
        if startDate >= endDate {
            let endDate = Date(timeInterval: 3600, since: startDate)
            endTimePicker.setDate(endDate, animated: true)
        } else { return }
    }
    // set endTimePicker valueChanged Methods
    @objc func timeChanged_endTime() -> Void {
        var startDate = startTimePicker.date
        let endDate = endTimePicker.date
        if endDate <= startDate {
            startDate = Date(timeInterval: -3600, since: endDate)
            startTimePicker.setDate(startDate, animated: true)
        } else { return }
    }
}
//MARK: privates
extension EditAddScheduleViewController {
    
    private func showAlert(message: String, control toBeFirstResponder: UIControl?) -> Void {
        let alert: UIAlertController = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Input", style: UIAlertAction.Style.default) { [weak toBeFirstResponder] (action: UIAlertAction) in toBeFirstResponder?.becomeFirstResponder()
        }
        let cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancel)
        self.present(alert,animated: true)
    }
 
}
