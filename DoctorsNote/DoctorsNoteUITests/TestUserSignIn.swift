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

    func testUserSignInAndOut() {
        // Check if signed in
        app?.buttons["Log In"].tap()
        XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "")
        
        let emailField = app!.textFields["Email Field"]
        let passwordField = app!.secureTextFields["Password Field"]
        
        emailField.tap()
        emailField.typeText("testemail")
        app?.buttons["Log In"].tap()
        XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "")
        
        passwordField.press(forDuration: 1.1)
        passwordField.typeText("testpassword")
        app?.buttons["Log In"].tap()
        XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "")
        
        emailField.tap()
        emailField.clearAndEnterText(text: "test@email.com")
        app?.buttons["Log In"].tap()
        
        XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "Incorrect username or password.")
        
        // FIXME: Remove and create real test account
        emailField.tap()
        emailField.clearAndEnterText(text: "hardin30@purdue.edu")
        passwordField.tap()
        passwordField.typeText("DoctorsNote1@")
        app?.buttons["Log In"].tap()
        sleep(2)
        XCTAssertFalse(app!.buttons["Log In"].isHittable)
        
        let logOutButton = app!.buttons["Log Out"].tap()
        sleep(2)
        XCTAssertFalse(app!.buttons["Log Out"].isHittable)
    }

}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        self.typeText(deleteString)
        self.typeText(text)
    }
}
