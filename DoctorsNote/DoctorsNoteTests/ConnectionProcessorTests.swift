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
    
    

    func testRetrievalConducted() {
        let connector = ConnectorMock()
        let processor = ConnectionProcessor(connector: connector)
        XCTAssert(connector.getConductRetrievalTaskCalls() == 0)
        processor.retrieveData(urlString: "garbage")
        XCTAssert(connector.getConductRetrievalTaskCalls() == 1)
        
    }
    
    func testDefaultProcesingDoesNothing() {
        let connector = ConnectorMock()
        let processor = ConnectionProcessor(connector: connector)
        XCTAssert(processor.retrieveData(urlString: "default").isEmpty == true)
    }

    func testConversationListNotEmpty() {
        let response = HTTPURLResponse(url: URL(string: "url")!, statusCode: Int(200), httpVersion: "HTTP/1.0", headerFields: [String : String]())
        let connector = ConnectorMock(returnData: Data("{\"key1\":\"val1\"}".utf8), responseHeader: response, potentialError: nil)
        let processor = ConnectionProcessor(connector: connector, connectionType: "conversationList")
        XCTAssert(processor.retrieveData(urlString: "url").isEmpty == false)
    }
}

class ConnectorMock: Connector {
    private var conductRetrievalTaskCalls = Int(0);
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
    
    func getConductRetrievalTaskCalls() -> Int {
        return conductRetrievalTaskCalls
    }
}

