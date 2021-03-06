//
//  RemindersVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSMobileClient


// Global list of reminders for now, should start with empty
//var remindersList = [String]()
var remindersList: [Reminder]?

class RemindersVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ReminderCellDelegate {
    
    @IBOutlet weak var remindersTableView: UITableView!
    
    var selectedReminder: Reminder?
    var indexPathForButton: IndexPath?
    
    override func viewDidAppear(_ animated: Bool) {
        remindersTableView.reloadData()
    }
    
    var processor: ConnectionProcessor?

    
    override func viewDidLoad() {
        navigationItem.title = "Reminders"
        super.viewDidLoad()
                self.indexPathForButton = IndexPath()
        // Do any additional setup after loading the view.
        var connector = Connector()
        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
        processor = ConnectionProcessor(connector: connector)
    }
    
    
    // ReminderCellDelegate protocol stub (onclick individual info button) NOT NECESSARY?
    func didTapReminderInfo(reminder: Reminder) {
        self.selectedReminder = reminder
//        let alertTitle = "Edit alert"
//        let message = "\(reminder.reminder ?? "nil") will be edited"
//
//        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
    }
    
    // Order: 1. onInfoButtonTap 2. prepare 3. didTapReminderInfo
    // Apparently delegate function gets called last which makes sense
    @IBAction func onInfoButtonTap(_ sender: Any) {
        let button = sender as! UIButton
        let cell = button.superview!.superview! as! ReminderCell
        indexPathForButton = remindersTableView.indexPath(for: cell)
    }
    
    // Send info to segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditReminder" {
            self.selectedReminder = remindersList![indexPathForButton!.row]
            let editReminderVC = segue.destination as! EditReminderVC
            editReminderVC.selectedReminder = self.selectedReminder
            editReminderVC.indexPathForButton = self.indexPathForButton
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindersList!.count
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        defaults.dictionaryRepresentation().keys.forEach(defaults.removeObject(forKey:))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("\(String(indexPath.row)) cell starting")

        let reminder = remindersList![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell") as! ReminderCell
        cell.setReminder(reminder: reminder)
        cell.delegate = self
        
        // Check if this reminder has notification, add notification info if not
        //Ask device for notifcations registered by this app
        //Pair notifcations back up with reminders
        //Add any that do not exist (make sure to take creationTime into account!)
        
        // OR
        
        //Pull notification identifiers from storage
        //Remove all notifcations (or should I do this in ProfileViewController viewdidload)
//        resetDefaults()
        notificationsDict[reminder.getReminderID()]?.removeReminderNotification(reminderId: reminder.getReminderID())
        
        //Add notifcation for each reminder
        let notificationPublisher = NotificationPublisher()
        notificationPublisher.sendReminderNotification(reminder: reminder, title: "Reminder", body: "\(reminder.getContent() )", badge: 1, numTimesDaily: Int(reminder.getIntradayFrequency()) , everyNumDays: Int(reminder.getDaysBetweenReminders()) )
        //                    notificationsList.append(notificationPublisher)
        notificationsDict[reminder.getReminderID()] = notificationPublisher
        print()
        return cell
        
    }
    
    // Delete a reminder
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let reminder = remindersList![indexPath.row]

        print("starting delete")
        print("notifID from dict: \(notificationsDict[reminder.getReminderID()]!.getIdentifier())")
        print("notifID from userdefault: \(UserDefaults.standard.object(forKey: String(reminder.getReminderID())) ?? "_WHY_")")
        do {
            try processor?.processDeleteReminder(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/reminderdelete", reminder: remindersList![indexPath.row])
        }
        catch let error {
            // Fails to store message on server
            print((error as! ConnectionError).getMessage())
        }
        notificationsDict[reminder.getReminderID()]?.removeReminderNotification(reminderId: reminder.getReminderID())
//        notificationsList[indexPath.row].removeReminderNotification()
        notificationsDict.removeValue(forKey: reminder.getReminderID())
        remindersList!.remove(at: indexPath.row)
        remindersTableView.reloadData()
        print("deleted reminder")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
        

}
