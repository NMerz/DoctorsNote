//
//  TestRequestAppointment.swift
//  DoctorsNoteUITests
//
//  Created by Ariana Zhu on 3/30/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import XCTest

class TestRequestAppointment: XCTestCase {

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

    func testRequestAppointment() throws {
        tryLogin()
//        XCUIApplication().tables["Dropdown"]/*@START_MENU_TOKEN@*/.staticTexts["test convo"]/*[[".cells.staticTexts[\"test convo\"]",".staticTexts[\"test convo\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
//        let app = app2
        app?.buttons["Calendar"].tap()
        app?.navigationBars["Calendar"].buttons["AddRequest"].tap()
        app?.buttons["Select Doctor"].tap()
        
//        let app2 = app
        app?.tables["Dropdown"]/*@START_MENU_TOKEN@*/.staticTexts["Agent Anderson"]/*[[".cells.staticTexts[\"Agent Anderson\"]",".staticTexts[\"Agent Anderson\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(1)
        app?.textFields["Select date and time"].tap()
        sleep(1)
        app?.datePickers/*@START_MENU_TOKEN@*/.pickerWheels["Today"]/*[[".pickers.pickerWheels[\"Today\"]",".pickerWheels[\"Today\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
//        app?.datePickers.pickerWheels["AM"].swipeUp()
        sleep(1)
        app?.textFields["Enter details here"].tap()
        app?.textFields["Enter details here"].typeText("test description")
        sleep(1)
        app?.buttons["Submit Appointment Request"].tap()
        sleep(1)
        XCUIApplication().buttons["Back to Calendar"].tap()
    }
    
    func testAppleCalendarExport() {
        tryLogin()
        app?.buttons["Calendar"].tap()
        app?.buttons["Pending"].tap()
        app?.tables.cells.element(boundBy: 0).swipeLeft()
        app?.buttons["Export"].tap()
        app?.buttons["Apple Calendar Button"].tap()
        app?.navigationBars.buttons.element(boundBy: 0).tap()
        
    }
    
    func testGoogleCalendarExport() {
        tryLogin()
        app?.buttons["Calendar"].tap()
        app?.buttons["Pending"].tap()
        app?.tables.cells.element(boundBy: 0).swipeLeft()
        app?.buttons["Export"].tap()
        app?.buttons["Google Calendar Button"].tap()
        
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
