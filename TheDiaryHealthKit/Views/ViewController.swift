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
        
        title = "Heart-Rates"
        
        tableView.tableFooterView = UIView()
        
        let permitHKButton = UIBarButtonItem(title: "PermitHK", style: .plain, target: self, action: #selector(self.requestHKPermission))
        navigationItem.rightBarButtonItems = [permitHKButton]
        let addHeartRateButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.presentAdderView))
        navigationItem.leftBarButtonItems = [addHeartRateButton]
        
        let cellNib = UINib(nibName: "HeartRateCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "HeartRateCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hrViewModel.loadHeartRates { (success, error) in
            if success {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func requestHKPermission() {
        HealthKitSetUp.authorizeHealthKit { (success, error) in
            print(error ?? "No error provided")
        }
    }
    
    @objc func presentAdderView() {
        let adderViewController = HeartRateAdderViewController()
        navigationController?.pushViewController(adderViewController, animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YY hh:mm:ss"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeartRateCell") as? HeartRateCell else { return UITableViewCell() }
        cell.beatsLabel.text = String(describing: hrViewModel.getRate(at: indexPath.row))
        cell.startDateLabel.text = formatter.string(from: hrViewModel.getStartDate(at: indexPath.row))
        cell.endDateLabel.text = formatter.string(from: hrViewModel.getEndDate(at: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hrViewModel.heartRates.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if let uuid = hrViewModel.heartRates[indexPath.row].uuid {
                hrViewModel.deleteHeartRate(with: uuid) { (success, error) in
                    if success {
                        self.hrViewModel.loadHeartRates(completion: { (success, error) in
                            if success {
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
            }
        }
    }
}

