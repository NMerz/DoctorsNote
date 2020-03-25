//
//  Reminder.swift
//  DoctorsNote
//
//  Created by Merz on 3/4/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import Foundation

class Reminder: CustomStringConvertible{
    private let reminderID: Int
    private var content: String
    private let creatorID: String
    private let remindeeID: String
    private var timeCreated: Date
    private var intradayFrequency: Int
    private var daysBetweenReminders: Int
    
    public var description: String {
        return "Reminder: reminderID: \(reminderID), content: \(content), creatorID: \(creatorID), remindeeID: \(remindeeID), timeCreated: \(timeCreated), intradayFrequency: \(intradayFrequency), daysBetweenReminders: \(daysBetweenReminders)"
    }
    
    init(reminderID: Int, content: String, creatorID: String, remindeeID: String, timeCreated: Date, intradayFrequency: Int, daysBetweenReminders: Int) {
        self.reminderID = reminderID
        self.content = content
        self.creatorID = creatorID
        self.remindeeID = remindeeID
        self.timeCreated = timeCreated
        self.intradayFrequency = intradayFrequency
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

    func getIntradayFrequency() -> Int {
        return intradayFrequency
    }
    
    func getDaysBetweenReminders() -> Int {
        return daysBetweenReminders
    }
    
}
