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
        
        tryLogout()
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        tryLogout()
    }

    func testUserSignInAndOut() {
        // Check if signed in
        let loginButton = app!.buttons["Log In"]
        
        loginButton.tap()
        //XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "")
        
        let emailField = app!.textFields["Email Field"]
        let passwordField = app!.secureTextFields["Password Field"]
        let accountLabel = app!.staticTexts["Account Label"]
        
        emailField.tap()
        emailField.typeText("testemail")
        passwordField.tap()
        accountLabel.tap()
        loginButton.tap()
        XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "")
        
        passwordField.press(forDuration: 1.1)
        passwordField.typeText("testpassword")
        accountLabel.tap()
        app?.buttons["Log In"].tap()
        XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "")
        
        emailField.tap()
        emailField.clearAndEnterText(text: "test@email.com")
        accountLabel.tap()
        app?.buttons["Log In"].tap()
        
        XCTAssertNotEqual(app!.staticTexts.element(matching:.any, identifier: "Error Label").label, "Incorrect username or password.")
        
        // Test a real account
        emailField.tap()
        emailField.clearAndEnterText(text: "hardin30@purdue.edu")
        passwordField.tap()
        passwordField.typeText("DoctorsNote1@")
        accountLabel.tap()
        app?.buttons["Log In"].tap()
        sleep(2)
        
        app!.buttons["Log Out"].tap()
    
    }
    
    func testResetPassword() {
        
        let emailField = app!.textFields["Email Field"]
        
        app?.buttons["Forgot Button"].tap()
        
        emailField.tap()
        emailField.typeText("test@test.test")
        
        app?.buttons["Recover Button"].tap()
        
        // Check for existence of popup
        app?.buttons["Close Button"].tap()
        
        // Check that it moved on to the next view controller
        app?.textFields["Verification Field"].tap()
        
    }
    
    func testSignup() {
        
        if (app!.buttons["Back"].isHittable) {
            app!.buttons["Back"].tap()
        }
        
        app?.buttons["Request Button"].tap()
        
        let emailField = app!.textFields["Email Field"]
        let passwordField = app!.secureTextFields["Password Field"]
        let confirmField = app!.secureTextFields["Confirm Field"]
        let errorLabel = app!.staticTexts["Error Label"]
    
        // Todo: Check for incorrect field formatting
        
        emailField.tap()
        emailField.typeText("test@test.test")
        
        passwordField.tap()
        passwordField.typeText("ExamplePassword1!")
        
        // Check for non-matching passwords
        confirmField.tap()
        confirmField.typeText("Different Password")
        // Tap elsewhere to dismiss keyboard
        app?.staticTexts["Email"].tap()
        app?.buttons["Forward"].tap()
        print("Value is: ", errorLabel.label as! String)
        XCTAssert(errorLabel.label as! String != "")
        
        // Check for matching passwords
        confirmField.tap()
        confirmField.typeText("ExamplePassword1!")
        // Tap elsewhere to dismiss keyboard
        app?.staticTexts["Email"].tap()
        
        app?.buttons["Forward"].tap()
        
        // Check to make sure we moved on to the next view
        app?.buttons["Create Account"].tap()
    }
    
    func testProfileInformationUpdate() {
        let firstNameField = app!.textFields["First Name Field"]
        let middleNameField = app!.textFields["Middle Name Field"]
        let lastNameField = app!.textFields["Last Name Field"]
        let DOBButton = app!.buttons["DOB Button"]
        let sexButton = app!.buttons["Sex Button"]
        let phoneField = app!.textFields["Phone Field"]
        let streetField = app!.textFields["Street Field"]
        let cityField = app!.textFields["City Field"]
        let stateButton = app!.buttons["State Button"]
        let zipField = app!.textFields["ZIP Field"]
        let closeButton = app!.buttons["Close Button"]
        let forwardButton = app!.buttons["Forward"]
        let errorLabel = app!.staticTexts["Error Label"]
        
        if (app!.textFields["Email Field"].exists) {
            app?.textFields["Email Field"].tap()
            app?.textFields["Email Field"].typeText("bbh@purdue.edu")
            
            app?.secureTextFields["Password Field"].tap()
            app?.secureTextFields["Password Field"].typeText("DoctorsNote1@")
            app?.staticTexts["Account Label"].tap()
            
            app?.buttons["Log In"].tap()
        }
        
        // Check no entries filled
        forwardButton.tap()
        // Make sure we haven't move on to the next view
        XCTAssert(errorLabel.label != "")
        
        // Check entries filled
        firstNameField.tap()
        firstNameField.typeText("First")
        
        middleNameField.tap()
        middleNameField.typeText("Middle")
        
        lastNameField.tap()
        lastNameField.typeText("Last")
        
        DOBButton.tap()
        closeButton.tap()
        
        app?.swipeUp()
        
        sexButton.tap()
        closeButton.tap()
        
        phoneField.tap()
        phoneField.typeText("1234567890")
        
        streetField.tap()
        streetField.typeText("Street")
        
        cityField.tap()
        cityField.typeText("City")
        
        stateButton.tap()
        app?.cells.element(boundBy: 0).tap()
        
        zipField.tap()
        zipField.typeText("1234")
        
        // Hide keyboard
        app?.staticTexts["City"].tap()
        
        forwardButton.tap()
        
        app!.swipeDown()
        
        sleep(2)
        
        app!.swipeUp()
        
        sleep(1)
        
        zipField.tap()
        zipField.typeText("5")
        
        // Hide keyboard
        app?.staticTexts["City"].tap()
        
        forwardButton.tap()
        
        // Now on Healthcare Information page
        let roleButton = app!.buttons["Select Role"]
        let hospitalButton = app!.buttons["Select Hospital"]
        let healthcareButton = app!.buttons["Select Healthcare Provider"]
        let requestButton = app!.buttons["Request Button"]
        
        // Check that you cannot request account without entering information
        requestButton.tap()
        XCTAssert(errorLabel.label != "")
        
        // Enter information
        roleButton.tap()
        sleep(3)
        closeButton.tap()
        XCTAssert(roleButton.title != "Select Role")
        
        hospitalButton.tap()
        sleep(3)
        closeButton.tap()
        XCTAssert(hospitalButton.title != "Select Hospital")
        
        healthcareButton.tap()
        sleep(3)
        closeButton.tap()
        XCTAssert(healthcareButton.title != "Select Healthcare Provider")
        
    }
    
    func testInvalidDOB() {
        let firstNameField = app!.textFields["First Name Field"]
        let middleNameField = app!.textFields["Middle Name Field"]
        let lastNameField = app!.textFields["Last Name Field"]
        let DOBButton = app!.buttons["DOB Button"]
        let sexButton = app!.buttons["Sex Button"]
        let phoneField = app!.textFields["Phone Field"]
        let streetField = app!.textFields["Street Field"]
        let cityField = app!.textFields["City Field"]
        let stateButton = app!.buttons["State Button"]
        let zipField = app!.textFields["ZIP Field"]
        let closeButton = app!.buttons["Close Button"]
        let forwardButton = app!.buttons["Forward"]
        let errorLabel = app!.staticTexts["Error Label"]
        
        if (app!.textFields["Email Field"].exists) {
            app?.textFields["Email Field"].tap()
            app?.textFields["Email Field"].typeText("bbh@purdue.edu")
            
            app?.secureTextFields["Password Field"].tap()
            app?.secureTextFields["Password Field"].typeText("DoctorsNote1@")
            app?.staticTexts["Account Label"].tap()
            
            app?.buttons["Log In"].tap()
        }
        
        // Check no entries filled
        forwardButton.tap()
        // Make sure we haven't move on to the next view
        XCTAssert(errorLabel.label != "")
        
        // Check entries filled
        firstNameField.tap()
        firstNameField.typeText("First")
        
        middleNameField.tap()
        middleNameField.typeText("Middle")
        
        lastNameField.tap()
        lastNameField.typeText("Last")
        
        app?.swipeUp()
        
        sexButton.tap()
        closeButton.tap()
        
        phoneField.tap()
        phoneField.typeText("1234567890")
        
        streetField.tap()
        streetField.typeText("Street")
        
        cityField.tap()
        cityField.typeText("City")
        
        stateButton.tap()
        app?.cells.element(boundBy: 0).tap()
        
        zipField.tap()
        zipField.typeText("12345")
        
        // Hide keyboard
        app?.staticTexts["City"].tap()
        
        forwardButton.tap()
        
    }
    
    func testInvalidSex() {
        let firstNameField = app!.textFields["First Name Field"]
        let middleNameField = app!.textFields["Middle Name Field"]
        let lastNameField = app!.textFields["Last Name Field"]
        let DOBButton = app!.buttons["DOB Button"]
        let sexButton = app!.buttons["Sex Button"]
        let phoneField = app!.textFields["Phone Field"]
        let streetField = app!.textFields["Street Field"]
        let cityField = app!.textFields["City Field"]
        let stateButton = app!.buttons["State Button"]
        let zipField = app!.textFields["ZIP Field"]
        let closeButton = app!.buttons["Close Button"]
        let forwardButton = app!.buttons["Forward"]
        let errorLabel = app!.staticTexts["Error Label"]
        
        if (app!.textFields["Email Field"].exists) {
            app?.textFields["Email Field"].tap()
            app?.textFields["Email Field"].typeText("bbh@purdue.edu")
            
            app?.secureTextFields["Password Field"].tap()
            app?.secureTextFields["Password Field"].typeText("DoctorsNote1@")
            app?.staticTexts["Account Label"].tap()
            
            app?.buttons["Log In"].tap()
        }
        
        // Check no entries filled
        forwardButton.tap()
        // Make sure we haven't move on to the next view
        XCTAssert(errorLabel.label != "")
        
        // Check entries filled
        firstNameField.tap()
        firstNameField.typeText("First")
        
        middleNameField.tap()
        middleNameField.typeText("Middle")
        
        lastNameField.tap()
        lastNameField.typeText("Last")
        
        DOBButton.tap()
        closeButton.tap()
        
        app?.swipeUp()
        
        phoneField.tap()
        phoneField.typeText("1234567890")
        
        streetField.tap()
        streetField.typeText("Street")
        
        cityField.tap()
        cityField.typeText("City")
        
        stateButton.tap()
        app?.cells.element(boundBy: 0).tap()
        
        zipField.tap()
        zipField.typeText("12345")
        
        // Hide keyboard
        app?.staticTexts["City"].tap()
        
        forwardButton.tap()
    }
    
    func testInvalidState() {
        let firstNameField = app!.textFields["First Name Field"]
        let middleNameField = app!.textFields["Middle Name Field"]
        let lastNameField = app!.textFields["Last Name Field"]
        let DOBButton = app!.buttons["DOB Button"]
        let sexButton = app!.buttons["Sex Button"]
        let phoneField = app!.textFields["Phone Field"]
        let streetField = app!.textFields["Street Field"]
        let cityField = app!.textFields["City Field"]
        let stateButton = app!.buttons["State Button"]
        let zipField = app!.textFields["ZIP Field"]
        let closeButton = app!.buttons["Close Button"]
        let forwardButton = app!.buttons["Forward"]
        let errorLabel = app!.staticTexts["Error Label"]
        
        if (app!.textFields["Email Field"].exists) {
            app?.textFields["Email Field"].tap()
            app?.textFields["Email Field"].typeText("bbh@purdue.edu")
            
            app?.secureTextFields["Password Field"].tap()
            app?.secureTextFields["Password Field"].typeText("DoctorsNote1@")
            app?.staticTexts["Account Label"].tap()
            
            app?.buttons["Log In"].tap()
        }
        
        // Check no entries filled
        forwardButton.tap()
        // Make sure we haven't move on to the next view
        XCTAssert(errorLabel.label != "")
        
        // Check entries filled
        firstNameField.tap()
        firstNameField.typeText("First")
        
        middleNameField.tap()
        middleNameField.typeText("Middle")
        
        lastNameField.tap()
        lastNameField.typeText("Last")
        
        DOBButton.tap()
        closeButton.tap()
        
        app?.swipeUp()
        
        sexButton.tap()
        closeButton.tap()
        
        phoneField.tap()
        phoneField.typeText("1234567890")
        
        streetField.tap()
        streetField.typeText("Street")
        
        cityField.tap()
        cityField.typeText("City")
        
        zipField.tap()
        zipField.typeText("1234")
        
        // Hide keyboard
        app?.staticTexts["City"].tap()
        
        forwardButton.tap()
        
    }
    
    func testEmptyStreet() {
        let firstNameField = app!.textFields["First Name Field"]
        let middleNameField = app!.textFields["Middle Name Field"]
        let lastNameField = app!.textFields["Last Name Field"]
        let DOBButton = app!.buttons["DOB Button"]
        let sexButton = app!.buttons["Sex Button"]
        let phoneField = app!.textFields["Phone Field"]
        let streetField = app!.textFields["Street Field"]
        let cityField = app!.textFields["City Field"]
        let stateButton = app!.buttons["State Button"]
        let zipField = app!.textFields["ZIP Field"]
        let closeButton = app!.buttons["Close Button"]
        let forwardButton = app!.buttons["Forward"]
        let errorLabel = app!.staticTexts["Error Label"]
        
        if (app!.textFields["Email Field"].exists) {
            app?.textFields["Email Field"].tap()
            app?.textFields["Email Field"].typeText("bbh@purdue.edu")
            
            app?.secureTextFields["Password Field"].tap()
            app?.secureTextFields["Password Field"].typeText("DoctorsNote1@")
            app?.staticTexts["Account Label"].tap()
            
            app?.buttons["Log In"].tap()
        }
        
        // Check no entries filled
        forwardButton.tap()
        // Make sure we haven't move on to the next view
        XCTAssert(errorLabel.label != "")
        
        // Check entries filled
        firstNameField.tap()
        firstNameField.typeText("First")
        
        middleNameField.tap()
        middleNameField.typeText("Middle")
        
        lastNameField.tap()
        lastNameField.typeText("Last")
        
        DOBButton.tap()
        closeButton.tap()
        
        app?.swipeUp()
        
        sexButton.tap()
        closeButton.tap()
        
        phoneField.tap()
        phoneField.typeText("1234567890")
        
        cityField.tap()
        cityField.typeText("City")
        
        stateButton.tap()
        app?.cells.element(boundBy: 0).tap()
        
        zipField.tap()
        zipField.typeText("12345")
        
        // Hide keyboard
        app?.staticTexts["City"].tap()
        
        forwardButton.tap()
    }
    
    func testEmptyCity() {
        let firstNameField = app!.textFields["First Name Field"]
        let middleNameField = app!.textFields["Middle Name Field"]
        let lastNameField = app!.textFields["Last Name Field"]
        let DOBButton = app!.buttons["DOB Button"]
        let sexButton = app!.buttons["Sex Button"]
        let phoneField = app!.textFields["Phone Field"]
        let streetField = app!.textFields["Street Field"]
        let cityField = app!.textFields["City Field"]
        let stateButton = app!.buttons["State Button"]
        let zipField = app!.textFields["ZIP Field"]
        let closeButton = app!.buttons["Close Button"]
        let forwardButton = app!.buttons["Forward"]
        let errorLabel = app!.staticTexts["Error Label"]
        
        if (app!.textFields["Email Field"].exists) {
            app?.textFields["Email Field"].tap()
            app?.textFields["Email Field"].typeText("bbh@purdue.edu")
            
            app?.secureTextFields["Password Field"].tap()
            app?.secureTextFields["Password Field"].typeText("DoctorsNote1@")
            app?.staticTexts["Account Label"].tap()
            
            app?.buttons["Log In"].tap()
        }
        
        // Check no entries filled
        forwardButton.tap()
        // Make sure we haven't move on to the next view
        XCTAssert(errorLabel.label != "")
        
        // Check entries filled
        firstNameField.tap()
        firstNameField.typeText("First")
        
        middleNameField.tap()
        middleNameField.typeText("Middle")
        
        lastNameField.tap()
        lastNameField.typeText("Last")
        
        DOBButton.tap()
        closeButton.tap()
        
        app?.swipeUp()
        
        sexButton.tap()
        closeButton.tap()
        
        phoneField.tap()
        phoneField.typeText("1234567890")
        
        streetField.tap()
        streetField.typeText("Street")
        
        stateButton.tap()
        app?.cells.element(boundBy: 0).tap()
        
        zipField.tap()
        zipField.typeText("12345")
        
        // Hide keyboard
        app?.staticTexts["City"].tap()
        
        forwardButton.tap()
    }
    
    func tryLogout() {
        if (app!.buttons["Log Out"].exists && app!.buttons["Log Out"].isHittable) {
            app?.buttons["Log Out"].tap()
        }
    }
    
}
