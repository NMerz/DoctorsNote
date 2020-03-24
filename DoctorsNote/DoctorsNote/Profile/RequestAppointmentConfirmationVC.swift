//
//  RequestAppointmentConfirmationVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 3/8/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class RequestAppointmentConfirmationVC: UIViewController {
    var form: AppointmentForm?
    @IBOutlet weak var appointmentConfirmationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Request Confirmation"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy 'at' HH:mm"
        var formattedDateTime = dateFormatter.string(from: form!.dateAndTime!)
        
        self.appointmentConfirmationLabel.text = "Your request for an appointment with \(form!.doctor!) on \(formattedDateTime) has been scheduled. If approved, you will receive a notification shortly."
        self.appointmentConfirmationLabel.sizeToFit()
        self.appointmentConfirmationLabel.layoutIfNeeded()

        // Do any additional setup after loading the view.
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

class AppointmentForm: NSObject {
    var doctor: String?
    var dateAndTime: Date?
    var appointmentDetails: String?
}
