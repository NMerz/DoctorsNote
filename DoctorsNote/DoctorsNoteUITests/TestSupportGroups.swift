//
//  TestSupportGroups.swift
//  DoctorsNoteUITests
//
//  Created by Benjamin Hardin on 3/23/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import XCTest

class TestSupportGroups: XCTestCase {

    var app: XCUIApplication?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        self.app = XCUIApplication()
        app?.launch()
        app?.activate()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJoinPrompts() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // Need to login?
        
        // Navigate to support groups page
        app?.tabBars.buttons["Support Groups"].tap()
        app?.buttons["Search Icon"].tap()
        app?.tables.cells.element(boundBy: 0).buttons["Information Icon"].tap()
        app?.buttons["Join Button"].tap()
        app?.alerts.textFields["Display Name Field"].tap()
        app?.alerts.textFields["Display Name Field"].typeText("Test Display Name")
        app?.alerts.buttons["Set Name Button"].tap()
        app?.alerts.buttons["Ok Button"].tap()
    }

}
