//
//  CognitoHelper.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 3/8/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import AWSCognito
import AWSMobileClient

class CognitoHelper {

    public static let sharedHelper = CognitoHelper()
    
    func login(email: String, password: String, onDone: @escaping (_ success: Bool, _ err: AWSMobileClientError)->()) {
        AWSMobileClient.default().signIn(username: email, password: password) { (result, err) in
            if let err = err as? AWSMobileClientError {
                print("\(err.message)")
                onDone(false, err)
                return
            } else {
                AWSMobileClient.default().getUserAttributes { (dict, err) in
                    if let err = err as? AWSMobileClientError {
                        print("\(err.message)")
                        onDone(false, err)
                        return
                    }
                    // Means the user hasn't udpate info yet. This is probably not the best way to do this...
                    let name = dict!["name"]
                    if (name == nil) {
                        // Needs to set up profile. Should to go create profile screen
                        onDone(false, AWSMobileClientError.invalidParameter(message: "Need to set up profile"))
                    } else {
                        onDone(true, AWSMobileClientError.aliasExists(message: "The user exists!"))
                    }
                }
            }
        }
    }
    
    func isUserSetUp(onDone: @escaping (Bool)->Void) {
        AWSMobileClient.default().getUserAttributes { (dict, err) in
            if let err = err as? AWSMobileClientError {
                print("\(err.message)")
                onDone(false)
                return
            }
            // Means the user hasn't udpate info yet. This is probably not the best way to do this...
            let name = dict!["name"]
            if (name == nil) {
                // Needs to set up profile. Should to go create profile screen
                onDone(false)
            } else {
                // TODO: Create new user object/initialize fields?
                onDone(true)
            }
        }
        onDone(true)
    }
    
    func isLoggedIn() -> Bool {
        return AWSMobileClient.default().isSignedIn
    }
    
    func resetPassword() {
        
    }
    
    func setDisplayName(displayName: String, onDone: @escaping (Bool)->Void) {
        AWSMobileClient.default().updateUserAttributes(attributeMap: ["custom:display_name":displayName]) { (details, err) in
            if let err = err as? AWSMobileClientError {
                print(err.message)
                onDone(false)
            } else {
                onDone(true)
            }
        }
    }
    
}
