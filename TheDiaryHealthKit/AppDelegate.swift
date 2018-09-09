//
//  AppDelegate.swift
//  TheDiaryHealthKit
//
//  Created by jonathan thornburg on 9/7/18.
//  Copyright © 2018 jonathan thornburg. All rights reserved.
//

import UIKit
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
    
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        healthStore.handleAuthorizationForExtension { (success, error) in
            
        }
    }
}

