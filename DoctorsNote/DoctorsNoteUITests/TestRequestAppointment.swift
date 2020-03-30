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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        self.app = XCUIApplication()
        app?.launch()
        app?.activate()
        
        tryLogout()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        tryLogout()
    }

    func testDoctorProfile() throws {
        tryLogin()
//        XCUIApplication().tables["Dropdown"]/*@START_MENU_TOKEN@*/.staticTexts["test convo"]/*[[".cells.staticTexts[\"test convo\"]",".staticTexts[\"test convo\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        
//        app?.tabBars.buttons["Profile"].tap()
//        sleep(1)
////        app?.collectionViews.cells.element(boundBy: 0).tap()
////        sleep(1)
//        app?.buttons["Calendar"].tap()
//        sleep(1);
//        app?.buttons["AddRequest"].tap()
//        sleep(1);
//        app?.buttons["Select Doctor"].tap()
//        let tableView = app?.tables.containing(.table, identifier: "Dropdown")
//        let firstCell = tableView!.cells.element(boundBy: 0)
//        firstCell.tap()
        
        
//        XCTAssert(app!.staticTexts["Work Hours Label"].exists)
    }
    
    func tryLogin() {
        let emailField = app!.textFields["Email Field"]
        let passwordField = app!.secureTextFields["Password Field"]
        
        emailField.tap()
        emailField.typeText("hardin30@purdue.edu")
        
        passwordField.press(forDuration: 1.1)
        passwordField.typeText("DoctorsNote1@")
        app?.buttons["Log In"].tap()
        sleep(2)
        XCTAssertFalse(app!.buttons["Log In"].isHittable)
    }
    
    func tryLogout() {
        if (app!.buttons["Log Out"].exists) {
            app?.buttons["Log Out"].tap()
        }
    }

}
