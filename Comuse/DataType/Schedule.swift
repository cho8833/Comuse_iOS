//
//  Schedule.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit

struct Schedule {
    var day: Int
    var startTime: Time
    var endTime: Time
    var classPlace: String?
    var professorName: String
    var classTitle: String
    init(day: Int, startTime: Time, endTime: Time, professorName: String, classTitle: String) {
        self.day = day
        self.startTime = startTime
        self.endTime = endTime
        self.classPlace = nil
        self.professorName = professorName
        self.classTitle = classTitle
    }
    

}
