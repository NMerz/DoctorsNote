//
//  ProfileViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSCognito
import AWSMobileClient
import UserNotifications

class ProfileViewController: UIViewController {
   
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var personalInfoView: PersonalInfoView!
    @IBOutlet weak var remindersPreviewView: UIView!
    @IBOutlet weak var remindersPreviewLabel: UILabel!
    @IBOutlet weak var viewRemindersButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        remindersPreviewLabel.text = "You currently have \(remindersList.count) reminder(s)."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // 1. Ask for notifiction permission
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
//            // TODO: if !granted, tell user they can change notification settings later on
//        }
//        
//        // 2. Create notification content
//        let content = UNMutableNotificationContent()
//        content.title = "Reminder"
//        content.body = "Reminder name"
//        content.sound = UNNotificationSound.default
//
//        // 3. Create notification trigger (modify this)
//        let date = Date().addingTimeInterval(30)
//        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//
//        // 4. Create the request
//        let uuidString = UUID().uuidString
//        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
//
//        // 5. Register request with notification center
//        center.add(request) { (error) in
//            // Check the error parameter and handle any errors
//        }

        logOutButton.semanticContentAttribute = UIApplication.shared
        .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        
        personalInfoView.layer.shadowColor = UIColor.darkGray.cgColor
        personalInfoView.layer.shadowRadius = 5
        personalInfoView.layer.shadowOpacity = 0.5
        personalInfoView.layer.shadowOffset = CGSize.zero
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: personalInfoView.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        
        AWSMobileClient.default().getUserAttributes { (attr, err) in
            if let err = err as? AWSMobileClientError {
                print("\(err.message)")
            }
            else if (attr != nil) {
                DispatchQueue.main.async {
                    self.navigationItem.title = attr!["name"]! + " " + attr!["family_name"]!
                }
            }
        }
        //personalInfoView.layer.mask = mask
        remindersPreviewView.bringSubviewToFront(viewRemindersButton)
        remindersPreviewLabel.text = "You currently have \(remindersList.count) reminder(s)."
        
        
    }

    @IBAction func logOut(_ sender: Any) {
        
        AWSMobileClient.default().signOut()
    
    }
    
}


