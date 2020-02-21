//
//  User.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/18/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import Foundation

class User {
    
    enum Role {
        case patient
        case doctor
        case admin
    }
    
    var firstName: String?
    var lastName: String?
    var DOB: Date?
    // 4 Elements: street, city, state, zip
    var address: [String]?
    
    
}

//class Patient: User{
//
//}
//
//class Doctor: User {
//
//}
//
//class Admin: User {
//
//}

class Conversation {
    // Doctor's Name
    // Conversation id
    // boolean Conversation status
    // Last message time
    var name: String?
    var conversationID: String?
    var status: Bool?
    var lastMessageTime: Date?
}

class Message {
    
    enum MessageStatus {
        case read
        case delivered
        case sent
    }
    
    // User is sender
    // Time sent
    // Message read enum
    // MessageID
    var sender: User?
    var timeSent: Date?
    var status: MessageStatus?
    var messageID: String?
    
}
