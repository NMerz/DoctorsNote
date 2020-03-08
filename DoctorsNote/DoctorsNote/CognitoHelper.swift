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
    
    func login(email: String, password: String, onDone: @escaping (AWSMobileClientError)->(Void)) {
        var error : AWSMobileClientError?
        AWSMobileClient.default().signIn(username: email, password: password) { (result, err) in
            if let err = err as? AWSMobileClientError {
                print("\(err.message)")
                error = err
                onDone(error!)
                return
            } else {
                AWSMobileClient.default().getUserAttributes { (dict, err) in
                    if let err = err as? AWSMobileClientError {
                        print("\(err.message)")
                        error = err
                        onDone(error!)
                        return
                    }
                    // Means the user hasn't udpate info yet. This is probably not the best way to do this...
                    let name = dict!["name"]
                    if (name == nil) {
                        // Needs to set up profile. Should to go create profile screen
                    } else {
                        // TODO: Create new user object/initialize fields?
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
    
}
