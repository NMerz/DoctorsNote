//
//  ConnectionManager.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/16/20.
//  Copyright © 2020 Nathan Merz All rights reserved.
//

import Foundation

class ConnectionProcessor {
    var connectionData = Data()
    var connector = Connector()
    var connectionType = String()
    let signalWaiter = DispatchSemaphore(value: 0)
    
    init(connector: Connector, connectionType: String = "default") {
        self.connector = connector
        self.connectionType = connectionType
    }
    
    func retrieveData(urlString: String) -> [String : Any] {
        let data = retrieveJSONData(urlString: urlString)
        switch connectionType {
        case "conversationList":
            return processConversationList(conversationListData: data)
        default:
            //assert(false)
            return [String : Any]()
        }
    }
    
    private func retrieveJSONData(urlString: String) -> Data {
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
            //Handle error
            signalWaiter.signal()
            return
        }
        print("Return", String(bytes: returnData!, encoding: .utf8)!)
        let urlResponse = responseHeader as! HTTPURLResponse
        if (urlResponse.statusCode != 200) {
            print("Error on server")
            print(responseHeader ?? "nil")
            //Handle server error
            signalWaiter.signal()
            return
        }
        print("Status code:", urlResponse.statusCode)
        //        print("Return: ", terminator: "")
        //        for char in returnData! {
        //            print(Character(UnicodeScalar(char)), terminator: "")
        //        }
        //        print()
        print("Return", String(bytes: returnData!, encoding: .utf8)!)
        self.connectionData = returnData!
        signalWaiter.signal()
    }
    
    private func processConversationList(conversationListData: Data) -> [String : Any] {
        let data = try! JSONSerialization.jsonObject(with: conversationListData, options: .allowFragments) as! [String: Any]
        print(type(of: data))
        print(data)
        
        return data
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
