//
//  RequestAppointmentConfirmationVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 3/8/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class RequestAppointmentConfirmationVC: UIViewController {
//    var form: AppointmentForm?
    var appointment: Appointment?
    @IBOutlet weak var appointmentConfirmationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Request Confirmation"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy 'at' HH:mm"
        var formattedDateTime = dateFormatter.string(from: appointment!.getTimeScheduled())
        
        self.appointmentConfirmationLabel.text = "Your request for an appointment with \(appointment!.getWithID()) on \(formattedDateTime) has been scheduled. If approved, you will receive a notification shortly."
        self.appointmentConfirmationLabel.sizeToFit()
        self.appointmentConfirmationLabel.layoutIfNeeded()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBackToCalendarButton(_ sender: Any) {
        
        // pop to CalendarVC class
        navigationController?.popToViewController(ofClass: CalendarVC.self)

        for appointment in appointmentList {
            print(appointment.getContent())
        }
        
//        _ = navigationController?.popViewController(animated: true)
//        _ = navigationController?.popViewController(animated: true)
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

extension UINavigationController {

  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
      popToViewController(vc, animated: animated)
    }
  }

  func popViewControllers(viewsToPop: Int, animated: Bool = true) {
    if viewControllers.count > viewsToPop {
      let vc = viewControllers[viewControllers.count - viewsToPop - 1]
      popToViewController(vc, animated: animated)
    }
  }

}

//class AppointmentForm: NSObject {
//    var doctor: String?
//    var dateAndTime: Date?
//    var appointmentDetails: String?
//}
