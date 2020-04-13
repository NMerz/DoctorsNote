//
//  Message.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/23/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class Message {
    private var _message: String!
    private var _sender: String!
    private var _messageKey: String!
//    private var _messageRef               // ref for database
//    var currentUser                       // database stuff
    
    var message: String {
        return _message
    }
    
    var sender: String {
        return _sender
    }
    
    var messageKey: String {
        return _messageKey
    }
    
    init(message: String, sender: String) {
        _message = message
        _sender = sender
    }
    
//    set up initializer for database
//    init(messageKey: String) {
//        _messageKey = messageKey
//    }
}
