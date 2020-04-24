//
//  EncryptionTests.swift
//  DoctorsNoteTests
//
//  Created by Merz on 4/23/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import Foundation
import XCTest
import AWSMobileClient

// The current user must be set up and logged in
class EncryptionIntegrationTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    //Verify that the private keys, when retrieved are actually encryptedd and cannot be used without decryption
    //NOTE: This is classified as an integration test instead of a unit test because it does not use mocking. Thus, the current user must be set up and logged in to run correctly.
    func testPrivateKeyEncryptedIntegration() {
        let connector = Connector()
        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
        let connectionProcessor = ConnectionProcessor(connector: connector)
        do {
            let (privateKey1, privateKey2, _) = try connectionProcessor.retrieveEncryptedPrivateKeys(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/retrievekeys")
            var unmanagedError: Unmanaged<CFError>? = nil
            let attributes = [ kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: 2048,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
            ] as [CFString : Any]
            var newPrivateKey = SecKeyCreateWithData(Data(base64Encoded: privateKey1)! as CFData, attributes as CFDictionary, UnsafeMutablePointer<Unmanaged<CFError>?>(&unmanagedError))
            XCTAssert(newPrivateKey == nil) //Previous call expected to fail
            newPrivateKey = SecKeyCreateWithData(Data(base64Encoded: privateKey2)! as CFData, attributes as CFDictionary, UnsafeMutablePointer<Unmanaged<CFError>?>(&unmanagedError))
            XCTAssert(newPrivateKey == nil) //Previous call expected to fail
        } catch {
            print("Unable to reach server! Integration test impossible")
            XCTAssert(false)
        }
    }
}
