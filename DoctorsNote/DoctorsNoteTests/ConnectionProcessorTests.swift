//
//  ConnectionProcessorTests.swift
//  DoctorsNoteTests
//
//  Created by Nathan Merz on 2/16/20.
//  Copyright © 2020 Nathan Merz. All rights reserved.
//

import XCTest
import AWSMobileClient

class ConnectionProcessorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    

    func testGarbageRetrievalConducted() {
        let connector = ConnectorMock()
        let processor = ConnectionProcessor(connector: connector)
        XCTAssert(connector.getConductRetrievalTaskCalls() == 0)
        let (potentialData, potentialError) = processor.retrieveData(urlString: "garbage")
        XCTAssert(connector.getConductRetrievalTaskCalls() == 1)
        XCTAssert(potentialData == nil)
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "Missing response")
    }
    
    func testEmptyReturn() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialData, potentialError) = processor.retrieveData(urlString: "url")
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "Malformed response body")
        XCTAssert(potentialData == nil)
    }
    
    func testEmptyJSONReturn() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialData, potentialError) = processor.retrieveData(urlString: "url")
        XCTAssert(potentialError == nil)
        XCTAssert(potentialData != nil)
        XCTAssert(potentialData!.count == 0)
    }
    
    func testBadStatusCode() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialData, potentialError) = processor.retrieveData(urlString: "url")
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "Error connecting on server with return code: 500")
        XCTAssert(potentialData == nil)
    }
    
    func testErrorConnecting() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: ConnectionError(message: "Test error")) //NOTE: The error would not be of this type but I do not knwo what type it would be
        let processor = ConnectionProcessor(connector: connector)
        let (potentialData, potentialError) = processor.retrieveData(urlString: "url")
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "Error connecting to server")
        XCTAssert(potentialData == nil)
    }

    func testValidData() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"key1\":\"val1\",\"key2\":\"val2\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialData, potentialError) = processor.retrieveData(urlString: "url")
        XCTAssert(potentialError == nil)
        XCTAssert(potentialData != nil)
        XCTAssert(potentialData!.count == 2)
        //XCTAssert(potentialData?.contains(key: "key1", value: "val1"))
        XCTAssert(potentialData?["key1"] as! String == "val1")
        XCTAssert(potentialData?["key2"] as! String == "val2")
    }
    
    func testConversationListInvalidArrayJSON() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"[0]\":{\"conversationID\":\"1\",\"converserID\":\"0\",\"lastMessageTime\":0,\"status\":0}}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialConversationList, potentialError) = processor.processConversationList(url: "url")
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "At least one JSON field was an incorrect format")
        XCTAssert(potentialConversationList == nil)
    }
    
    func testConversationListConversationJSONArray() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"conversationList\": [\"bad\", {\"conversationID\":\"1\",\"converserID\":\"0\",\"lastMessageTime\":0,\"status\":0}]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialConversationList, potentialError) = processor.processConversationList(url: "url")
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "At least one JSON field was an incorrect format")
        XCTAssert(potentialConversationList == nil)
    }
    
    func testConversationListConversationFieldType() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"conversationList\":[{\"conversationID\":1,\"converserID\":0,\"converserPublicKey\":\"key\",\"adminPublicKey\":\"key\",\"conversationName\":\"0id\",\"lastMessageTime\":0,\"status\":0,\"numMembers\":2,\"description\":\"descriptive\"}]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialConversationList, potentialError) = processor.processConversationList(url: "url")
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "At least one JSON field was an incorrect format")
        XCTAssert(potentialConversationList == nil)
    }
    
    func testConversationListConversationKeyFieldProcessed() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"conversationList\":[{\"conversationID\":1,\"converserID\":\"0id\",\"adminPublicKey\":\"key\",\"conversationName\":\"0id\",\"lastMessageTime\":0,\"status\":0,\"numMembers\":2,\"description\":\"descriptive\"}]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialConversationList, potentialError) = processor.processConversationList(url: "url")
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "At least one JSON field was an incorrect format")
        XCTAssert(potentialConversationList == nil)
    }
    
    func testMessageListMessageInvalidJSONArray() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"[0]\":{\"messageId\":\"1\",\"content\":\"123\",\"contentType\":0,\"sender\":\"2id\"}}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let potentialMessageList = try processor.processMessages(url: "url", conversationID: 1, numberToRetrieve: 2)
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was an incorrect format")
        }
    }
    
    func testMessageListMessageJSONArray() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"messageList\":[\"bad\", {\"messageId\":\"1\",\"content\":\"123\",\"contentType\":0,\"sender\":\"2id\"}]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let potentialMessageList = try processor.processMessages(url: "url", conversationID: 1, numberToRetrieve: 2)
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was an incorrect format")
        }
    }
    
    func testMessageListMessageFieldType() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"messageList\":[{\"messageId\":\"1\",\"content\":\"123\",\"contentType\":0,\"sender\":\"2id\"}]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let potentialMessageList = try processor.processMessages(url: "url", conversationID: 1, numberToRetrieve: 2)
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was an incorrect format")
        }
    }
    
    func testReminderListReminderInvalidJSONArray() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"[0]\":{\"reminderID\":11,\"remindee\":\"123id\",\"creatorID\":231,\"timeCreated\":123,\"alertTime\":1583692386455,\"content\":\"This is content\"}}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let _ = try processor.processReminders(url: "url", numberToRetrieve: 2)
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was an incorrect format")
        }
    }
    
    func testReminderListReminderJSONArray() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"reminderList\":[\"bad\",{\"reminderID\":11,\"remindee\":\"123id\",\"creatorID\":231,\"timeCreated\":123,\"alertTime\":1583692386455,\"content\":\"This is content\"}]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let _ = try processor.processReminders(url: "url", numberToRetrieve: 2)
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was an incorrect format")
        }
    }
    
    func testReminderListReminderFieldType() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"reminderList\":[{\"reminderID\":11,\"remindee\":\"123id\",\"creatorID\":231,\"timeCreated\":123,\"alertTime\":1583692386455,\"content\":\"This is content\"}]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let _ = try processor.processReminders(url: "url", numberToRetrieve: 2)
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was an incorrect format")
        }
    }
    
    func testConversationListLowerFailure() {
        let connector = ConnectorMock()
        let processor = ConnectionProcessor(connector: connector)
        let (potentialConversationList, potentialError) = processor.processConversationList(url: "garbage")
        XCTAssert(potentialConversationList == nil)
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "Missing response")
    }
    
    func testValidConversationList() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"conversationList\":[{\"conversationID\":1,\"converserID\":\"0id\",\"converserPublicKey\":\"key\",\"adminPublicKey\":\"key\",\"conversationName\":\"0id\",\"lastMessageTime\":0,\"status\":0,\"numMembers\":2,\"description\":\"descriptive\"}]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialConversationList, potentialError) = processor.processConversationList(url: "url")
        XCTAssert(potentialError == nil)
        XCTAssert(potentialConversationList != nil)
        let conversationList = potentialConversationList!
        XCTAssert(conversationList[0].getConverserID() == "0id")
        XCTAssert(conversationList[0].getConversationName() == "0id")
        XCTAssert(conversationList[0].getLastMessageTime() == Date(timeIntervalSince1970: 0))
        XCTAssert(conversationList[0].getStatus() == 0)
    }
    
    func testMessagePostBadStatus() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let potentialError = processor.processNewMessage(url: "url", message: Message(messageID: 1, conversationID: 1, content: "content".data(using: .utf8)!, contentType: 0, sender: User(uid: "1id")!, numFails: 0))
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "Error connecting on server with return code: 500")
    }
    
    func testMessagePostBadBody() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"unwanted\":\"body\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let potentialError = processor.processNewMessage(url: "url", message: Message(messageID: 1, conversationID: 1, content: "content".data(using: .utf8)!, contentType: 0, sender: User(uid: "1id")!, numFails: 0))
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "Non-blank return")
    }
    
    func testMessagePostEncryption() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (newPrivateKey, _ , length, _) = LocalCipher().generateKetSet(password: "password", securityQuestionAnswers: ["answer"], username: "notunique")
        let returnString = "{\"privateKeyP\":\"" + newPrivateKey.base64EncodedString() + "\", \"privateKeyS\":\" \",\"length\":" + String(Int(length)) + "}"
        let returnData = Data((returnString).utf8)
        let connector2 = ConnectorMock(returnData: returnData, responseHeader: response, potentialError: nil)
        let processor2 = ConnectionProcessor(connector: connector2)
        var cipher: MessageCipher? = nil
        do {
            cipher = try MessageCipher(uniqueID: "notunique", localAESKey: LocalCipher().getAESFromPass(password: "password", username: "notunique"), processor: processor2)
        } catch {
        }
        let potentialError = processor.processNewMessage(url: "url", message: Message(messageID: 1, conversationID: 1, content: "content".data(using: .utf8)!, contentType: 0, sender: User(uid: "id1")!, numFails: 0), cipher: cipher!, publicKeyExternalBase64: "MIIBCgKCAQEA0E5A8SyAJ5+tBYHgfmGyYHnfGmTm4JlflOZU4SShcm9Gax76lCrcwOhBSCk3HqHgv4u/EVsfuKc/DZnHyvOUXKj78q+D3Lhp1PDbHPQurOUrbAMf4m0zKuLcdTWe6ZZzf2/CeNcbEzXNoiBBCaVWe23tnpG0XjIsF8wbdcGkO/aPCScbtjDnKybmzX0XygpGTKE3gJGs7Ze+K0/7K1hM+fD5kkjPkQUcBAdjF/AefMzI64mds0fEU5Ge11o2Nhdx9rmKrPtafYfnG0hglvqGVf5z3X/Vh1Wt2soB1wOvx4nh8aoaDO1/rXgtqYdtxRmRULyOjG48/YWGgAHvuweJEQIDAQAB", adminPublicKeyExternalBase64: "MIIBCgKCAQEA0E5A8SyAJ5+tBYHgfmGyYHnfGmTm4JlflOZU4SShcm9Gax76lCrcwOhBSCk3HqHgv4u/EVsfuKc/DZnHyvOUXKj78q+D3Lhp1PDbHPQurOUrbAMf4m0zKuLcdTWe6ZZzf2/CeNcbEzXNoiBBCaVWe23tnpG0XjIsF8wbdcGkO/aPCScbtjDnKybmzX0XygpGTKE3gJGs7Ze+K0/7K1hM+fD5kkjPkQUcBAdjF/AefMzI64mds0fEU5Ge11o2Nhdx9rmKrPtafYfnG0hglvqGVf5z3X/Vh1Wt2soB1wOvx4nh8aoaDO1/rXgtqYdtxRmRULyOjG48/YWGgAHvuweJEQIDAQAB")
        XCTAssert(connector.getConductPostTaskCalls() == 1)
        XCTAssert(potentialError == nil)
        let postedData = connector.getPostedData()
        XCTAssert(postedData != nil)
        if postedData == nil {
            return
        }
        var postedDictionary: [String: Any]? = nil
        do {
            postedDictionary = try JSONSerialization.jsonObject(with: postedData!, options: .allowFragments) as? [String: Any]
        } catch {
            XCTAssert(false)
        }
        XCTAssert(postedDictionary != nil)
        if postedDictionary == nil {
            return
        }
        XCTAssert(postedDictionary!["senderContent"] as! String != "content")
        XCTAssert(postedDictionary!["receiverContent"] as! String != "content")
        XCTAssert(postedDictionary!["adminContent"] as! String != "content")
        XCTAssert(postedDictionary!["senderContent"] as! String != "content".data(using: .utf8)!.base64EncodedString())
        XCTAssert(postedDictionary!["receiverContent"] as! String != "content".data(using: .utf8)!.base64EncodedString())
        XCTAssert(postedDictionary!["adminContent"] as! String != "content".data(using: .utf8)!.base64EncodedString())

    }
    
    func testPostedMessageReceiverDecryptability() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (newPrivateKey, _ , length, publicKey) = LocalCipher().generateKetSet(password: "password", securityQuestionAnswers: ["answer"], username: "notunique")
        let returnString = "{\"privateKeyP\":\"" + newPrivateKey.base64EncodedString() + "\", \"privateKeyS\":\" \",\"length\":" + String(Int(length)) + "}"
        let returnData = Data((returnString).utf8)
        let connector2 = ConnectorMock(returnData: returnData, responseHeader: response, potentialError: nil)
        let processor2 = ConnectionProcessor(connector: connector2)
        var cipher: MessageCipher? = nil
        do {
            cipher = try MessageCipher(uniqueID: "notunique", localAESKey: LocalCipher().getAESFromPass(password: "password", username: "notunique"), processor: processor2)
        } catch {
        }
        let potentialError = processor.processNewMessage(url: "url", message: Message(messageID: 1, conversationID: 1, content: "longContent1!".data(using: .utf8)!, contentType: 0, sender: User(uid: "id1")!, numFails: 0), cipher: cipher!, publicKeyExternalBase64: publicKey.base64EncodedString(), adminPublicKeyExternalBase64: "MIIBCgKCAQEA0E5A8SyAJ5+tBYHgfmGyYHnfGmTm4JlflOZU4SShcm9Gax76lCrcwOhBSCk3HqHgv4u/EVsfuKc/DZnHyvOUXKj78q+D3Lhp1PDbHPQurOUrbAMf4m0zKuLcdTWe6ZZzf2/CeNcbEzXNoiBBCaVWe23tnpG0XjIsF8wbdcGkO/aPCScbtjDnKybmzX0XygpGTKE3gJGs7Ze+K0/7K1hM+fD5kkjPkQUcBAdjF/AefMzI64mds0fEU5Ge11o2Nhdx9rmKrPtafYfnG0hglvqGVf5z3X/Vh1Wt2soB1wOvx4nh8aoaDO1/rXgtqYdtxRmRULyOjG48/YWGgAHvuweJEQIDAQAB")
        XCTAssert(connector.getConductPostTaskCalls() == 1)
        XCTAssert(potentialError == nil)
        let postedData = connector.getPostedData()
        XCTAssert(postedData != nil)
        if postedData == nil {
            return
        }
        var postedDictionary: [String: Any]? = nil
        do {
            postedDictionary = try JSONSerialization.jsonObject(with: postedData!, options: .allowFragments) as? [String: Any]
        } catch {
            XCTAssert(false)
        }
        XCTAssert(postedDictionary != nil)
        if postedDictionary == nil {
            return
        }
        XCTAssert(String(bytes: Data(base64Encoded: try cipher!.decrypt(toDecrypt: Data(base64Encoded: postedDictionary!["receiverContent"] as! String)!))!, encoding: .utf8) == "longContent1!")
    }
    
    func testPostedMessageAdminDecryptability() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (newPrivateKey, _ , length, publicKey) = LocalCipher().generateKetSet(password: "password", securityQuestionAnswers: ["answer"], username: "notunique")
        let returnString = "{\"privateKeyP\":\"" + newPrivateKey.base64EncodedString() + "\", \"privateKeyS\":\" \",\"length\":" + String(Int(length)) + "}"
        let returnData = Data((returnString).utf8)
        let connector2 = ConnectorMock(returnData: returnData, responseHeader: response, potentialError: nil)
        let processor2 = ConnectionProcessor(connector: connector2)
        var cipher: MessageCipher? = nil
        do {
            cipher = try MessageCipher(uniqueID: "notunique", localAESKey: LocalCipher().getAESFromPass(password: "password", username: "notunique"), processor: processor2)
        } catch {
        }
        let potentialError = processor.processNewMessage(url: "url", message: Message(messageID: 1, conversationID: 1, content: "longContent2!".data(using: .utf8)!, contentType: 0, sender: User(uid: "id1")!, numFails: 0), cipher: cipher!, publicKeyExternalBase64: "MIIBCgKCAQEA0E5A8SyAJ5+tBYHgfmGyYHnfGmTm4JlflOZU4SShcm9Gax76lCrcwOhBSCk3HqHgv4u/EVsfuKc/DZnHyvOUXKj78q+D3Lhp1PDbHPQurOUrbAMf4m0zKuLcdTWe6ZZzf2/CeNcbEzXNoiBBCaVWe23tnpG0XjIsF8wbdcGkO/aPCScbtjDnKybmzX0XygpGTKE3gJGs7Ze+K0/7K1hM+fD5kkjPkQUcBAdjF/AefMzI64mds0fEU5Ge11o2Nhdx9rmKrPtafYfnG0hglvqGVf5z3X/Vh1Wt2soB1wOvx4nh8aoaDO1/rXgtqYdtxRmRULyOjG48/YWGgAHvuweJEQIDAQAB", adminPublicKeyExternalBase64: publicKey.base64EncodedString())
        XCTAssert(connector.getConductPostTaskCalls() == 1)
        XCTAssert(potentialError == nil)
        let postedData = connector.getPostedData()
        XCTAssert(postedData != nil)
        if postedData == nil {
            return
        }
        var postedDictionary: [String: Any]? = nil
        do {
            postedDictionary = try JSONSerialization.jsonObject(with: postedData!, options: .allowFragments) as? [String: Any]
        } catch {
            XCTAssert(false)
        }
        XCTAssert(postedDictionary != nil)
        if postedDictionary == nil {
            return
        }
        XCTAssert(String(bytes: Data(base64Encoded: try cipher!.decrypt(toDecrypt: Data(base64Encoded: postedDictionary!["adminContent"] as! String)!))!, encoding: .utf8) == "longContent2!")
    }
    
    func testValidMessagePost() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let potentialError = processor.processNewMessage(url: "url", message: Message(messageID: 1, conversationID: 1, content: "content".data(using: .utf8)!, contentType: 0, sender: User(uid: "id1")!, numFails: 0))
        XCTAssert(connector.getConductPostTaskCalls() == 1)
        XCTAssert(potentialError == nil)
    }
    
    func testValidMessageRetrieval() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data(("{\"messageList\":[{\"messageId\":1,\"content\":\"" + ("123".data(using: .utf8)!.base64EncodedString()) + "\",\"contentType\":0,\"sender\":\"2id\"}]}").data(using: .utf8)!), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let messageList = try processor.processMessages(url: "url", conversationID: 0, numberToRetrieve: 1)
            XCTAssert(messageList[0].getConversationID() == 0)
            XCTAssert(String(bytes:messageList[0].getRawContent(), encoding: .utf8) == "123")
            XCTAssert(messageList[0].getSender().getUID() == "2id")
        } catch {
            XCTAssert(false)
        }
    }
    
    func testValidReminderRetrieval() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"reminderList\":[{\"reminderID\":11,\"remindee\":\"123id\",\"creatorID\":\"231id\",\"timeCreated\":4123,\"intradayFrequency\":10,\"daysBetweenReminders\":2,\"content\":\"This is content\",\"descriptionContent\":\"This is a description\" }]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let reminderList = try processor.processReminders(url: "url", numberToRetrieve: 1)
            let reminder = reminderList[0]
            XCTAssert(reminder.getReminderID() == 11)
            XCTAssert(reminder.getRemindeeID() == "123id")
            XCTAssert(reminder.getCreatorID() == "231id")
            print(reminder.getTimeCreated())
            XCTAssert(reminder.getTimeCreated() == Date(timeIntervalSince1970: 4.123))
            XCTAssert(reminder.getIntradayFrequency() == 10)
            XCTAssert(reminder.getDaysBetweenReminders() == 2)
            XCTAssert(reminder.getContent() == "This is content")
            XCTAssert(reminder.getDescriptionContent() == "This is a description")
        } catch {
            XCTAssert(false)
        }
    }
    
    func testValidReminderPost() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processNewReminder(url: "url", reminder: Reminder(reminderID: 7, content: "content", descriptionContent: "description", creatorID: "creatorID", remindeeID: "remindeeID", timeCreated: Date(timeIntervalSince1970: 0), intradayFrequency: 13, daysBetweenReminders: 3))
        } catch {
            XCTAssert(false)
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testReminderPostBadResponseCode() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processNewReminder(url: "url", reminder: Reminder(reminderID: 7, content: "content", descriptionContent: "description", creatorID: "creatorID", remindeeID: "remindeeID", timeCreated: Date(timeIntervalSince1970: 0), intradayFrequency: 13, daysBetweenReminders: 3))
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Error connecting on server with return code: 500")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testReminderPostBadResponseBody() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"unwanted\":\"data\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processNewReminder(url: "url", reminder: Reminder(reminderID: 7, content: "content", descriptionContent: "description", creatorID: "creatorID", remindeeID: "remindeeID", timeCreated: Date(timeIntervalSince1970: 0), intradayFrequency: 13, daysBetweenReminders: 3))
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Non-blank return")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testValidReminderDelete() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processDeleteReminder(url: "url", reminder: Reminder(reminderID: 7, content: "content", descriptionContent: "description", creatorID: "creatorID", remindeeID: "remindeeID", timeCreated: Date(timeIntervalSince1970: 0), intradayFrequency: 13, daysBetweenReminders: 3))
        } catch {
            XCTAssert(false)
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testReminderDeleteBadResponseCode() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processDeleteReminder(url: "url", reminder: Reminder(reminderID: 7, content: "content", descriptionContent: "description", creatorID: "creatorID", remindeeID: "remindeeID", timeCreated: Date(timeIntervalSince1970: 0), intradayFrequency: 13, daysBetweenReminders: 3))
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Error connecting on server with return code: 500")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testReminderDeleteBadResponseBody() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"unwanted\":\"data\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processDeleteReminder(url: "url", reminder: Reminder(reminderID: 7, content: "content", descriptionContent: "description", creatorID: "creatorID", remindeeID: "remindeeID", timeCreated: Date(timeIntervalSince1970: 0), intradayFrequency: 13, daysBetweenReminders: 3))
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Non-blank return")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testValidReminderEdit() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processEditReminder(deleteUrl: "url", addURl: "url", reminder: Reminder(reminderID: 7, content: "content", descriptionContent: "description", creatorID: "creatorID", remindeeID: "remindeeID", timeCreated: Date(timeIntervalSince1970: 0), intradayFrequency: 13, daysBetweenReminders: 3))
        } catch {
            XCTAssert(false)
        }
        XCTAssert(connector.getConductPostTaskCalls() == 2)
    }
    
    func testReminderEditBadResponseCode() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processEditReminder(deleteUrl: "url", addURl: "url", reminder: Reminder(reminderID: 7, content: "content", descriptionContent: "description", creatorID: "creatorID", remindeeID: "remindeeID", timeCreated: Date(timeIntervalSince1970: 0), intradayFrequency: 13, daysBetweenReminders: 3))
            XCTAssert(false)
        } catch {
            XCTAssert((error as! ConnectionError).getMessage() == "Error connecting on server with return code: 500")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testReminderEditBadResponseBody() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"unwanted\":\"data\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processEditReminder(deleteUrl: "url", addURl: "url", reminder: Reminder(reminderID: 7, content: "content", descriptionContent: "description", creatorID: "creatorID", remindeeID: "remindeeID", timeCreated: Date(timeIntervalSince1970: 0), intradayFrequency: 13, daysBetweenReminders: 3))
            XCTAssert(false)
        } catch let error {
            XCTAssert((error as! ConnectionError).getMessage() == "Non-blank return")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testValidGetKey() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"privateKeyP\":\"key1\",\"privateKeyS\":\"key2\",\"length\":3}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.retrieveEncryptedPrivateKeys(url: "url")
        } catch {
            XCTAssert(false)
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testGetKeyBadResponseCode() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"privateKeyP\":\"key1\",\"privateKeyS\":\"key2\",\"length\":3}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.retrieveEncryptedPrivateKeys(url: "url")
            XCTAssert(false)
        } catch {
            XCTAssert((error as! ConnectionError).getMessage() == "Error connecting on server with return code: 500")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testGetKeyBadResponseFormat() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"privateKeyP\":\"key1\",\"privateKeyS\":\"key2\",\"length\":\"3\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.retrieveEncryptedPrivateKeys(url: "url")
            XCTAssert(false)
        } catch let error {
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was missing or in an incorrect format")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testValidPostKey() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.postKeys(url: "url", privateKeyP: "key1", privateKeyS: "key2", length: 2, publicKey: "pubKey")
        } catch {
            XCTAssert(false)
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testPostKeyBadResponseCode() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.postKeys(url: "url", privateKeyP: "key1", privateKeyS: "key2", length: 2, publicKey: "pubKey")
            XCTAssert(false)
        } catch {
            XCTAssert((error as! ConnectionError).getMessage() == "Error connecting on server with return code: 500")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testPostKeyBadResponseBody() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"unwanted\":\"data\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.postKeys(url: "url", privateKeyP: "key1", privateKeyS: "key2", length: 2, publicKey: "pubKey")
            XCTAssert(false)
        } catch let error {
            XCTAssert((error as! ConnectionError).getMessage() == "Non-blank return")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    func testAppointmentListAppointmentInvalidJSONArray() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data(("{\"[0]]\":{\"appointmentID\":1,\"content\":\"123\",\"timeScheduled\":1583692386455,\"withID\":\"2id\",\"status\":1}}").data(using: .utf8)!), responseHeader: response, potentialError: nil)

        let processor = ConnectionProcessor(connector: connector)
        do {
            let _ = try processor.processAppointments(url: "url")
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was an incorrect format")
        }
    }
    
    func testAppointmentListAppointmentJSONArray() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data(("{\"appointmentList\":[\"bad\",{\"appointmentID\":1,\"content\":\"123\",\"timeScheduled\":1583692386455,\"withID\":\"2id\",\"status\":1}]}").data(using: .utf8)!), responseHeader: response, potentialError: nil)

        let processor = ConnectionProcessor(connector: connector)
        do {
            let _ = try processor.processAppointments(url: "url")
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was an incorrect format")
        }
    }
    
    func testAppointmentListAppointmentFieldType() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data(("{\"appointmentList\":[{\"appointmentID\":1,\"content\":\"123\",\"timeScheduled\":1583692386455,\"withID\":2,\"status\":1}]}").data(using: .utf8)!), responseHeader: response, potentialError: nil)

        let processor = ConnectionProcessor(connector: connector)
        do {
            let _ = try processor.processAppointments(url: "url")
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was an incorrect format")
        }
    }
    
    func testValidAppointmentRetrieval() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data(("{\"appointmentList\":[{\"appointmentID\":1,\"content\":\"123\",\"timeScheduled\":1583692386455,\"withID\":\"2id\",\"status\":1}]}").data(using: .utf8)!), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let appointmentList = try processor.processAppointments(url: "url")
            let appointment = appointmentList[0]
            XCTAssert(appointment.getAppointmentID() == 1)
            XCTAssert(appointment.getContent() == "123")
            XCTAssert(appointment.getTimeScheduled() == Date(timeIntervalSince1970: 1583692386.455))
            XCTAssert(appointment.getWithID() == "2id")
            XCTAssert(appointment.getStatus() == 1)
        } catch {
            XCTAssert(false)
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
     }
     
     func testValidAppointmentPost() {
         let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
         let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
         let processor = ConnectionProcessor(connector: connector)
         do {
            try processor.processNewAppointment(url: "url", appointment: Appointment(appointmentID: 322, content: "This is content", timeScheduled: Date(timeIntervalSince1970: 1583692386455), withID: "docID-4"))
         } catch {
             XCTAssert(false)
         }
         XCTAssert(connector.getConductPostTaskCalls() == 1)
     }
     
     func testAppointmentPostBadResponseCode() {
         let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
         let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
         let processor = ConnectionProcessor(connector: connector)
         do {
             try processor.processNewAppointment(url: "url", appointment: Appointment(appointmentID: 322, content: "This is content", timeScheduled: Date(timeIntervalSince1970: 1583692386455), withID: "docID-4"))
             XCTAssert(false)
         } catch let error {
             print((error as! ConnectionError).getMessage())
             XCTAssert((error as! ConnectionError).getMessage() == "Error connecting on server with return code: 500")
         }
         XCTAssert(connector.getConductPostTaskCalls() == 1)
     }
     
     func testAppointmentPostBadResponseBody() {
         let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
         let connector = ConnectorMock(returnData: Data("{\"unwanted\":\"data\"}".utf8), responseHeader: response, potentialError: nil)
         let processor = ConnectionProcessor(connector: connector)
         do {
             try processor.processNewAppointment(url: "url", appointment: Appointment(appointmentID: 322, content: "This is content", timeScheduled: Date(timeIntervalSince1970: 1583692386455), withID: "docID-4"))
             XCTAssert(false)
         } catch let error {
             print((error as! ConnectionError).getMessage())
             XCTAssert((error as! ConnectionError).getMessage() == "Non-blank return")
         }
         XCTAssert(connector.getConductPostTaskCalls() == 1)
     }

    //This test is testMessagePostBadStatus preceeding testValidConversationList without the ConnectionProcessor being reinititalized. This should provide some confidence that it is relatively stateless
    func testConsecutiveExecutions() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"conversationList\":[{\"conversationID\":1,\"converserID\":\"0id\",\"converserPublicKey\":\"key\",\"adminPublicKey\":\"key\",\"conversationName\":\"0id\",\"lastMessageTime\":0,\"status\":0,\"numMembers\":2,\"description\":\"descriptive\"}]}".utf8), responseHeader: response, potentialError: ConnectionError(message: "Test error"))
        //connector.setToken(potentialTokens: Tokens(idToken: SessionToken(tokenString: "a"), accessToken: nil, refreshToken: nil, expiration: nil), potentialError: nil)
            //(idToken: SessionToken(tokenString: "token")), potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialData, potentialError) = processor.retrieveData(urlString: "url")
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "Error connecting to server")
        XCTAssert(potentialData == nil)
        connector.modifyResponse(newResponse: HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]()))
        connector.modifyError(newError: nil)
        let (potentialConversationList, potentialError2) = processor.processConversationList(url: "url")
        XCTAssert(potentialError2 == nil)
        XCTAssert(potentialConversationList != nil)
        let conversationList = potentialConversationList!
        XCTAssert(conversationList[0].getConverserID() == "0id")
        XCTAssert(conversationList[0].getConversationName() == "0id")
        XCTAssert(conversationList[0].getLastMessageTime() == Date(timeIntervalSince1970: 0))
        XCTAssert(conversationList[0].getStatus() == 0)
        
    }
    
    // Delete message
    func testMessageDeleteBadResponseCode() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processDeleteMessage(url: "url", messageId: 1)
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Error connecting on server with return code: 500")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    // Delete message
    func testMessageDeleteBadResponseBody() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"unwanted\":\"data\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processDeleteMessage(url: "url", messageId: 1)
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Non-blank return")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    // Delete user
    func testUserDeleteBadResponseCode() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let asserted = try processor.processDeleteUser(url: "url", uid: "1id")
            XCTAssert((asserted != nil))
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Error connecting on server with return code: 500")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    // Delete user
    func testUserDeleteBadResponseBody() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"unwanted\":\"data\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let asserted = try processor.processDeleteUser(url: "url", uid: "1id")
            XCTAssert((asserted != nil))
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Non-blank return")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    // Leave conversation
    func testLeaveConversationBadResponseCode() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processLeaveConversation(url: "url", convoID: "1")
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Error connecting on server with return code: 500")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    // Leave Conversation
    func testLeaveConversationBadResponseBody() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"unwanted\":\"data\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let asserted = try processor.processLeaveConversation(url: "url", convoID: "1")
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Non-blank return")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
    // Get User Info
    func testUserInfoBadResponseCode() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processGetUserInfo(url: "url", uid: "userID")
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "Error connecting on server with return code: 500")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    

    func testUserInfoBadResponseFormat() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"firstName\":2,\"lastName\":\"data\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processGetUserInfo(url: "url", uid: "userID")
            XCTAssert(false)
        } catch let error {
            print((error as! ConnectionError).getMessage())
            XCTAssert((error as! ConnectionError).getMessage() == "At least one JSON field was an incorrect format")
        }
        XCTAssert(connector.getConductPostTaskCalls() == 1)
    }
    
}

