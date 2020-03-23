//
//  AddReminderVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class AddReminderVC: UIViewController {
    @IBOutlet weak var newReminderField: UITextField!
    @IBOutlet weak var numTimesADayField: UITextField!
    @IBOutlet weak var everyNumDaysField: UITextField!
    @IBOutlet weak var newReminderDescriptionField: UITextField!
    @IBOutlet weak var addReminderButton: UIButton!
    
    private let notificationPublisher = NotificationPublisher()
    
    @IBAction func addReminderButtonAction(_ sender: Any) {
        if newReminderField.text != "" {
            if numTimesADayField.text != "" {
                if everyNumDaysField.text != "" {
                    let newReminder = Reminder()
                    newReminder.reminder = newReminderField.text!
                    newReminder.numTimesADay = numTimesADayField.text!
                    newReminder.everyNumDays = everyNumDaysField.text!
                    if newReminderDescriptionField.text != "" {
                        newReminder.reminderDescription = newReminderDescriptionField.text!
                    }
                    
                    remindersList.append(newReminder)
                    
                    newReminderField.text = ""
                    numTimesADayField.text = ""
                    everyNumDaysField.text = ""
                    newReminderDescriptionField.text = ""
                    
                    notificationPublisher.sendNotification(title: "Reminder", body: "\(newReminder.reminder ?? "")", badge: 1, delayInterval: nil)
                }
            }
        }
        else {
            // TODO fix alert, it's not showing atm
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let alertController2 = UIAlertController(title: "hol up", message: "Please enter reminder and frequency.", preferredStyle: .alert)
            alertController2.addAction(okAction)
            self.present(alertController2, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Reminder"
    }

}

class Reminder: NSObject {
    var reminder: String?
    var numTimesADay: String?
    var everyNumDays: String?
    var reminderDescription: String?
}
