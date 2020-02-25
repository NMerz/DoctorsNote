//
//  ConnectionProcessor.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/16/20.
//  Copyright © 2020 Nathan Merz All rights reserved.
//

import Foundation

class ConnectionProcessor {
    static private let standardURL = "https://2wahxpoqf9.execute-api.us-east-2.amazonaws.com/default/PythonAPITest"
    var connectionData: Data?
    var connectionError: ConnectionError?
    let connector: Connector
    let signalWaiter = DispatchSemaphore(value: 0)
    
    init(connector: Connector) {
        self.connector = connector
    }
    
    static func standardUrl() -> String {
        return standardURL
    }
    
    func retrieveData(urlString: String) -> ([String : Any]?, ConnectionError?) {
        retrieveJSONData(urlString: urlString)
        return processData()
    }
    
    func postData(urlString: String, data: Data) -> ([String : Any]?, ConnectionError?) {
        postJSONData(urlString: urlString, data: data)
        return processData()
    }
    
    private func processData() -> ([String : Any]?, ConnectionError?) {
        let data = connectionData
        
        if data == nil {
            if connectionError == nil {
                return (nil, ConnectionError(message: "Unknown Error"));
            }
            let returnError = ConnectionError(message: connectionError!.getMessage())
            connectionError = nil
            return (nil, returnError);
        }
        if (connectionError != nil) { //Should never be the case if data is not nil
            let returnError = ConnectionError(message: connectionError!.getMessage())
            connectionError = nil
            return (nil, returnError);
        }
        connectionError = nil
        var jsonData: [String: Any]
        print("JSON decoding:", String(bytes: data!, encoding: .utf8)!)
        do {
            jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
        }
        catch {
            return (nil, ConnectionError(message: "Malformed response body"))
            
        }
        print(type(of: jsonData))
        print(jsonData)
        return (jsonData, nil)
    }
    
    private func retrieveJSONData(urlString: String) {
        let url = URL(string: urlString)!
        print(url)
        connector.conductGetTask(manager: self, url: url)
        signalWaiter.wait()
        //TODO: This waiter should be replaced: A session/task other than the singleton can be used and then set to call a completion handler https://developer.apple.com/documentation/foundation/urlsessiondatadelegate/1410027-urlsession
    }
    
    private func postJSONData(urlString: String, data: Data) {
        let url = URL(string: urlString)!
        print(url)
        connector.conductPostTask(manager: self, url: url, data: data)
        signalWaiter.wait()
        //TODO: This waiter should be replaced: A session/task other than the singleton can be used and then set to call a completion handler https://developer.apple.com/documentation/foundation/urlsessiondatadelegate/1410027-urlsession
    }
    
    func processConnection (returnData: Data?, response: URLResponse?, potentialError: Error?) {
        
        if (potentialError != nil) {
            //print("Error (possibly) locally")
            connectionError = ConnectionError(message: "Error connecting to server")
            signalWaiter.signal()
            return
        }
        if (response == nil) {
            //print("Missing response header")
            connectionError = ConnectionError(message: "Missing response")
            signalWaiter.signal()
            return
        }
        //print("Return", String(bytes: returnData!, encoding: .utf8)!)
        let urlResponse = response as! HTTPURLResponse
        if (urlResponse.statusCode != 200) {
            //print("Error on server")
            connectionError = ConnectionError(message: "Error connecting on server with return code: " + String(urlResponse.statusCode))
            //print(response ?? "nil")
            signalWaiter.signal()
            return
        }
        //print("Status code:", urlResponse.statusCode)
        //print("Return", String(bytes: returnData!, encoding: .utf8)!)
        self.connectionData = returnData!
        signalWaiter.signal()
    }
    
    func processConversationList(url: String) -> ([Conversation]?, ConnectionError?) {
        let (potentialData, potentialError) = retrieveData(urlString: url)
        if (potentialError != nil) {
            return (nil, potentialError)
        }
        if (potentialData == nil) { //Should never happen if potentialError is nil
            return (nil, ConnectionError(message: "Data nil with no error"))
        }
        let conversationList = potentialData!
        var conversations = [Conversation]()
        if (conversationList.first?.value as? NSArray == nil) {
            return (nil, ConnectionError(message: "At least one JSON field was an incorrect format"))
        }
        for conversationDict in (conversationList.first?.value as! NSArray) {
            if (conversationDict as? [String : Any?] == nil) {
                return (nil, ConnectionError(message: "At least one JSON field was an incorrect format"))
            }
            let conversation = conversationDict as! [String : Any?]
           // let conversation = conversationList[conversationKey] as! [String : Any?]
            if ((conversation["conversationID"] as? Int) != nil) && ((conversation["conversationPartner"] as? Int) != nil) && ((conversation["lastMessageTime"] as? TimeInterval) != nil) && ((conversation["unreadMessages"] as? String) != nil) {
                let newConversation = Conversation(conversationID:  conversation["conversationID"] as! Int, conversationPartner: User(uid: conversation["conversationPartner"] as! Int), lastMessageTime: Date(timeIntervalSince1970: (conversation["lastMessageTime"] as! TimeInterval)), unreadMessages: conversation["unreadMessages"] as! String == "true")
                conversations.append(newConversation)
            } else {
                return (nil, ConnectionError(message: "At least one JSON field was an incorrect format"))
            }
        }
        return (conversations, potentialError)
    }
    
