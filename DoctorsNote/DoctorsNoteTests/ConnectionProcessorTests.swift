//
//  ConnectionProcessorTests.swift
//  DoctorsNoteTests
//
//  Created by Nathan Merz on 2/16/20.
//  Copyright © 2020 Nathan Merz. All rights reserved.
//

import XCTest

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
        XCTAssert(potentialError?.getMessage() == "Unknown Error")
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
        let connector = ConnectorMock(returnData: Data("{\"[0]\":{\"conversationID\":1,\"conversationPartner\":\"0\",\"lastMessageTime\":0,\"unreadMessages\":\"false\"}}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        var (potentialConversationList, potentialError) = processor.processConversationList(url: "url")
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "At least one JSON field was an incorrect format")
        XCTAssert(potentialConversationList == nil)
    }
    
    func testConversationListLowerFailure() {
        let connector = ConnectorMock()
        let processor = ConnectionProcessor(connector: connector)
        XCTAssert(connector.getConductRetrievalTaskCalls() == 0)
        let (potentialConversationList, potentialError) = processor.processConversationList(url: "garbage")
        XCTAssert(potentialConversationList == nil)
        XCTAssert(potentialError != nil)
        XCTAssert(potentialError?.getMessage() == "Unknown Error")
    }
    
    func testValidConversationList() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"[0]\":{\"conversationID\":1,\"conversationPartner\":0,\"lastMessageTime\":0,\"unreadMessages\":\"false\"}}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector)
        let (potentialConversationList, potentialError) = processor.processConversationList(url: "url")
        XCTAssert(potentialError == nil)
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
    
    override func conductRetrievalTask(manager: ConnectionProcessor, url: URL) {
        conductRetrievalTaskCalls += 1
        
        manager.processConnection(returnData: returnData, responseHeader: responseHeader, potentialError: potentialError)
    }
    
    override func conductPostTask(manager: ConnectionProcessor, url: URL, data: Data) {
        conductPostTaskCalls += 1
        
        manager.processConnection(returnData: returnData, responseHeader: responseHeader, potentialError: potentialError)
    }
    
    func getConductRetrievalTaskCalls() -> Int {
        return conductRetrievalTaskCalls
    }
    
    func getConductPostTaskCalls() -> Int {
        return conductPostTaskCalls
    }
}

