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
    public static var user: User?
    
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
                        CognitoHelper.user = User(uid: Int(dict!["custom:userID"]!)!, dict: dict!)
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
            // Checks if the user's information is initialized
            if let _ = dict!["name"] {
                // Needs to set up profile. Should to go create profile screen
                CognitoHelper.user = User(uid: Int(dict!["custom:userID"]!)!, dict: dict!)
                onDone(true)
            } else {
                onDone(false)
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        return AWSMobileClient.default().isSignedIn
    }
    
    func resetPassword() {
        
    }

    func getWorkHours(doctor: User, onDone: @escaping (_ success: Bool, _ message: String)->Void) {
        // Check if user is doctor
        //onDone("", NSError(domain: "Error: Requested user is not a doctor.", code: 1, userInfo: [:]))
        // Get doctor's work hours
        AWSMobileClient.default().getUserAttributes { (attr, err) in
            if let err = err as? AWSMobileClientError {
                onDone(false, err.message)
            } else {
                if let hours = attr!["custom:work_hours"] {
                    onDone(true, hours)
                } else {
                    onDone(false, "Error: Cannot get work hours attribute.")
                }
            }
        }
    }
    
    func updateWorkHours(doctor: User, workHours: String, onDone: @escaping (_ success: Bool, _ errMessage: String)->Void) {
        // Check if user is a doctor
        
        // Set work hours
        AWSMobileClient.default().updateUserAttributes(attributeMap: ["custom:work_hours" : workHours]) { (details, err) in
            if let err = err as? AWSMobileClientError {
                onDone(false, err.message)
            } else {
                onDone(true, "")
            }
        }
    }
    
    func setUserRole(role:String, onDone: @escaping (_ success: Bool, _ errMessage: String)->Void) {
        // Check if user is valid
        
        // Set user role
        AWSMobileClient.default().updateUserAttributes(attributeMap: ["custom:role":role]) { (details, err) in
            if let err = err as? AWSMobileClientError {
                onDone(false, err.message)
            } else {
                onDone(true, "")
            }
        }
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