class ConnectorTests : XCTestCase {
    func testValidConductGetTask() {
        let session = SessionMock()
        let tokenGuard = TokenGuardMock()
        let connector = Connector(tokenGuard: tokenGuard, session: session)
        connector.setToken(potentialTokens: Tokens(idToken: SessionToken(tokenString: "a"), accessToken: SessionToken(tokenString: "b"), refreshToken: SessionToken(tokenString: "c"), expiration: nil), potentialError: nil)
        var request = URLRequest(url: URL(string: "url")!)
        connector.conductGetTask(manager: ConnectionProcessorMock(), request: &request)
        XCTAssert(tokenGuard.wasPassed() == true)
        XCTAssert(session.checkResumed() == true)
    }
    
    func testValidConductPostTask() {
        let session = SessionMock()
        let tokenGuard = TokenGuardMock()
        let connector = Connector(tokenGuard: tokenGuard, session: session)
        connector.setToken(potentialTokens: Tokens(idToken: SessionToken(tokenString: "a"), accessToken: SessionToken(tokenString: "b"), refreshToken: SessionToken(tokenString: "c"), expiration: nil), potentialError: nil)

        var request = URLRequest(url: URL(string: "url")!)
        connector.conductPostTask(manager: ConnectionProcessorMock(), request: &request, data: Data())
        XCTAssert(tokenGuard.wasPassed() == true)
        XCTAssert(session.checkResumed() == true)
    }
}

