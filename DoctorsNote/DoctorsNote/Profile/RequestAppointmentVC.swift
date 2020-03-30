//
//  RequestAppointmentVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 3/8/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSMobileClient

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
    var processor: ConnectionProcessor?
    
    var selectedButton = UIButton()
    
    // Is doctorlist specific to user or same for everyone
    // Name, ID
    var doctorList = [(String, String)]()
    var thisId: String?
    var thisName: String?
    
//    var form: AppointmentForm?
    var appointment: Appointment?
    var date: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var connector = Connector()
        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
        processor = ConnectionProcessor(connector: connector)
        navigationItem.title = "Request Appointment"
//        self.form = AppointmentForm()
        dropdownTableView.accessibilityIdentifier = "Dropdown"
        
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
        dropdownTableView.register(DropdownCell.self, forCellReuseIdentifier: "DropdownCell")
        // Do any additional setup after loading the view.
        
        appointmentDatePicker = UIDatePicker()
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
        
        // Includes time as well?
        self.appointment?.setTimeScheduled(newTime: appointmentDatePicker.date)
        date = appointmentDatePicker.date
        
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
        // Connect doctor list to backend
        let (potentialConversationList, error) = (processor?.processConversationList(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/ConversationList"))!
        if error != nil {
            //Panic
        } else {
            let converversationList = potentialConversationList!
            for conversation in converversationList {
                // If conversation isn't support group
                if conversation.getConverserID() != "N/A" {
                    var newDoctorList = [(String, String)]()
                    newDoctorList.append((conversation.getConversationName(), conversation.getConverserID()))
                    doctorList = newDoctorList
                }
            }
        }
        
        //doctorList = ["Doctor 1", "Doctor 2", "Doctor 3"]
        selectedButton = doctorDropdownButton
        addTransparentView(frames: doctorDropdownButton.frame)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
        let (docName, _) = doctorList[indexPath.row]
        cell.textLabel?.text = docName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (docName, docId) = doctorList[indexPath.row]
        thisId = docId
        thisName = docName
        selectedButton.setTitle(docName, for: .normal)
        removeTransparentView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // AppointmentID?
        self.appointment = Appointment(appointmentID: 0, content: detailField.text!, timeScheduled: self.date, withID: thisId!)
        do {
            try processor?.processNewAppointment(url: "tdb", appointment: appointment!)
            
        } catch let error {
            print((error as! ConnectionError).getMessage())
        }
        //appointmentList.append(self.appointment!)
//        self.form?.doctor = doctorDropdownButton.titleLabel?.text
//        self.form?.dateAndTime = appointmentDatePicker.date
//
//        self.form?.appointmentDetails = detailField.text
        let requestConfirmation = segue.destination as! RequestAppointmentConfirmationVC
//        requestConfirmation.form = self.form
        // Pass name of doctor
        requestConfirmation.appointment = self.appointment
        requestConfirmation.docName = self.thisName
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

}
