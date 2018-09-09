//
//  HealthKitSetUp.swift
//  TheDiaryHealthKit
//
//  Created by jonathan thornburg on 9/7/18.
//  Copyright © 2018 jonathan thornburg. All rights reserved.
//

import Foundation
import HealthKit

enum HealthKitSetUpError: String, Error {
    case notAvailableOnDevice = "HealthKit data is not available on this device."
    case dataTypeNotAvailable = "This datatype is not available through HealthKit."
}

struct HealthKitSetUp {
    
    static func authorizeHealthKit(handler: @escaping (Bool, Error?) -> ()) {
        guard HKHealthStore.isHealthDataAvailable() else {
            handler(false, HealthKitSetUpError.notAvailableOnDevice)
            return
        }
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            handler(false, HealthKitSetUpError.dataTypeNotAvailable)
            return
        }
        
        let healthKitWriteTypes: Set<HKSampleType> = [heartRate]
        let healthKitReadTypes: Set<HKObjectType> = [heartRate]
        
        HKHealthStore().requestAuthorization(toShare: healthKitWriteTypes, read: healthKitReadTypes) { (success, error) in
            handler(success, error)
        }
    }
}
