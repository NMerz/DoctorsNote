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
    
    func sendNotification(title: String, body: String, badge: Int?, delayInterval: Int?) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        var delayTimeTrigger: UNTimeIntervalNotificationTrigger?
        
        if let delayInterval = delayInterval {
            delayTimeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(delayInterval), repeats: false)
            
        }
        
        if let badge = badge {
            var currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
            currentBadgeCount += badge
            content.badge = NSNumber(integerLiteral: currentBadgeCount)
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        // Create request
        //let uuidString = UUID().uuidString // identifier
        let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: delayTimeTrigger)
        
        // Register request with notification center
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
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
