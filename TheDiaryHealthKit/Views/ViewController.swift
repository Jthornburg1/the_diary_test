//
//  ViewController.swift
//  TheDiaryHealthKit
//
//  Created by jonathan thornburg on 9/7/18.
//  Copyright © 2018 jonathan thornburg. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let hrViewModel = HeartRateViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "HealthKit Heart-Rates"
        
        tableView.tableFooterView = UIView()
        
        let permitHKButton = UIBarButtonItem(title: "PermitHK", style: .plain, target: self, action: #selector(self.requestHKPermission))
        navigationItem.rightBarButtonItems = [permitHKButton]
        let addHeartRateButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.presentAdderView))
        navigationItem.leftBarButtonItems = [addHeartRateButton]
        
        let start = Date(timeIntervalSince1970: 1536448060)
        let end = Date(timeIntervalSince1970: 1536448080)
        
        hrViewModel.writeHeartRate(beats: 215.0, start: start, end: end) { (success, error) in
            if !success {
                print(error?.localizedDescription ?? "no error provided")
            }
        }
        
        hrViewModel.readHeartRates { (success, error) in
            
        }
    }
    
    @objc func requestHKPermission() {
        HealthKitSetUp.authorizeHealthKit { (success, error) in
            print(error ?? "No error provided")
        }
    }
    
    @objc func presentAdderView() {
        print("Presenting AdderView!")
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

