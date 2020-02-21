//
//  Message.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/21/20.
//  Copyright © 2020 Nathan Merz. All rights reserved.
//

import Foundation

class Message {
    private let conversation: Conversation
    private var content: [Int8]
    private var sender: User
    
    init(conversation: Conversation, content: [Int8], sender: User) {
        self.conversation = conversation
        self.content = content
        self.sender = sender
    }
    
    func getConversation() -> Conversation {
        return conversation
    }
    
    func getContent() -> [Int8] {
        return content
    }
    
    func getSender() -> User {
        return sender
    }
}
