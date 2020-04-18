//
//  ConnectionProcessor.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/16/20.
//  Copyright © 2020 Nathan Merz All rights reserved.
//

import Foundation
import AWSMobileClient

class ConnectionProcessor {
    static private let standardURL = "https://2wahxpoqf9.execute-api.us-east-2.amazonaws.com/default/PythonAPITest"
    var connectionData: Data?
    var connectionError: ConnectionError?
    let connector: Connector
    let signalWaiter = DispatchSemaphore(value: 0)
    
    init(connector: Connector) {
        self.connector = connector
        
    }
    
//    func reportMissingAuthToken() {
//        connectionError = ConnectionError(message: "Missing authentication token")
//        signalWaiter.signal()
//        return
//    }

    static func standardUrl() -> String {
        return standardURL
    }
    
    func retrieveData(urlString: String) -> ([String : Any]?, ConnectionError?) {
        retrieveJSONData(urlString: urlString)
        return processData()
    }
    
    private func postData(urlString: String, dataJSON: [String : Any]) throws -> ([String : Any]) {
        var postData = Data()
        do {
            postData = try JSONSerialization.data(withJSONObject: dataJSON, options: [])
        } catch {
            throw ConnectionError(message: "Failed to extract data from dictionary")
        }
        postJSONData(urlString: urlString, data: postData)
        let (potentialData, potentialError) = processData()
        if potentialError != nil {
            throw potentialError!
        }
        if (potentialData == nil) { //Should never happen if potentialError is nil
            throw ConnectionError(message: "Data nil with no error")
        }
        return potentialData!
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
        var jsonData: [String: Any]?
        //print("JSON decoding:", String(bytes: data!, encoding: .utf8)!)
        do {
            jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            if jsonData == nil { //I cannot remember any case where this would happen instead of throwing
                throw ConnectionError(message: "Malformed response body")
            }
        }
        catch {
            return (nil, ConnectionError(message: "Malformed response body"))
            
        }
        //print(type(of: jsonData!))
        //print(jsonData!)
        return (jsonData!, nil)
    }
    
    private func retrieveJSONData(urlString: String) {
        let url = URL(string: urlString)!
        print(url)
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        connector.conductGetTask(manager: self, request: &request)
        signalWaiter.wait()
        //TODO: This waiter should be replaced: A session/task other than the singleton can be used and then set to call a completion handler https://developer.apple.com/documentation/foundation/urlsessiondatadelegate/1410027-urlsession
    }
    
