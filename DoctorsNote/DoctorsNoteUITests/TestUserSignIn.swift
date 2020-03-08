//
//  TestUserSignUp.swift
//  DoctorsNoteUITests
//
//  Created by Benjamin Hardin on 3/8/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import XCTest

class TestUserSignIn: XCTestCase {

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

    func testUserSignIn() {
        // Check if signed in
        app?.buttons["Log In"].tap()
        XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "")
        
        let emailField = app!.textFields["Email Field"]
        let passwordField = app!.secureTextFields["Password Field"]
        
        emailField.tap()
        emailField.typeText("testemail")
        app?.buttons["Log In"].tap()
        XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "")
        
        passwordField.tap()
        passwordField.typeText("testpassword")
        app?.buttons["Log In"].tap()
        XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "")
        
        emailField.tap()
        emailField.typeText("test@email.com")
        app?.buttons["Log In"].tap()
        
        sleep(2)
        // Make sure that the app has changed views
        XCTAssert(!app!.staticTexts["Error Label"].exists)
        
        
    }

}
