//
//  Conversation.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/19/20.
//  Copyright © 2020 Nathan Merz. All rights reserved.
//

import Foundation

class Conversation {
    private let conversationPartner: User
    private let conversationID: Int
    private var lastMessageTime: Date
    private var unreadMessages: Bool
    
    init(conversationID: Int, conversationPartner: User, lastMessageTime: Date, unreadMessages: Bool) {
        self.conversationID = conversationID
        self.conversationPartner = conversationPartner
        self.lastMessageTime = lastMessageTime
        self.unreadMessages = unreadMessages
    }
    
    convenience init? (conversationID: Int) {
        let connector = Connector()
        let connectionProcessor = ConnectionProcessor(connector: connector)
        let (potentialConversation, potentialError) = connectionProcessor.processConversation(url: ConnectionProcessor.standardUrl(), conversationID: conversationID)
        if (potentialError == nil && potentialConversation != nil) {
            let conversation = potentialConversation!
            self.init (conversationID: conversationID, conversationPartner: conversation.getConversationPartner(), lastMessageTime: conversation.getLastMessageTime(), unreadMessages: conversation.getUnreadMessages())
        }
        return nil
    }
    
    func getConversationID() -> Int {
        return conversationID
    }
    
    func getConversationPartner() -> User {
        return conversationPartner
    }
    
    func getLastMessageTime() -> Date {
        return lastMessageTime
    }
    
    func getUnreadMessages() -> Bool {
        return unreadMessages
    }
}
