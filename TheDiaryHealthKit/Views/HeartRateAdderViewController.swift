//
//  HeartRateAdderViewController.swift
//  TheDiaryHealthKit
//
//  Created by jonathan thornburg on 9/9/18.
//  Copyright © 2018 jonathan thornburg. All rights reserved.
//

import UIKit

class HeartRateAdderViewController: UIViewController {
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var ratePicker: UIPickerView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startSecondsPicker: UIPickerView!
    @IBOutlet weak var endSecondsPicker: UIPickerView!
    @IBOutlet var buttons: [UIButton]!
    
    var startDate: Date?
    var startDateBeforeSeconds: Date?
    var endDate: Date?
    var endDateBeforeSeconds: Date?
    var beatsCount: Int?
    var beatsRange = Array(30...220)
    var secondsRange = Array(1...59)
    var dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MM/dd/YY hh:mm:ss"
        startDatePicker.isHidden = true
        endDatePicker.isHidden = true
        ratePicker.isHidden = true
        ratePicker.delegate = self
        ratePicker.dataSource = self
        startSecondsPicker.delegate = self
        startSecondsPicker.dataSource = self
        endSecondsPicker.delegate = self
        endSecondsPicker.dataSource = self
        startSecondsPicker.isHidden = true
        endSecondsPicker.isHidden = true
        endDatePicker.maximumDate = Date()
        startDatePicker.maximumDate = Date()
        for button in buttons {
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.cornerRadius = 3
            button.backgroundColor = UIColor.blue
        }
        for label in labels {
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
        }
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveHeartRate))
        navigationItem.rightBarButtonItems = [saveButton]
    }
    
    
    @IBAction func setRate(_ sender: Any) {
        startDatePicker.isHidden = true
        endDatePicker.isHidden = true
        ratePicker.isHidden = false
        startSecondsPicker.isHidden = true
        endSecondsPicker.isHidden = true
    }
    
    @IBAction func setStartTime(_ sender: Any) {
        startDatePicker.isHidden = false
        endDatePicker.isHidden = true
        ratePicker.isHidden = true
        startSecondsPicker.isHidden = true
        endSecondsPicker.isHidden = true
    }
    @IBAction func setStartSeconds(_ sender: Any) {
        startDatePicker.isHidden = true
        endDatePicker.isHidden = true
        ratePicker.isHidden = true
        startSecondsPicker.isHidden = false
        endSecondsPicker.isHidden = true
    }
    
    @IBAction func setEndTime(_ sender: Any) {
        startDatePicker.isHidden = true
        endDatePicker.isHidden = false
        ratePicker.isHidden = true
        startSecondsPicker.isHidden = true
        endSecondsPicker.isHidden = true
    }
    @IBAction func setEndSeconds(_ sender: Any) {
        startDatePicker.isHidden = true
        endDatePicker.isHidden = true
        ratePicker.isHidden = true
        startSecondsPicker.isHidden = true
        endSecondsPicker.isHidden = false
    }
    
    @IBAction func didPickStartDate(_ sender: Any) {
        startDateBeforeSeconds = startDatePicker.date
        startDateLabel.text = dateFormatter.string(from: startDateBeforeSeconds!)
    }
    @IBAction func didPickEndDate(_ sender: Any) {
        endDateBeforeSeconds = endDatePicker.date
        endDateLabel.text = dateFormatter.string(from: endDateBeforeSeconds!)
    }
    
    func addSeconds(_ seconds: Int, _ preSecondsDate: Date?, _ finalDate: inout Date?) {
        if preSecondsDate != nil {
            finalDate = preSecondsDate?.addingTimeInterval(Double(seconds))
        }
    }
    
    @objc func saveHeartRate() {
        guard let startDt = startDateBeforeSeconds, let endDt = endDateBeforeSeconds, let beats = beatsCount else { presentAlert(); return }
        if startDate == nil {
            startDate = startDt
        }
        if endDate == nil {
            endDate = endDt
        }
        let viewModel = HeartRateViewModel()
        guard endDate! > startDate! else {
            let alertController = UIAlertController(title: "Error", message: "The start time must be before the end time", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
            return
        }
        viewModel.writeHeartRate(beats: Double(beats), start: startDate!, end: endDate!) { (success, error) in
            if success {
                let alertController = UIAlertController(title: "Success", message: "You've saved this heart rate!", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func presentAlert() {
        let alertController = UIAlertController(title: "Empty Fields", message: "To save a heart rate, you must set all fields. Either the BPM, start time, or end time are unset.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}

extension HeartRateAdderViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case ratePicker:
            return beatsRange.count
        default:
            return secondsRange.count
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 55
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case ratePicker:
            beatsCount = beatsRange[row]
            bpmLabel.text = "\(String(describing: beatsCount!)) BPM"
        case startSecondsPicker:
            addSeconds(secondsRange[row], startDateBeforeSeconds, &startDate)
            if let startDate = startDate {
                startDateLabel.text = dateFormatter.string(from: startDate)
            }
        case endSecondsPicker:
            addSeconds(secondsRange[row], endDateBeforeSeconds, &endDate)
            if let endDate = endDate {
                endDateLabel.text = dateFormatter.string(from: endDate)
            }
        default:
            print("no pickers left")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case ratePicker:
            return String(describing: beatsRange[row])
        default:
            return String(describing: secondsRange[row])
        }
    }
}
