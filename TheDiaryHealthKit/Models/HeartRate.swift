//
//  HeartRate.swift
//  TheDiaryHealthKit
//
//  Created by jonathan thornburg on 9/8/18.
//  Copyright © 2018 jonathan thornburg. All rights reserved.
//

import Foundation

struct HeartRate {
    
    var beats: Int?
    var startDate: Date?
    var endDate: Date?
    var uuid: String?
    
    init(beats: Int, startDate: Date, endDate: Date, uuid: String) {
        self.beats = beats
        self.startDate = startDate
        self.endDate = endDate
        self.uuid = uuid
    }
}
