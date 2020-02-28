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
        var (potentialData, potentialError) = processor.retrieveData(urlString: "url")
        XCTAssert(potentialError == nil)
        XCTAssert(potentialData != nil)
        XCTAssert(potentialData!.count == 2)
        //XCTAssert(potentialData?.contains(key: "key1", value: "val1"))
        XCTAssert(potentialData?["key1"] as! String == "val1")
        XCTAssert(potentialData?["key2"] as! String == "val2")
    }
    
    func testConversationListInvalidDataType() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"[0]\":{\"conversationID\":1,\"converserID\":\"0\",\"lastMessageTime\":0,\"status\":0}}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        var (potentialConversationList, potentialError) = processor.processConversationList(url: "url")
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "At least one JSON field was an incorrect format")
        XCTAssert(potentialConversationList == nil)
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
        let connector = ConnectorMock(returnData: Data("{\"conversationList\":[{\"conversationID\":1,\"converserID\":0,\"lastMessageTime\":0,\"status\":0}]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialConversationList, potentialError) = processor.processConversationList(url: "url")
        XCTAssert(potentialError == nil)
        XCTAssert(potentialConversationList != nil)
        let conversationList = potentialConversationList!
        XCTAssert(conversationList[0].getConversationPartner().getUID() == 0)
        XCTAssert(conversationList[0].getLastMessageTime() == Date(timeIntervalSince1970: 0))
        XCTAssert(conversationList[0].getUnreadMessages() == false)
    }
    
    func testMessagePostBadStatus() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let potentialError = processor.processNewMessage(url: "url", message: Message(messageID: 1, conversation: Conversation(conversationID: 1)!, content: [UInt8]("content".utf8), sender: User(uid: 1)!))
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "Error connecting on server with return code: 500")
    }
    
    func testValidMessagePost() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let potentialError = processor.processNewMessage(url: "url", message: Message(messageID: 1, conversation: Conversation(conversationID: 1)!, content: [UInt8]("content".utf8), sender: User(uid: 1)!))
        XCTAssert(connector.getConductPostTaskCalls() == 1)
        XCTAssert(potentialError == nil)
    }
    
    func testValidMessageRetrieval() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"messageList\":[{\"messageID\":1,\"conversationID\":0,\"content\":\"123\",\"senderID\":2}]}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        do {
            let potentialMessageList = try processor.processMessages(url: "url", conversation: Conversation(conversationID: 0)!, numberToRetrieve: 1)
            XCTAssert(potentialMessageList != nil)
            let messageList = potentialMessageList!
            XCTAssert(messageList[0].getConversation().getConversationID() == 0)
            XCTAssert(messageList[0].getContent() == [UInt8]("123".utf8))
            XCTAssert(messageList[0].getSender().getUID() == 2)
        } catch {
            XCTAssert(false)
        }
    }
    
    //This test is testMessagePostBadStatus preceeding testValidConversationList without the ConnectionProcessor being reinititalized. This should provide some confidence that it is relatively stateless
    func testConsecutiveExecutions() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(500), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"conversationList\":[{\"conversationID\":1,\"converserID\":0,\"lastMessageTime\":0,\"status\":0}]}".utf8), responseHeader: response, potentialError: ConnectionError(message: "Test error")) //NOTE: The error would not be of this type but I do not knwo what type it would be
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
        XCTAssert(conversationList[0].getConversationPartner().getUID() == 0)
        XCTAssert(conversationList[0].getLastMessageTime() == Date(timeIntervalSince1970: 0))
        XCTAssert(conversationList[0].getUnreadMessages() == false)
        
    }
}

class ConnectorMock: Connector {
    private var conductRetrievalTaskCalls = Int(0);
    private var conductPostTaskCalls = Int(0);
    var returnData = Data?(nil)
    var responseHeader = URLResponse?(nil)
    var potentialError = Error?(nil)
    
    override init() {
    }
    
    init(returnData: Data?, responseHeader: URLResponse?, potentialError: Error?) {
        self.returnData = returnData
        self.responseHeader = responseHeader
        self.potentialError = potentialError
    }
    
    override func conductGetTask(manager: ConnectionProcessor, url: URL) {
        conductRetrievalTaskCalls += 1
        
        manager.processConnection(returnData: returnData, response: responseHeader, potentialError: potentialError)
    }
    
    override func conductPostTask(manager: ConnectionProcessor, url: URL, data: Data) {
        conductPostTaskCalls += 1
        
        manager.processConnection(returnData: returnData, response: responseHeader, potentialError: potentialError)
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
