//
//  TestDeleteUser.swift
//  DoctorsNoteUITests
//
//  Created by Sanjana Koka on 4/12/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import XCTest

class TestDeleteUser: XCTestCase {

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
        //tryLogout()
    }

    func testDeleteButton() {
        tryLogin()
        
        XCTAssert(app!.navigationBars.buttons["Log Out"].exists)
    }
    
    func tryLogin() {
       let emailField = app!.textFields["Email Field"]
       let passwordField = app!.secureTextFields["Password Field"]
           
        if (emailField.exists && emailField.isHittable) {
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
