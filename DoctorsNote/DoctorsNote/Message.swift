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
    private var content: Data
    private var sender: User

    init(messageID: Int, conversationID: Int, content: Data, sender: User = User(uid: "-1")) {//TODO: This is a place holder. User -1 needs to be replace with the current user's own.
        self.messageID = messageID
        self.conversationID = conversationID
        print(content.base64EncodedString().count)
        self.content = content
        self.sender = sender
    }

    func getMessageID() -> Int {
        return messageID
    }

    func getConversationID() -> Int {
        return conversationID
    }

    func getBase64Content() -> String {
        return content.base64EncodedString()
    }
    
    func getRawContent() -> Data {
        return content
    }

    func getSender() -> User {
        return sender
    }
}
