//
//  Message.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/21/20.
//  Copyright © 2020 Nathan Merz. All rights reserved.
//

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
    
    func getConversation() -> Conversation {
        return conversation
    }
    
    func getContent() -> [UInt8] {
        return content
    }
    
    func getSender() -> User {
        return sender
    }
}
