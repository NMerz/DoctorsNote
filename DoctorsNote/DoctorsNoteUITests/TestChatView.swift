//
//  TestChatView.swift
//  DoctorsNoteUITests
//
//  Created by Benjamin Hardin on 3/25/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import XCTest

class TestChatView: XCTestCase {

    var app: XCUIApplication?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        self.app = XCUIApplication()
        app?.launch()
        app?.activate()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDoctorProfile() throws {
        app?.tabBars.buttons["Chats"].tap()
        sleep(1)
        app?.collectionViews.cells.element(boundBy: 0).tap()
        sleep(1)
        app?.buttons["Info Button"].tap()
        XCTAssert(app!.staticTexts["Work Hours Label"].exists)
    }

}
