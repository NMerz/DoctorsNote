//
//  AddReminderVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSMobileClient


//var notificationsList = [NotificationPublisher]()
// Key: ReminderID, Value: corresponding notification publisher
var notificationsDict = [Int: NotificationPublisher]()

class AddReminderVC: UIViewController {
    @IBOutlet weak var newReminderField: UITextField!
    @IBOutlet weak var numTimesADayField: UITextField!
    @IBOutlet weak var everyNumDaysField: UITextField!
    @IBOutlet weak var newReminderDescriptionField: UITextField!
    @IBOutlet weak var addReminderButton: UIButton!
    
    var processor: ConnectionProcessor?

        
    @IBAction func addReminderButtonAction(_ sender: Any) {
        if newReminderField.text != "" {
            if numTimesADayField.text != "" {
                if everyNumDaysField.text != "" {
                    let content = newReminderField.text!
                    let intradayFrequency = Int(numTimesADayField.text!)!
                    let daysBetweenReminders = Int(everyNumDaysField.text!)!
                    let newReminder = Reminder(reminderID: 0, content: content, creatorID: "ignored", remindeeID: "37d6a758-e79f-442f-af49-6bff78c8ad10", timeCreated: Date(timeIntervalSinceNow: 0), intradayFrequency: intradayFrequency, daysBetweenReminders: daysBetweenReminders)

                    if newReminderDescriptionField.text != "" {
                        // TODO description
//                        newReminder.reminderDescription = newReminderDescriptionField.text!
                    }
                    
                    remindersList!.append(newReminder)
                    do {
                        try processor!.processNewReminder(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/reminderadd", reminder: newReminder)
                    }
                    catch let error {
                        // Fails to store message on server
                        print((error as! ConnectionError).getMessage())
                    }
                    
                    // Pull reminders from server
                    let connector = Connector()
                    AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
                    let processor = ConnectionProcessor(connector: connector)
                    do {
                        remindersList = try processor.processReminders(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/reminderlist", numberToRetrieve: 10000)
                    }
                    catch let error {
                        // Fails to store message on server
                        print((error as! ConnectionError).getMessage())
                    }
                    
                    newReminderField.text = ""
                    numTimesADayField.text = ""
                    everyNumDaysField.text = ""
                    newReminderDescriptionField.text = ""
                    
                    // Go back to RemindersVC
                    _ = navigationController?.popViewController(animated: true)
                    
                    // Don't need to add publisher here bc it will be added in cellForRowAt?
                    // TODO: better error check for integer casting
//                    let notificationPublisher = NotificationPublisher()
//                    notificationPublisher.sendReminderNotification(reminder: newReminder, title: "Reminder", body: "\(newReminder.getContent() )", badge: 1, numTimesDaily: Int(newReminder.getIntradayFrequency()) , everyNumDays: Int(newReminder.getDaysBetweenReminders()) )
////                    notificationsList.append(notificationPublisher)
//                    notificationsDict[newReminder.getReminderID()] = notificationPublisher
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
        var connector = Connector()
        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
        processor = ConnectionProcessor(connector: connector)
        //        self.selectedReminder = Reminder()
    }

}

//class Reminder2: NSObject {
//    var reminder: String?
//    var numTimesADay: String?
//    var everyNumDays: String?
//    var reminderDescription: String?
//}
