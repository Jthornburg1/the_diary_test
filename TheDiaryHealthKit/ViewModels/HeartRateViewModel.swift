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
    
    func loadHeartRates(completion: @escaping (Bool, Error?) -> ()) {
        readHeartRates { (heartRateData, error) in
            guard let hrData = heartRateData else { return completion(false, error) }
            self.heartRates.removeAll()
            for sample in hrData {
                if let currentSample = sample as? HKQuantitySample {
                    let heartRateUnit = HKUnit(from: "count/min")
                    let beats = currentSample.quantity.doubleValue(for: heartRateUnit)
                    let startDate = currentSample.startDate
                    let endDate = currentSample.endDate
                    let uuid = String(describing: currentSample.uuid)
                    let heartRate = HeartRate(beats: Int(beats), startDate: startDate, endDate: endDate, uuid: uuid)
                    self.heartRates.append(heartRate)
                }
            }
            DispatchQueue.main.async(execute: {
                completion(true, error)
            })
        }
    }
    
    func readHeartRates(completion: @escaping ([HKSample]?,Error?) -> ()) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType!, predicate: nil, limit: 100, sortDescriptors: [sortDescriptor]) { (query, heartRateData, error) in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    return completion(nil, error)
                })
            }
            guard let hrData = heartRateData else { return completion(nil, error) }
            DispatchQueue.main.async(execute: {
                completion(hrData, error)
            })
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
    
    func deleteHeartRate(with uuid: String, completion: @escaping (Bool, Error?) -> ()) {
        
        readHeartRates { (heartRateData, error) in
            guard let hrData = heartRateData else {
                DispatchQueue.main.async(execute: {
                    completion(false, error)
                })
                return
            }
            for sample in hrData {
                if String(describing: sample.uuid) == uuid {
                    self.hkStore.delete(sample, withCompletion: { (success, error) in
                        DispatchQueue.main.async(execute: {
                            completion(success, error)
                        })
                    })
                }
            }
        }
    }
    
    func getRate(at index: Int) -> Int {
        guard let beats = heartRates[index].beats else { return 0 }
        return beats
    }
    
    func getStartDate(at index: Int) -> Date {
        guard let stDate = heartRates[index].startDate else { return Date() }
        return stDate
    }
    
    func getEndDate(at index: Int) -> Date {
        guard let endDate = heartRates[index].endDate else { return Date() }
        return endDate
    }
    
    func getUUID(at index: Int) -> String {
        guard let uuid = heartRates[index].uuid else { return "" }
        return uuid
    }
}