class ConnectorMock: Connector {
    private var conductRetrievalTaskCalls = Int(0);
    private var conductPostTaskCalls = Int(0);
    var returnData = Data?(nil)
    var responseHeader = URLResponse?(nil)
    var potentialError = Error?(nil)
    var postedData: Data? = nil
    
    init() {
        
    }
    
    init(returnData: Data?, responseHeader: URLResponse?, potentialError: Error?) {
        self.returnData = returnData
        self.responseHeader = responseHeader
        self.potentialError = potentialError
    }
    
    override func conductGetTask(manager: ConnectionProcessor, request: inout URLRequest) {
        conductRetrievalTaskCalls += 1
        
        manager.processConnection(returnData: returnData, response: responseHeader, potentialError: potentialError)
    }
    
    override func conductPostTask(manager: ConnectionProcessor, request: inout URLRequest, data: Data) {
        conductPostTaskCalls += 1
        postedData = data
        manager.processConnection(returnData: returnData, response: responseHeader, potentialError: potentialError)
    }
    
    func getPostedData() -> Data? {
        return postedData
    }
    
    func getConductRetrievalTaskCalls() -> Int {
        return conductRetrievalTaskCalls
    }
    
    func getConductPostTaskCalls() -> Int {
        return conductPostTaskCalls
    }
    
