//
//  NotificationPublisher.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 3/22/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class NotificationPublisher: NSObject {
    private var thisIdentifier: String?
    
    func sendReminderNotification(title: String, body: String, badge: Int?, numTimesDaily: Int, everyNumDays: Int) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        // TODO modify for backend
//        content.categoryIdentifier = "Reminder"
//        content.userInfo = ["userId": "thisID"]
        
        var delayTimeTrigger: UNTimeIntervalNotificationTrigger?
        // 86400 seconds in a day
        // TODO: fix repeating time interval logic lol, maybe change everyNumDays variable
        let delayInterval = (86400 * Double(everyNumDays)) / Double(numTimesDaily)
        delayTimeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(delayInterval >= 60 ? delayInterval: 60), repeats: true)
        
        if let badge = badge {
            var currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
            currentBadgeCount += badge
            content.badge = NSNumber(integerLiteral: currentBadgeCount)
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        // Create request
        let uuidString = UUID().uuidString // identifier
        self.thisIdentifier = uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: delayTimeTrigger)
        
        // Register request with notification center
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func removeReminderNotification() {
        // error check if self.thisIdentifier is nil
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.thisIdentifier!])
        print("removed notification")
    }
}

extension NotificationPublisher: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("the notification is about to be presented")
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let identifier = response.actionIdentifier
        
        switch identifier {
        case UNNotificationDismissActionIdentifier:
            print("the notification was dismissed")
            completionHandler()
        case UNNotificationDefaultActionIdentifier:
            print("the user opened the app from the notification")
            completionHandler()
        default:
            print("the default case was called")
            completionHandler()
        }
    }
}
