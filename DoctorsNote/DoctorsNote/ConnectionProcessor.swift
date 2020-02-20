//
//  ConnectionProcessor.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/16/20.
//  Copyright © 2020 Nathan Merz All rights reserved.
//

import Foundation

class ConnectionProcessor {
    var connectionData: Data?
    var connectionError: ConnectionError?
    let connector: Connector
    let signalWaiter = DispatchSemaphore(value: 0)
    
    init(connector: Connector) {
        self.connector = connector
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
    
    func processConversationList(url: String) -> ([String : Any]?, ConnectionError?) {
        let (data, potentialError) = retrieveData(urlString: url)
        return (data, potentialError)
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
