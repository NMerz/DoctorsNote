//
////  Message.swift
////  DoctorsNote
//
//  Created by Nathan Merz on 2/21/20.
//  Copyright © 2020 Nathan Merz. All rights reserved.

import Foundation

class Message {
    private let messageID: Int
    private let conversationID: Int
    private var content: [UInt8]
    private var sender: User

    init(messageID: Int, conversationID: Int, content: [UInt8], sender: User = User(uid: -1)) {//TODO: This is a place holder. User 1 needs to be replace with the current user's own.
        self.messageID = messageID
        self.conversationID = conversationID
        self.content = content
        self.sender = sender
    }

    func getMessageID() -> Int {
        return messageID
    }

    func getConversationID() -> Int {
        return conversationID
    }

    func getContent() -> [UInt8] {
        return content
    }

    func getSender() -> User {
        return sender
    }
}
