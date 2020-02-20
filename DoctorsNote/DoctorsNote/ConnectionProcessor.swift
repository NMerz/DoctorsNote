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
        let data = retrieveJSONData(urlString: urlString)
        if data == nil {
            if connectionError == nil {
                return (nil, ConnectionError(message: "Unknown Error"));
            }
            return (nil, connectionError);
        }
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
    
    private func retrieveJSONData(urlString: String) -> Data? {
        let url = URL(string: urlString)!
        print(url)
        connector.conductRetrievalTask(manager: self, url: url)
        signalWaiter.wait()
        //TODO: This waiter should be replaced: A session/task other than the singleton can be used and then set to call a completion handler https://developer.apple.com/documentation/foundation/urlsessiondatadelegate/1410027-urlsession
        return connectionData
    }
    
    func processConnection (returnData: Data?, responseHeader: URLResponse?, potentialError: Error?) {
        
        if (potentialError != nil) {
            print("Error locally")
            connectionError = ConnectionError(message: "Error connecting to server")
            signalWaiter.signal()
            return
        }
        if (responseHeader == nil) {
            print("Missing response header")
            signalWaiter.signal()
            return
        }
        print("Return", String(bytes: returnData!, encoding: .utf8)!)
        let urlResponse = responseHeader as! HTTPURLResponse
        if (urlResponse.statusCode != 200) {
            print("Error on server")
            connectionError = ConnectionError(message: "Error connecting on server with return code: " + String(urlResponse.statusCode))
            print(responseHeader ?? "nil")
            signalWaiter.signal()
            return
        }
        print("Status code:", urlResponse.statusCode)
        print("Return", String(bytes: returnData!, encoding: .utf8)!)
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
        for conversationKey in conversationList.keys {
            let conversation = conversationList[conversationKey] as! [String : Any?]
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
}

class Connector {
    func conductRetrievalTask(manager: ConnectionProcessor, url: URL) {
        let retrievalTask = URLSession.shared.dataTask(with: url) {returnData, responseHeader, potentialError in
            manager.processConnection(returnData: returnData, responseHeader: responseHeader, potentialError: potentialError)
        }
        retrievalTask.resume()
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