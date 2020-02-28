//
////  Message.swift
////  DoctorsNote
//
////<<<<<<< HEAD
////  Created by Ariana Zhu on 2/23/20.
////  Copyright © 2020 Team7. All rights reserved.
////
//
//import UIKit
//
//class Message {
//    private var _message: String!
//    private var _sender: String!
//    private var _messageKey: String!
////    private var _messageRef               // ref for database
////    var currentUser                       // database stuff
//
//    var message: String {
//        return _message
//    }
//
//    var sender: String {
//        return _sender
//    }
//
//    var messageKey: String {
//        return _messageKey
//    }
//
//    init(message: String, sender: String) {
//        _message = message
//        _sender = sender
//    }
//
////    set up initializer for database
////    init(messageKey: String) {
////        _messageKey = messageKey
////    }
////=======
////  Created by Nathan Merz on 2/21/20.
////  Copyright © 2020 Nathan Merz. All rights reserved.
////
//}

import Foundation

class Message {
    private let messageID: Int
    private let conversation: Conversation
    private var content: [UInt8]
    private var sender: User

    init(messageID: Int, conversation: Conversation, content: [UInt8], sender: User) {
        self.messageID = messageID
        self.conversation = conversation
        self.content = content
        self.sender = sender
    }

    func getMessageID() -> Int {
        return messageID
    }

    func getConversation() -> Conversation {
        return conversation
    }

    func getContent() -> [UInt8] {
        return content
    }

    func getSender() -> User {
        return sender
    }
//>>>>>>> DOC-35-textbox
}
