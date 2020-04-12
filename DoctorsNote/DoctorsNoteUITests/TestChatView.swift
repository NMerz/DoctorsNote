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
        tryLogout()
    }

    func testDoctorProfile() throws {
        tryLogin()
        app?.tabBars.buttons["Chats"].tap()
        sleep(1)
        app?.collectionViews.cells.element(boundBy: 0).tap()
        sleep(1)
        app?.buttons["Info Button"].tap()
        XCTAssert(app!.staticTexts["Work Hours Label"].exists)
    }
    
    func tryLogin() {
        let emailField = app!.textFields["Email Field"]
        let passwordField = app!.secureTextFields["Password Field"]
        
        if (emailField.isHittable) {
            emailField.tap()
            emailField.typeText("hardin30@purdue.edu")
            
            passwordField.press(forDuration: 1.1)
            passwordField.typeText("DoctorsNote1@")
            
            app?.staticTexts["Account Label"].tap()
            app?.buttons["Log In"].tap()
            sleep(2)
        }
    }
    
    func tryLogout() {
        if (app!.buttons["Log Out"].exists) {
            app?.buttons["Log Out"].tap()
        }
    }

}
