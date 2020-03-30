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
    private var content: String     // Reminder2.reminder
    private var descriptionContent: String
    private let creatorID: String
    private let remindeeID: String
    private var timeCreated: Date
    private var intradayFrequency: Int  // Reminder2.numTimesADay
    private var daysBetweenReminders: Int // Remidner2.everyNumDays
    
    public var description: String {
        return "Reminder: reminderID: \(reminderID), content: \(content), descriptionContent: \(descriptionContent), creatorID: \(creatorID), remindeeID: \(remindeeID), timeCreated: \(timeCreated), intradayFrequency: \(intradayFrequency), daysBetweenReminders: \(daysBetweenReminders)"
    }
    
    init(reminderID: Int, content: String, descriptionContent: String, creatorID: String, remindeeID: String, timeCreated: Date, intradayFrequency: Int, daysBetweenReminders: Int) {
        self.reminderID = reminderID
        self.content = content
        self.descriptionContent = descriptionContent
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
    
    func setContent(newContent: String) {
        content = newContent
    }
    
    func getDescriptionContent() -> String {
        return descriptionContent
    }
    
    func setDescriptionContent(newDescription: String) {
        descriptionContent = newDescription
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
    
    func setTimeCreated(newTime: Date) {
        timeCreated = newTime
    }

    func getIntradayFrequency() -> Int {
        return intradayFrequency
    }
    
    func setIntradayFrequency(newFrequency: Int) {
        intradayFrequency = newFrequency
    }
    
    func getDaysBetweenReminders() -> Int {
        return daysBetweenReminders
    }
    
    func setDaysBetweenReminders(newInterval: Int) {
        daysBetweenReminders = newInterval
    }
    
}
