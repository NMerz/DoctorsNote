//
//  RequestAppointmentVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 3/8/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class RequestAppointmentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var doctorDropdownButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateAndTimeField: UITextField!
    private var appointmentDatePicker: UIDatePicker!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailField: UITextField!
    @IBOutlet weak var submitAppointmentRequestButton: UIButton!
    
    let transparentView = UIView()
    let dropdownTableView = UITableView()
    
    var selectedButton = UIButton()
    
    var doctorList = [String]()
    
    var form: AppointmentForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Request Appointment"
        self.form = AppointmentForm()
        
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
        dropdownTableView.register(DropdownCell.self, forCellReuseIdentifier: "DropdownCell")
        // Do any additional setup after loading the view.
        
        appointmentDatePicker = UIDatePicker()
        // Not military time pls
//        appointmentDatePicker.locale = NSLocale(localeIdentifier: "en_US") as Locale
        appointmentDatePicker?.datePickerMode = .dateAndTime
        appointmentDatePicker?.addTarget(self, action: #selector(dateTimeChanged(appointmentDatePicker:)), for: .valueChanged)
        
        // Get rid of date/time popup
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
//        view.addGestureRecognizer(tapGesture)
        
        dateAndTimeField.inputView = appointmentDatePicker
        
    }
    
//    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
//        view.endEditing(true)
//    }
    
    @objc func dateTimeChanged(appointmentDatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy 'at' HH:mm"
        dateAndTimeField.text = dateFormatter.string(from: appointmentDatePicker.date)
        view.endEditing(true)
    }
    
    func addTransparentView(frames: CGRect) {
        // Add transparent background
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first // shared.keyWindow depreciated
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        // Add dropdown table
        dropdownTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(dropdownTableView)
        dropdownTableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        // Update doctorList
        dropdownTableView.reloadData()
        
        // Remove transparent background
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.transparentView.alpha = 0.2
            
            // 50 is height of one row
            self.dropdownTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.doctorList.count * 50))
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, animations: {
            self.transparentView.alpha = 0
            self.dropdownTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
        }, completion: nil)
        
    }
    
    @IBAction func onClickDoctorDropdown(_ sender: Any) {
        // Connect hospital list to API later
        doctorList = ["Doctor 1", "Doctor 2", "Doctor 3"]
        selectedButton = doctorDropdownButton
        addTransparentView(frames: doctorDropdownButton.frame)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
        cell.textLabel?.text = doctorList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedButton.setTitle(doctorList[indexPath.row], for: .normal)
        removeTransparentView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.form?.doctor = doctorDropdownButton.titleLabel?.text
        self.form?.dateAndTime = appointmentDatePicker.date
        
        self.form?.appointmentDetails = detailField.text
        let requestConfirmation = segue.destination as! RequestAppointmentConfirmationVC
        requestConfirmation.form = self.form
    }
    
    // Check for invalid input
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        if let doctor = doctorDropdownButton.titleLabel?.text, doctor == "Select Doctor" {
            let alertController2 = UIAlertController(title: "hol up", message: "Please select a doctor.", preferredStyle: .alert)
            alertController2.addAction(okAction)
            self.present(alertController2, animated: true, completion: nil)
            return false
        }
        if let details = detailField.text, details.count <= 10 {
            let alertController3 = UIAlertController(title: "hol up", message: "Appointment details must be at least 10 characters long.", preferredStyle: .alert)
            alertController3.addAction(okAction)
            self.present(alertController3, animated: true, completion: nil)
            return false
        }
        // Date and time
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
