//
//  HeartRateViewModel.swift
//  TheDiaryHealthKit
//
//  Created by jonathan thornburg on 9/8/18.
//  Copyright © 2018 jonathan thornburg. All rights reserved.
//

import Foundation
import HealthKit

class HeartRateViewModel {
    
    var heartRates = [HeartRate]()
    let hkStore = HKHealthStore()
    
    func readHeartRates(completion: @escaping (Bool,Error?) -> ()) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType!, predicate: nil, limit: 100, sortDescriptors: [sortDescriptor]) { (query, heartRateData, error) in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    return completion(false, error)
                })
            }
            
            guard let hrData = heartRateData else { return completion(false, error) }
            print("here are the HKSamples: ")
            for sample in hrData {
                if let currentSample = sample as? HKQuantitySample {
                    print(currentSample)
                }
            }
        }
        HKHealthStore().execute(heartRateQuery)
    }
    
    func writeHeartRate(beats: Double, start: Date, end: Date, handler: @escaping (Bool, Error?) -> ()) {
        let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let quantity = HKQuantity(unit: unit, doubleValue: beats)
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            DispatchQueue.main.async {
                handler(false, nil)
            }
            return
        }
        let heartRateSample = HKQuantitySample(type: type, quantity: quantity, start: start, end: end)
        hkStore.save(heartRateSample) { (success, error) in
            DispatchQueue.main.async(execute: {
                handler(success, error)
            })
        }
    }
}