    func modifyResponse(newResponse: URLResponse?) {
        responseHeader = newResponse
    }
    
    func modifyError(newError: Error?) {
        potentialError = newError
    }
}

class TokenGuardMock : TokenGuard {
    private var passed = false;
    
    override func pass() {
        passed = true
    }
    
    func wasPassed() -> Bool {
        return passed
    }
}

class SessionMock : URLSession {
    private let dataTaskMock = URLSessionDataTaskMock()
    private let uploadTaskMock = URLSessionUploadTaskMock()
    
    override init() {
        
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return dataTaskMock
    }
    
    override func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        return uploadTaskMock
    }
    
    func checkResumed() -> Bool {
        return dataTaskMock.checkResumed() || uploadTaskMock.checkResumed()
    }
}

class URLSessionDataTaskMock : URLSessionDataTask {
    private var resumed = false;
    
    override init() {
        
    }
    
    override func resume() {
        resumed = true;
    }
    
    func checkResumed() -> Bool {
        return resumed
    }
}

class URLSessionUploadTaskMock : URLSessionUploadTask {
    private var resumed = false;
    
    override init() {
        
    }
    
    override func resume() {
        resumed = true;
    }
    
    func checkResumed() -> Bool {
        return resumed
    }
}

class ConnectionProcessorMock : ConnectionProcessor {
    override init(connector: Connector = ConnectorMock()) {
        super.init(connector: connector)
    }
    override func processConnection(returnData: Data?, response: URLResponse?, potentialError: Error?) {
        
    }
}

class MessageCipherMock : MessageCipher {
    init (conenctionProcessor: ConnectionProcessor) throws {
//        let (newPrivateKey, _ ,length,  _) = LocalCipher().generateKetSet(password: "password", securityQuestionAnswers: ["answer"], username: "notunique")
        try super.init(uniqueID: "notunique", localAESKey: LocalCipher().getAESFromPass(password: "pass", username: "notunique"), processor: conenctionProcessor)
    }
    
}
