//
//  AddReminderVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class EditReminderVC: UIViewController {
    @IBOutlet weak var editReminderField: UITextField!
    @IBOutlet weak var editNumTimesADayField: UITextField!
    @IBOutlet weak var editEveryNumDaysField: UITextField!
    @IBOutlet weak var editReminderDescriptionField: UITextField!
    @IBOutlet weak var editReminderButton: UIButton!
        
    @IBAction func editReminderButtonAction(_ sender: Any) {
        if editReminderField.text != "" {
            if editNumTimesADayField.text != "" {
                if editEveryNumDaysField.text != "" {
                    let newReminder = Reminder()
                    newReminder.reminder = editReminderField.text!
                    newReminder.numTimesADay = editNumTimesADayField.text!
                    newReminder.everyNumDays = editEveryNumDaysField.text!
                    if editReminderDescriptionField.text != "" {
                        newReminder.reminderDescription = editReminderDescriptionField.text!
                    }
                    
                    remindersList[indexPathForButton!.row] = newReminder
                    
                    // Remove previous notification info
                    notificationsList[indexPathForButton!.row].removeReminderNotification()
                    
                    // update notification info
                    let notificationPublisher = NotificationPublisher()
                    notificationPublisher.sendReminderNotification(title: "Reminder", body: "\(newReminder.reminder ?? "")", badge: 1, numTimesDaily: Int(newReminder.numTimesADay!) ?? 1, everyNumDays: Int(newReminder.everyNumDays!) ?? 1)
                    notificationsList[indexPathForButton!.row] = notificationPublisher
                                        
                    // Confirm edit completed
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    let alertController2 = UIAlertController(title: "Edit Complete", message: "Your reminder has been updated.", preferredStyle: .alert)
                    alertController2.addAction(okAction)
                    self.present(alertController2, animated: true, completion: nil)
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
    
    
    var selectedReminder: Reminder?
    var indexPathForButton: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit Reminder"
        self.editReminderField.text = "\(selectedReminder!.reminder!)"
        self.editNumTimesADayField.text = "\(selectedReminder!.numTimesADay!)"
        self.editEveryNumDaysField.text = "\(selectedReminder!.everyNumDays!)"
        self.editReminderDescriptionField.text = "\(selectedReminder!.reminderDescription ?? "")"
    }

}