    func processUser(url: String, uid: Int) -> (User?, ConnectionError?) {
        //Placeholder
        return (User(uid: -1, firstName: "place", lastName: "holder", dateOfBirth: Date(), address: "nowhere", healthSystems: [HealthSystem]()), nil)
    }
    
    func processConversation(url: String, conversationID: Int) -> (Conversation?, ConnectionError?) {
        //Placeholder
        return (Conversation(conversationID: -1, conversationPartner: User(uid: -1)!, lastMessageTime: Date(), unreadMessages: false), nil)
    }
    
    func processMessages(url: String, conversation: Conversation, numberToRetrieve: Int, startIndex: Int = 0, sinceWhen: Date = Date(timeIntervalSinceNow: TimeInterval(0))) throws -> [Message]? {
        var messageJSON = [String : Any]()
        messageJSON["conversationID"] = conversation.getConversationID()
        messageJSON["numberToRetrieve"] = numberToRetrieve
        messageJSON["startIndex"] = startIndex
        messageJSON["sinceWhen"] = sinceWhen.timeIntervalSince1970
        var messageData = Data()
        do {
            messageData = try JSONSerialization.data(withJSONObject: messageJSON, options: [])
        } catch {
            throw ConnectionError(message: "Failed to extract data from message")
        }
        let (potentialData, potentialError) = postData(urlString: url, data: messageData)
        if potentialError != nil {
            throw potentialError!
        }
        if (potentialData == nil) { //Should never happen if potentialError is nil
            throw ConnectionError(message: "Data nil with no error")
        }
        let messageList = potentialData!
        var messages = [Message]()
        if (messageList.first?.value as? NSArray == nil) {
            throw ConnectionError(message: "At least one JSON field was an incorrect format")
        }
        
        for messageDict in (messageList.first?.value as! NSArray) {
            if (messageDict as? [String : Any?] == nil) {
                throw ConnectionError(message: "At least one JSON field was an incorrect format")
            }
            let message = messageDict as! [String : Any?]
            if ((message["messageID"] as? Int) != nil) && ((message["conversationID"] as? Int) != nil) && ((message["content"] as? String) != nil) && ((message["senderID"] as? Int) != nil) {
                let newMessage = Message(messageID: message["messageID"] as! Int, conversation: Conversation(conversationID: message["conversationID"] as! Int)!, content: [UInt8]((message["content"] as! String).utf8), sender: User(uid: message["senderID"] as! Int))
                messages.append(newMessage)
            } else {
                throw ConnectionError(message: "At least one JSON field was an incorrect format")
            }
        }
        return messages
    }
    
    //TODO: Finer processing/passing of any errors returned by server to UI
    //  - Need to discuss this with team
    func processNewMessage(url: String, message: Message) -> ConnectionError? {
        var messageJSON = [String: Any]()
        messageJSON["senderID"] = message.getSender().getUID()
        messageJSON["conversationID"] = message.getConversation().getConversationID()
        messageJSON["content"] = message.getContent()
        var messageData = Data()
        do {
            messageData = try JSONSerialization.data(withJSONObject: messageJSON, options: [])
        } catch {
            return ConnectionError(message: "Failed to extract data from message")
        }
        let (potentialData, potentialError) = postData(urlString: url, data: messageData)
        if potentialError != nil {
            return potentialError
        }
        if (potentialData == nil) { //Should never happen if potentialError is nil
            return ConnectionError(message: "Data nil with no error")
        }
        return nil //Should have returned a blank 200 if successful, if so, no need to return an error
    }
}

class Connector {
    func conductGetTask(manager: ConnectionProcessor, url: URL) {
        let retrievalTask = URLSession.shared.dataTask(with: url) {returnData, responseHeader, potentialError in
            manager.processConnection(returnData: returnData, response: responseHeader, potentialError: potentialError)
        }
        retrievalTask.resume()
    }
    
    func conductPostTask(manager: ConnectionProcessor, url: URL, data: Data) {
        let postSession = URLSession.shared.uploadTask(with: URLRequest(url: url), from: data, completionHandler: manager.processConnection(returnData:response:potentialError:))
        postSession.resume()
    }
}

class ConnectionError : Error {
    private let message: String
    init(message: String) {
        self.message = message
    }
    func getMessage() -> String {
        return message
    }
}
