//
//  User.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/18/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

//import Foundation
//
//class User {
//    
//    enum Role {
//        case patient
//        case doctor
//        case admin
//    }
//    
//    enum Sex {
//        case male
//        case female
//    }
//    
//    var firstName: String?
//    var middleName: String?
//    var lastName: String?
//    var DOB: Date?
//    // 4 Elements: street, city, state, zip
//    var address: [String]?
//    var sex: Sex?
//    var role: Role?
//    
//    // Middle name does not need to be supplied
//    init(firstName: String, middleName: String = "", lastName: String, DOB: Date, address: [String], sex: Sex, role: Role) {
//        self.firstName = firstName
//        self.middleName = middleName
//        self.lastName = lastName
//        self.DOB = DOB
//        self.address = address
//        self.sex = sex
//        self.role = role
//        
//    }
//    
//}

//class Conversation {
//    // Doctor's Name
//    // Conversation id
//    // boolean Conversation status
//    // Last message time
//    var name: String?
//    var conversationID: String?
//    var status: Bool?
//    var lastMessageTime: Date?
//}

//class Message {
//    
//    enum MessageStatus {
//        case read
//        case delivered
//        case sent
//    }
//    
//    // User is sender
//    // Time sent
//    // Message read enum
//    // MessageID
//    var sender: User?
//    var timeSent: Date?
//    var status: MessageStatus?
//    var messageID: String?
//    
//}
