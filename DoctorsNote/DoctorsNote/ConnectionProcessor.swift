//
//  ConnectionManager.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/16/20.
//  Copyright © 2020 Nathan Merz All rights reserved.
//

import Foundation

class ConnectionProcessor {
    var connectionData = String()
    var connector = Connector();
    
    func ConnectionProcessor(connector: Connector) {
        self.connector = connector
    }
    
    func retrieveData(urlString: String) -> String {
        let url = URL(string: urlString)!
        print(url)
        let retrievalTask = Connector.makeRetrievalTask(manager: self, url: url)
        retrievalTask.resume()
        return connectionData
    }
    
    
    
    func manageConnection (returnData: Data?, responseHeader: URLResponse?, potentialError: Error?) {
        
        if (potentialError != nil) {
            print("Error locally")
            //Handle error
            return
        }
        let urlResponse = responseHeader as! HTTPURLResponse
        if (urlResponse.statusCode != 200) {
            print("Error on server")
            print(responseHeader ?? "nil")
            //Handle server error
            return
        }
        print("Status code:", urlResponse.statusCode)
//        print("Return: ", terminator: "")
//        for char in returnData! {
//            print(Character(UnicodeScalar(char)), terminator: "")
//        }
//        print()
        print("Return", String(bytes: returnData!, encoding: .utf8)!)
        self.connectionData = String(bytes: returnData!, encoding: .utf8)!
    }
}

class Connector {
    static func makeRetrievalTask(manager: ConnectionProcessor, url: URL) -> (URLSessionDataTask) {
        return URLSession.shared.dataTask(with: url) {returnData, responseHeader, potentialError in
            manager.manageConnection(returnData: returnData, responseHeader: responseHeader, potentialError: potentialError)
        }
    }
}
