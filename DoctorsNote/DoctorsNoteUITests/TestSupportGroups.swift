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
        tryLogout()
    }

    func testJoinPrompts() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        tryLogin()
        
        // Navigate to support groups page
        app?.tabBars.buttons["Support Groups"].tap()
        app?.buttons["Search Icon"].tap()
        app?.tables.cells.element(boundBy: 0).buttons["Information Icon"].tap()
        app?.buttons["Join Button"].tap()
        sleep(4)
        app?.alerts.textFields["Display Name Field"].tap()
        app?.alerts.textFields["Display Name Field"].typeText("Test Display Name")
        app?.alerts.buttons["Set Name Button"].tap()
        sleep(4)
        app?.alerts.buttons["Ok Button"].tap()
        app?.tabBars.buttons["Profile"].tap()
    }
    
    func testSearchSupportGroups() {
        tryLogin()
        app?.tabBars.buttons["Support Groups"].tap()
        app?.buttons["Search Icon"].tap()
        app?.tables.cells.element(boundBy: 0).buttons["Information Icon"].tap()
    }
    
    func testDisplayNameOnJoin() {
        tryLogin()
        app?.tabBars.buttons["Support Groups"].tap()
        app?.buttons["Search Icon"].tap()
        app?.tables.cells.element(boundBy: 0).buttons["Information Icon"].tap()
        XCTAssertTrue(app!.staticTexts["Name Label"].exists)
    }
    
    func testDisplayDescriptionOnJoin() {
        tryLogin()
        app?.tabBars.buttons["Support Groups"].tap()
        app?.buttons["Search Icon"].tap()
        app?.tables.cells.element(boundBy: 0).buttons["Information Icon"].tap()
        XCTAssertTrue(app!.staticTexts["Description Label"].exists)
    }

    func testDisplayMembersOnJoin() {
        tryLogin()
        app?.tabBars.buttons["Support Groups"].tap()
        app?.buttons["Search Icon"].tap()
        app?.tables.cells.element(boundBy: 0).buttons["Information Icon"].tap()
        XCTAssertTrue(app!.staticTexts["Member Label"].exists)
    }
    
    func testDeleteSupportGroupMessage() {
        tryLogin()
        app?.tabBars.buttons["Support Groups"].tap()
        sleep(1)
        app?.collectionViews.cells.element(boundBy: 0).tap()
        sleep(1)
        app?.collectionViews.cells.element(boundBy: 0).press(forDuration: 2)
        app?.menuItems["Delete"].tap()
    }
    
    func testDisplayInformation() {
        tryLogin()
        app?.tabBars.buttons["Support Groups"].tap()
        sleep(1)
        app?.collectionViews.cells.element(boundBy: 0).tap()
        sleep(1)
        app?.buttons["Info Button"].tap()
        XCTAssertTrue(app!.staticTexts["Name Label"].exists)
        XCTAssertTrue(app!.staticTexts["Description Label"].exists)
        XCTAssertTrue(app!.staticTexts["Members Label"].exists)
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
            //XCTAssertFalse(app!.buttons["Log In"].isHittable)
        }
    }
    
    func tryLogout() {
        if (app!.buttons["Log Out"].exists) {
            app?.buttons["Log Out"].tap()
        }
    }

}
