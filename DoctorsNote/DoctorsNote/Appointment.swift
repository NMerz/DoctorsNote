//
//  Appointment.swift
//  
//
//  Created by Merz on 3/25/20.
//  Copyright © 2020 Nathan Merz All rights reserved.
//

import Foundation

class Appointment {
    private let appointmentID: Int
    private var content: String
    private var timeScheduled: Date
    private var withID: String
    private var status: Int /* pending (retrieved by requestor) = -1; pending (retrieved by requestedWith) = 0; accepted = 1*/
    
    init(appointmentID: Int, content: String, timeScheduled: Date, withID: String, status: Int = 0) {
        self.appointmentID = appointmentID
        self.content = content
        self.timeScheduled = timeScheduled
        self.withID = withID
        self.status = status
    }
    
    func getAppointmentID() -> Int {
        return appointmentID
    }
    
    func getContent() -> String {
        return content
    }
    
    func setContent(content: String) {
        self.content = content
    }
    
    func getTimeScheduled() -> Date {
        return timeScheduled
    }
    
    func setTimeScheduled(newTime: Date) {
        timeScheduled = newTime
    }
    
    func getWithID() -> String {
        return withID
    }
    
    func getStatus() -> Int {
        return status
    }
    
    func setStatus(newStatus: Int) {
        self.status = newStatus
    }
    
//    not needed
    func approveAppointment() {
        if status == 0 {
            status = 1
        }
    }
}
