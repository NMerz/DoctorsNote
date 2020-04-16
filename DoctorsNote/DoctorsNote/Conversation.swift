//
//  Conversation.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/19/20.
//  Copyright © 2020 Nathan Merz. All rights reserved.
//
import Foundation

class Conversation {
    private let conversationID: Int
    private let converserID: String
    private let converserPublicKey: String
    private let adminPublicKey: String
    private var conversationName: String
    private var lastMessageTime: Date
    private var status: Int
    
    init(conversationID: Int, converserID: String, converserPublicKey: String, adminPublicKey: String, conversationName: String, lastMessageTime: Date, status: Int) {
        self.conversationID = conversationID
        self.converserID = converserID
        self.converserPublicKey = converserPublicKey
        self.adminPublicKey = adminPublicKey
        self.conversationName = conversationName
        self.lastMessageTime = lastMessageTime
        self.status = status
    }
    
    convenience init? (conversationID: Int) {
        let connector = Connector()
        let connectionProcessor = ConnectionProcessor(connector: connector)
        let (potentialConversation, potentialError) = connectionProcessor.processConversation(url: ConnectionProcessor.standardUrl(), conversationID: conversationID)
        if (potentialError == nil && potentialConversation != nil) {
            let conversation = potentialConversation!
            self.init (conversationID: conversationID, converserID: conversation.getConverserID(), converserPublicKey: conversation.getConverserPublicKey(), adminPublicKey: conversation.getAdminPublicKey(), conversationName: conversation.getConversationName(), lastMessageTime: conversation.getLastMessageTime(), status: conversation.getStatus())
        }
        //Below this is a temporary mock for functionality
        let conversation = potentialConversation!
        self.init (conversationID: conversationID, converserID: conversation.getConverserID(), converserPublicKey: conversation.getConverserPublicKey(), adminPublicKey: conversation.getAdminPublicKey(), conversationName: conversation.getConversationName(), lastMessageTime: conversation.getLastMessageTime(), status: conversation.getStatus())
        //return nil
    }
    
    func getConversationID() -> Int {
        return conversationID
    }
    
    func getConverserID() -> String {
        return converserID
    }
    
    func getConverserPublicKey() -> String {
        return converserPublicKey
    }
    
    func getAdminPublicKey() -> String {
        return adminPublicKey
    }
    
    func getConversationName() -> String {
        return conversationName
    }
    
    func getLastMessageTime() -> Date {
        return lastMessageTime
    }
    
    func getStatus() -> Int {
        return status
    }
}
