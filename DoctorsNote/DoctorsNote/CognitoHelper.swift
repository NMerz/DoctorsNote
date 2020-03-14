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
    
    func getWorkHours(doctor: User, onDone: @escaping (String, Error)->Void) {
        // Check if user is doctor
        //onDone("", NSError(domain: "Error: Requested user is not a doctor.", code: 1, userInfo: [:]))
        // Get doctor's work hours
        AWSMobileClient.default().getUserAttributes { (attr, err) in
            if let err = err {
                onDone((err as? AWSMobileClientError)!.message, err)
            } else {
                if let hours = attr!["custom:work_hours"] {
                    onDone(hours, NSError(domain: "", code: 0, userInfo: [:]))
                } else {
                    onDone("Error: Cannot get work hours attribute.", NSError(domain: "", code: 1, userInfo: [:]))
                }
            }
        }
    }
    
    func updateWorkHours(doctor: User, onDone: @escaping (Bool)->Void) {
        // Check if user is a doctor
        
        // Set work hours
        AWSMobileClient.default().updateUserAttributes(attributeMap: <#T##[String : String]#>, completionHandler: <#T##(([UserCodeDeliveryDetails]?, Error?) -> Void)##(([UserCodeDeliveryDetails]?, Error?) -> Void)##([UserCodeDeliveryDetails]?, Error?) -> Void#>)
    }
    
}
