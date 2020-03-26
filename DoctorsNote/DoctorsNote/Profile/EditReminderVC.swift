//
//  AddReminderVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSMobileClient

class EditReminderVC: UIViewController {
    var processor: ConnectionProcessor?

    
    @IBOutlet weak var editReminderField: UITextField!
    @IBOutlet weak var editNumTimesADayField: UITextField!
    @IBOutlet weak var editEveryNumDaysField: UITextField!
    @IBOutlet weak var editReminderDescriptionField: UITextField!
    @IBOutlet weak var editReminderButton: UIButton!
        
    @IBAction func editReminderButtonAction(_ sender: Any) {
        if editReminderField.text != "" {
            if editNumTimesADayField.text != "" {
                if editEveryNumDaysField.text != "" {
                    let content = editReminderField.text!
                    let intradayFrequency = Int(editNumTimesADayField.text!)!
                    let daysBetweenReminders = Int(editEveryNumDaysField.text!)!
                remindersList![indexPathForButton!.row].setTimeCreated(newTime: Date(timeIntervalSinceNow: 0))
                    remindersList![indexPathForButton!.row].setContent(newContent: content)
                    remindersList![indexPathForButton!.row].setIntradayFrequency(newFrequency: intradayFrequency)
                    remindersList![indexPathForButton!.row].setDaysBetweenReminders(newInterval: daysBetweenReminders)

//                    let newReminder = Reminder(reminderID: 0, content: content, creatorID: "", remindeeID: "37d6a758-e79f-442f-af49-6bff78c8ad10", timeCreated: Date(timeIntervalSinceNow: 0), intradayFrequency: intradayFrequency, daysBetweenReminders: daysBetweenReminders)
//
//                    newReminder.reminder = editReminderField.text!
//                    newReminder.numTimesADay = editNumTimesADayField.text!
//                    newReminder.everyNumDays = editEveryNumDaysField.text!
                    if editReminderDescriptionField.text != "" {
//                        newReminder.reminderDescription = editReminderDescriptionField.text!
                    }
                    
//                    remindersList![indexPathForButton!.row] = newReminder
                    do {
                        try processor!.processEditReminder(deleteUrl: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/reminderdelete", addURl: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/reminderadd", reminder: remindersList![indexPathForButton!.row])
                    }
                    catch let error {
                        // Fails to store message on server
                        print((error as! ConnectionError).getMessage())
                    }
                    
                    // Remove previous notification info
//                    notificationsList[indexPathForButton!.row].removeReminderNotification()
                    notificationsDict[remindersList![indexPathForButton!.row].getReminderID()]?.removeReminderNotification(reminderId: remindersList![indexPathForButton!.row].getReminderID())
                    
                    // update notification info
                    let notificationPublisher = NotificationPublisher()
                    notificationPublisher.sendReminderNotification(reminder: remindersList![indexPathForButton!.row], title: "Reminder", body: "\(remindersList![indexPathForButton!.row].getContent() )", badge: 1, numTimesDaily: Int(remindersList![indexPathForButton!.row].getIntradayFrequency()) , everyNumDays: Int(remindersList![indexPathForButton!.row].getDaysBetweenReminders()) )
//                    notificationsList[indexPathForButton!.row] = notificationPublisher
                    notificationsDict[remindersList![indexPathForButton!.row].getReminderID()] = notificationPublisher
                    
                                        
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
        self.editReminderField.text = "\(selectedReminder!.getContent())"
        self.editNumTimesADayField.text = "\(selectedReminder!.getIntradayFrequency())"
        self.editEveryNumDaysField.text = "\(selectedReminder!.getDaysBetweenReminders())"
//        self.editReminderDescriptionField.text = "\(selectedReminder!.reminderDescription ?? "")"
        
        var connector = Connector()
        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
        processor = ConnectionProcessor(connector: connector)
    }

}
