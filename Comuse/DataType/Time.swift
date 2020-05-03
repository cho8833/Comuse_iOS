//
//  Time.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
struct Time: Codable {
    var hour: Int
    var minute: Int
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}
func == (lhs: Time, rhs: Time) -> Bool {
    return (lhs.hour == rhs.hour && lhs.minute == rhs.minute)
}