    private func postJSONData(urlString: String, data: Data) {
        let url = URL(string: urlString)!
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //request.setValue(authToken!.tokenString, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        connector.conductPostTask(manager: self, request: &request, data: data)
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
            print(response ?? "nil")
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
            print(conversationDict)
            let conversation = conversationDict as! [String : Any?]
            print(conversation)
           // let conversation = conversationList[conversationKey] as! [String : Any?]
//            print(conversation["conversationID"] as? Int)
//            print(conversation["converserID"] as? String)
//            print(conversation["conversationName"] as? String)
//            print(conversation["lastMessageTime"] as? TimeInterval)
//            print(conversation["status"] as? Int)
            if ((conversation["conversationID"] as? Int) != nil) && ((conversation["converserID"] as? String) != nil) && ((conversation["conversationName"] as? String) != nil) && ((conversation["lastMessageTime"] as? TimeInterval) != nil) && ((conversation["status"] as? Int) != nil && ((conversation["numMembers"]) as? Int) != nil && ((conversation["description"]) as? String) != nil) {
                // TODO: numMembers and description fields need to be set once database connection is finished
                let newConversation = Conversation(conversationID:  conversation["conversationID"] as! Int, converserID:  conversation["converserID"] as! String, conversationName: conversation["conversationName"] as! String, lastMessageTime: Date(timeIntervalSince1970: (conversation["lastMessageTime"] as! TimeInterval) / 1000.0), status: conversation["status"] as! Int, numMembers: conversation["numMembers"] as! Int, description: conversation["description"] as! String)
                conversations.append(newConversation)
            } else {
                return (nil, ConnectionError(message: "At least one JSON field was an incorrect format"))
            }
        }
        return (conversations, potentialError)
    }
    
    func processUser(url: String, uid: String) -> (User?, ConnectionError?) {
        //Placeholder
        return (User(uid: "-1", email: "email", firstName: "temp", middleName: "place", lastName: "holder", dateOfBirth: Date(), address: "nowhere",  sex: "Male", phoneNumber: "9119119111", role: "Patient", healthSystems: [HealthSystem](), workHours: ""), nil)
    }
    
    func processConversation(url: String, conversationID: Int) -> (Conversation?, ConnectionError?) {
        //Placeholder
        return (Conversation(conversationID: -1, converserID: "-1", conversationName: "placeholder retrieval", lastMessageTime: Date(), status: -999, numMembers: -1, description: ""), nil)
    }
    
    func processMessages(url: String, conversationID: Int, numberToRetrieve: Int, startIndex: Int = 0, sinceWhen: Date = Date(timeIntervalSinceNow: TimeInterval(0))) throws -> [Message] {
        var messageJSON = [String : Any]()
        messageJSON["conversationID"] = conversationID
        messageJSON["numberToRetrieve"] = numberToRetrieve
        messageJSON["startIndex"] = startIndex
        messageJSON["sinceWhen"] = sinceWhen.timeIntervalSince1970
        
        let messageList = try postData(urlString: url, dataJSON: messageJSON)
        var messages = [Message]()
        if (messageList.first?.value as? NSArray == nil) {
            print("MessageList not an array")
            print(messageList.first?.value)
            throw ConnectionError(message: "At least one JSON field was an incorrect format")
        }
        
        for messageDict in (messageList.first?.value as! NSArray) {
            if (messageDict as? [String : Any?] == nil) {
                print("Message is wrong")
                throw ConnectionError(message: "At least one JSON field was an incorrect format")
            }
            let message = messageDict as! [String : Any?]
            print((message["messageId"]! as? Int) != nil)
            print((message["content"] as? String) != nil)
            print(Data(base64Encoded: (message["content"] as! String)) != nil)
            print((message["contentType"] as? Int) != nil)
            print((message["sender"] as? String) != nil)
            if ((message["messageId"] as? Int) != nil) && ((message["content"] as? String) != nil) && Data(base64Encoded: (message["content"] as! String)) != nil && ((message["contentType"] as? Int) != nil) && ((message["sender"] as? String) != nil) {
                let numFails = CognitoHelper.numFails
                let newMessage = Message(messageID: message["messageId"] as! Int, conversationID: conversationID, content: Data(base64Encoded: (message["content"] as! String))!, contentType: message["contentType"] as! Int, sender: User(uid: message["sender"] as! String), numFails: numFails)
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
        messageJSON["conversationID"] = message.getConversationID()
        messageJSON["content"] = message.getBase64Content()
        messageJSON["contentType"] = message.getContentType()
        messageJSON["numFails"] = message.getNumFails()
        do {
            let data = try postData(urlString: url, dataJSON: messageJSON)
            if data.count != 0 {
                return ConnectionError(message: "Non-blank return")
            }
        } catch let error {
            return error as? ConnectionError
        }
        return nil //Should have returned a blank 200 if successful, if so, no need to return an error
    }
    
    func processReminders(url: String, numberToRetrieve: Int, startIndex: Int = 0, sinceWhen: Date = Date(timeIntervalSinceNow: TimeInterval(0))) throws -> [Reminder] {
        var reminderJSON = [String : Any]()
        reminderJSON["numberToRetrieve"] = numberToRetrieve
        reminderJSON["startIndex"] = startIndex
        reminderJSON["sinceWhen"] = sinceWhen.timeIntervalSince1970
        
        let reminderList = try postData(urlString: url, dataJSON: reminderJSON)
        var reminders = [Reminder]()
        if (reminderList.first?.value as? NSArray == nil) {
            throw ConnectionError(message: "At least one JSON field was an incorrect format")
        }
        
        for reminderDict in (reminderList.first?.value as! NSArray) {
            if (reminderDict as? [String : Any?] == nil) {
                throw ConnectionError(message: "At least one JSON field was an incorrect format")
            }
            let reminder = reminderDict as! [String : Any?]
            print((reminder["reminderID"] as? Int) != nil)
            print((reminder["remindee"] as? String) != nil)
            print((reminder["creatorID"] as? String) != nil)
            print((reminder["timeCreated"] as? Int) != nil)
            print((reminder["timeCreated"] as! Double) / 1000.0)
            print((reminder["intradayFrequency"] as? Int) != nil)
            print((reminder["daysBetweenReminders"] as? Int) != nil)
            print((reminder["content"] as? String) != nil)
            print((reminder["descriptionContent"] as? String) != nil)
            if ((reminder["reminderID"] as? Int) != nil) && ((reminder["remindee"] as? String) != nil) && ((reminder["creatorID"] as? String) != nil) && ((reminder["timeCreated"] as? Int) != nil) && ((reminder["intradayFrequency"] as? Int) != nil) && ((reminder["daysBetweenReminders"] as? Int) != nil) && ((reminder["content"] as? String) != nil) && ((reminder["descriptionContent"] as? String) != nil) {
                let newReminder = Reminder(reminderID: reminder["reminderID"] as! Int, content: reminder["content"] as! String, descriptionContent: reminder["descriptionContent"] as! String, creatorID: reminder["creatorID"] as! String, remindeeID: reminder["remindee"] as! String, timeCreated: Date(timeIntervalSince1970: ((reminder["timeCreated"] as! Double) / 1000.0)), intradayFrequency: reminder["intradayFrequency"] as! Int, daysBetweenReminders: reminder["daysBetweenReminders"] as! Int)
                reminders.append(newReminder)
            } else {
                throw ConnectionError(message: "At least one JSON field was an incorrect format")
            }
        }
        return reminders
    }
    
    //TODO: Finer processing/passing of any errors returned by server to UI
    //  - Need to discuss this with team
    func processNewReminder(url: String, reminder: Reminder) throws {
        var reminderJSON = [String: Any]()
        reminderJSON["content"] = reminder.getContent()
        reminderJSON["descriptionContent"] = reminder.getDescriptionContent()
        reminderJSON["remindee"] = reminder.getRemindeeID()
        var timeCreated = reminder.getTimeCreated().timeIntervalSince1970 * 1000 //put the millis before the decimal point
        timeCreated.round() // make an int
        reminderJSON["timeCreated"] = timeCreated
        reminderJSON["intradayFrequency"] = reminder.getIntradayFrequency()
        reminderJSON["daysBetweenReminders"] = reminder.getDaysBetweenReminders()
        let data = try postData(urlString: url, dataJSON: reminderJSON)
        if data.count != 0 {
            throw ConnectionError(message: "Non-blank return")
        }
        //Should have returned a blank 200 if successful, if so, no need to do anything
    }
    
    //TODO: Finer processing/passing of any errors returned by server to UI
    //  - Need to discuss this with team
    func processDeleteReminder(url: String, reminder: Reminder) throws {
        var reminderJSON = [String: Any]()
        reminderJSON["reminderID"] = reminder.getReminderID()

        let data = try postData(urlString: url, dataJSON: reminderJSON)
        if data.count != 0 {
            throw ConnectionError(message: "Non-blank return")
        }
        //Should have returned a blank 200 if successful, if so, no need to do anything
    }
    
    //TODO: Finer processing/passing of any errors returned by server to UI
    //  - Need to discuss this with team
    func processEditReminder(deleteUrl: String, addURl: String, reminder: Reminder) throws {
        try processDeleteReminder(url: deleteUrl, reminder: reminder);
        try processNewReminder(url: addURl, reminder: reminder);
    }
    
    func processNewAppointment(url: String, appointment: Appointment) throws {
        var appointmentJSON = [String: Any]()
        appointmentJSON["timeScheduled"] = appointment.getTimeScheduled().timeIntervalSince1970 * 1000
        appointmentJSON["content"] = appointment.getContent()
        appointmentJSON["withID"] = appointment.getWithID()
        let data = try postData(urlString: url, dataJSON: appointmentJSON)
        if data.count != 0 {
            throw ConnectionError(message: "Non-blank return") //Should have returned a blank 200 if successful
        }
    }
    
    func processAcceptAppointment(url: String, appointment: Appointment) throws {
        var appointmentJSON = [String: Any]()
        appointmentJSON["appointmentID"] = appointment.getAppointmentID()

        let data = try postData(urlString: url, dataJSON: appointmentJSON)
        if data.count != 0 {
            throw ConnectionError(message: "Non-blank return")
        }
        //Should have returned a blank 200 if successful, if so, no need to do anything
    }
    
    func processDeleteAppointment(url: String, appointment: Appointment) throws {
        var appointmentJSON = [String: Any]()
        appointmentJSON["appointmentID"] = appointment.getAppointmentID()

        let data = try postData(urlString: url, dataJSON: appointmentJSON)
        if data.count != 0 {
            throw ConnectionError(message: "Non-blank return")
        }
        //Should have returned a blank 200 if successful, if so, no need to do anything
    }
    
    func processAppointments(url: String) throws -> [Appointment] {
        let appointmentJSON = [String: Any]()
        let appointmentList = try postData(urlString: url, dataJSON: appointmentJSON)
        var appointments = [Appointment]()
        if (appointmentList.first?.value as? NSArray == nil) {
            throw ConnectionError(message: "At least one JSON field was an incorrect format")
        }
        
        for appointmentDict in (appointmentList.first?.value as! NSArray) {
            if (appointmentDict as? [String : Any?] == nil) {
                throw ConnectionError(message: "At least one JSON field was an incorrect format")
            }
            let appointment = appointmentDict as! [String : Any?]
            if ((appointment["appointmentID"] as? Int) != nil) && ((appointment["timeScheduled"] as? Int) != nil) && ((appointment["content"] as? String) != nil) && ((appointment["withID"] as? String) != nil) && ((appointment["status"] as? Int) != nil) {
                let newAppointment = Appointment(appointmentID: appointment["appointmentID"] as! Int, content: appointment["content"] as! String, timeScheduled: Date(timeIntervalSince1970: TimeInterval((appointment["timeScheduled"] as! Double)) / 1000.0), withID: appointment["withID"] as! String, status: appointment["status"] as! Int)
                appointments.append(newAppointment)
            } else {
                throw ConnectionError(message: "At least one JSON field was an incorrect format")
            }
        }
        return appointments
    }
    
    func processJoinSupportGroup(url: String, conversationID: Int) throws -> ConnectionError? {
        var joinJSON = [String: Any]()
        joinJSON["userID"] = AWSMobileClient.default().username!
        joinJSON["conversationID"] = conversationID
        
        do {
            let data = try postData(urlString: url, dataJSON: joinJSON)
            if data.count != 0 {
                return ConnectionError(message: "Non-blank return")
            }
        } catch let error {
            return error as? ConnectionError
        }
        return nil
    }
    
    func processUserInformation(url: String, uid: String) throws -> User? {
        var userJSON = [String: Any]()
        userJSON["uid"] = uid
        let userData = try postData(urlString: url, dataJSON: userJSON)
        if (userData.first?.value as? NSArray == nil) {
            throw ConnectionError(message: "At least one JSON field was an incorrect format")
        }
        
        for userDict in (userData.first?.value as! NSArray) {
            if (userDict as? [String : Any?] == nil) {
                throw ConnectionError(message: "At least one JSON field was an incorrect format")
            }
            let user = userDict as! [String : Any?]
            if (((user["email"]) as? String) != nil && ((user["firstName"]) as? String) != nil && ((user["middleName"]) as? String) != nil && ((user["lastName"]) as? String) != nil && ((user["address"]) as? String) != nil && ((user["phoneNumber"]) as? String) != nil) {
                // WARNING: Not all fields are filled in since some information private/not necessary
                let user = User(uid: uid, email: user["email"] as! String, firstName: user["firstName"] as! String, middleName: user["middleName"] as! String, lastName: user["lastName"] as! String, dateOfBirth: Date(), address: user["adress"] as! String, sex: "", phoneNumber: user["phoneNumber"] as! String, role: "", healthSystems: [HealthSystem(hospital: "", hospitalWebsite: "", healthcareProvider: "", healthcareWebsite: "")], workHours: "")
                return user
            } else {
                throw ConnectionError(message: "At least one JSON field was an incorrect format")
            }
        }
        return nil
    }
}

class Connector {
    var authToken: SessionToken? = nil
    let tokenGuard: TokenGuard
    let session: URLSession
    
    init (tokenGuard: TokenGuard = TokenGuard(), session: URLSession = URLSession.shared) {
        self.tokenGuard = tokenGuard
        self.session = session
    }

    func setToken(potentialTokens: Tokens?, potentialError: Error?) {
        if (potentialError != nil || potentialTokens == nil || potentialTokens!.accessToken == nil) {
            return
        }
        authToken = potentialTokens!.idToken!
        print(authToken!.tokenString)
        tokenGuard.release()
    }
    
    
    func conductGetTask(manager: ConnectionProcessor, request: inout URLRequest) {
        tokenGuard.pass()
//        if (authToken == nil) {
//            manager.reportMissingAuthToken()
//            return
//        }
        request.setValue(authToken!.tokenString, forHTTPHeaderField: "Authorization")
        let retrievalTask = session.dataTask(with: request, completionHandler: manager.processConnection(returnData:response:potentialError:))
        retrievalTask.resume()
    }
    
    func conductPostTask(manager: ConnectionProcessor, request: inout URLRequest, data: Data) {
        tokenGuard.pass()
//        if (authToken == nil) {
//            manager.reportMissingAuthToken()
//            return
//        }
        request.setValue(authToken!.tokenString, forHTTPHeaderField: "Authorization")
        let postSession = session.uploadTask(with: request, from: data, completionHandler: manager.processConnection(returnData:response:potentialError:))
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

class TokenGuard {
    let signalWaiter = DispatchSemaphore(value: 0)

    func release() {
        signalWaiter.signal()
    }
    
    func pass() {
        signalWaiter.wait()
        signalWaiter.signal()
    }
}
