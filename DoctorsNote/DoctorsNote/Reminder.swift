//
//  Reminder.swift
//  DoctorsNote
//
//  Created by Merz on 3/4/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import Foundation

class Reminder {
    private let reminderID: Int
    private var content: String
    private let creatorID: String
    private let remindeeID: String
    private var timeCreated: Date
    private var intradayFequency: Int
    private var daysBetweenReminders: Int
    
    init(reminderID: Int, content: String, creatorID: String, remindeeID: String, timeCreated: Date, intradayFequency: Int, daysBetweenReminders: Int) {
        self.reminderID = reminderID
        self.content = content
        self.creatorID = creatorID
        self.remindeeID = remindeeID
        self.timeCreated = timeCreated
        self.intradayFequency = intradayFequency
        self.daysBetweenReminders = daysBetweenReminders
    }

    func getReminderID() -> Int {
        return reminderID
    }
    
    func getContent() -> String {
        return content
    }

    func getCreatorID() -> String {
        return creatorID
    }

    func getRemindeeID() -> String {
        return remindeeID
    }

    func getTimeCreated() -> Date {
        return timeCreated
    }

    func getIntradayFequency() -> Int {
        return intradayFequency
    }
    
    func getDaysBetweenReminders() -> Int {
        return daysBetweenReminders
    }
}
