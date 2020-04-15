//
//  ProfileViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import PopupKit
import AWSCognito
import AWSMobileClient
import UserNotifications

class ProfileViewController: UIViewController {
   
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var personalInfoView: PersonalInfoView!
    @IBOutlet weak var settingsButton: UIButton!
    var mask: CAShapeLayer?
    
    var p: PopupView?
    @IBOutlet weak var remindersPreviewView: UIView!
    @IBOutlet weak var remindersPreviewLabel: UILabel!
    @IBOutlet weak var viewRemindersButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        remindersPreviewLabel.text = "You currently have \(remindersList!.count) reminder(s)."
        UIApplication.shared.applicationIconBadgeNumber = 0

    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        defaults.dictionaryRepresentation().keys.forEach(defaults.removeObject(forKey:))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var connector2 = Connector()
        AWSMobileClient.default().getTokens(connector2.setToken(potentialTokens:potentialError:))
        var processor2 = ConnectionProcessor(connector: connector2)
        do {
            let cipher = LocalCipher()
            let (keyP, keyS, keyPub) = cipher.generateKetSet(password: "coolPass!1", securityQuestionAnswers: ["answer1", "answer2"], username: "abcd")
            try processor2.postKeys(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/addkeys", privateKeyP: keyP.base64EncodedString(), privateKeyS: keyS.base64EncodedString(), publicKey: keyPub.base64EncodedString())
            //try processor2.processDeleteAppointment(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/appointmentdelete", appointment: Appointment(appointmentID: 25, content: "blah", timeScheduled: Date(), withID: "blah"))
            do {
                print(try processor2.retrieveEncryptedPrivateKeys(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/retrievekeys"))
            } catch let error as ConnectionError {
                print(error.getMessage())
                if error.getMessage() == "Null response" {
                    //TODO: post keys
                    print("TODO: I need to post the keys")
                }
            }
        } catch let error {
            print((error as! ConnectionError).getMessage())
        }
        
        // Remove permanent data, should I do this here?
//        resetDefaults()
        
        // Permanent data test
//        UserDefaults.standard.set("ariana was here", forKey: "id")
//        UserDefaults.standard.removeObject(forKey: "id")
//        if let string = UserDefaults.standard.object(forKey: "id") {
//            print(string)
//        }
//        else {
//            print("deleted!")
//        }
        // End permanent data test
        
//        var connector = Connector()
//        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
//        var processor = ConnectionProcessor(connector: connector)
//        do {
//            try processor.processNewReminder(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/reminderadd", reminder: Reminder(reminderID: -1, content: "Contents", creatorID: "ignored", remindeeID: "37d6a758-e79f-442f-af49-6bff78c8ad10", timeCreated: Date(timeIntervalSince1970: 1234), intradayFrequency: 2, daysBetweenReminders: 1))
//        } catch let error {
//            print((error as! ConnectionError).getMessage())
//        }
//        do {
//            let reminders = try processor.processReminders(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/reminderlist", numberToRetrieve: 3)
//            print(reminders[0])
//            //print(reminders[1])
//            //print(reminders[2])
//        } catch let error {
//            print((error as! ConnectionError).getMessage())
//        }
        
        
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
        
        let widthConstraint = NSLayoutConstraint(item: personalInfoView!, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: -40)
        let horizontalConstraint = NSLayoutConstraint(item: personalInfoView!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([widthConstraint, horizontalConstraint])
        
        mask = CAShapeLayer()
        mask!.path = UIBezierPath(roundedRect: personalInfoView.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        
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

        
        //personalInfoView.layer.mask = mask
        remindersPreviewView.bringSubviewToFront(viewRemindersButton)
        remindersPreviewLabel.text = "You currently have \(remindersList!.count) reminder(s)."
        
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mask?.frame = personalInfoView.bounds
        // Todo: Implement later, as it is not a huge priority. Currently has issues with resizing due to layout constraints
        //personalInfoView.layer.mask = mask!
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        CognitoHelper.sharedHelper.logout()
    
    }
    
    @IBAction func showSettings(_ sender: Any) {
    
        let width : Int = Int(self.view.frame.width - 40)
        let height : Int = 160

        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        contentView.backgroundColor = UIColor.white
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 38.5).cgPath
        contentView.layer.mask = maskLayer

        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed
        
        let reportButton = UIButton(frame: CGRect(x: 25, y: 25, width: width - 50, height: 55))
        let reportLayer = CAShapeLayer()
        reportLayer.path = UIBezierPath(roundedRect: reportButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        reportButton.layer.mask = reportLayer
        reportButton.backgroundColor = UIColor.systemGray3
        reportButton.setTitle("Report an issue", for: .normal)
        reportButton.accessibilityIdentifier = "Report Button"
        reportButton.addTarget(self, action: #selector(sendReport), for: .touchUpInside)
    
        let closeButton = UIButton(frame: CGRect(x: width/2 - 45, y: 105, width: 90, height: 40))
        closeButton.setTitle("Done", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        closeButton.layer.mask = layer
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)

        contentView.addSubview(reportButton)
        contentView.addSubview(closeButton)

        let xPos = self.view.frame.width / 2
        let yPos = self.view.frame.height - CGFloat(height) + (tabBarController?.tabBar.frame.height)! - 20
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: (self.tabBarController?.view)!)
        
    }
    
    @objc func dismissPopup(sender: UIButton!) {
        p?.dismissType = .slideOutToBottom
        p?.dismiss(animated: true)
    }
    
    @objc func sendReport(sender: UIButton!) {
        let toEmail = "bbh@purdue.edu"
        let subject = "Doctors Note Issue Report".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        let urlString = "mailto:\(toEmail)?subject=\(subject!)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
}


