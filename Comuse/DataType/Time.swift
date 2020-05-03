//
//  Time.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/01.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import ObjectMapper
struct Time: Mappable {
    var hour: Int
    var minute: Int
    
    init?(map: Map) {
        if let hour = map.JSON["hour"] as? Int{
            self.hour = hour
        } else { return nil }
        if let minute = map.JSON["minute"] as? Int {
            self.minute = minute
        } else { return nil }
    }
    mutating func mapping(map: Map) {
        self.hour<-map["hour"]
        self.minute<-map["minute"]
    }
}
func == (lhs: Time, rhs: Time) -> Bool {
    return (lhs.hour == rhs.hour && lhs.minute == rhs.minute)
}
