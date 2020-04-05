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
    public static var numFails: Int = 0
    
    func login(email: String, password: String, onDone: @escaping (_ success: Bool, _ err: AWSMobileClientError)->()) {
        AWSMobileClient.default().signIn(username: email, password: password) { (result, err) in
            if let err = err as? AWSMobileClientError {
                print("\(err.message)")
                onDone(false, err)
                return
            } else {
                onDone(true, AWSMobileClientError.aliasExists(message: "The user exists!"))
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
            if let _ = dict!["custom:healthcare_provider"] {
                // Needs to set up profile. Should to go create profile screen
                CognitoHelper.user = User(uid: AWSMobileClient.default().username!, dict: dict!)
                onDone(true)
            } else {
                CognitoHelper.user = User(uid: AWSMobileClient.default().username!)
                onDone(false)
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        return AWSMobileClient.default().isSignedIn
    }
    
    func logout() {
        AWSMobileClient.default().signOut()
        // Clear old user
        CognitoHelper.user = User(uid: "-1")
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
    
    func updateAttributes(attributeMap: [String:String], onDone: @escaping (_ success: Bool, _ errMessage: String)->Void) {
        AWSMobileClient.default().updateUserAttributes(attributeMap: attributeMap) { (details, err) in
            if let err = err as? AWSMobileClientError {
                onDone(false, err.message)
            } else {
                onDone(true, "")
            }
        }
        if let name = attributeMap["name"] {
            CognitoHelper.user?.setFirstName(firstName: name)
        }
        if let middleName = attributeMap["middle_name"] {
            CognitoHelper.user?.setMiddleName(middleName: middleName)
        }
        if let lastName = attributeMap["family_name"] {
            CognitoHelper.user?.setLastName(lastName: lastName)
        }
        if let lastName = attributeMap["family_name"] {
            CognitoHelper.user?.setLastName(lastName: lastName)
        }
        if let sex = attributeMap["gender"] {
            CognitoHelper.user?.setSex(sex: sex)
        }
        if let DOB = attributeMap["birthdate"] {
            CognitoHelper.user?.setDOB(DOB: DOB)
        }
        if let address = attributeMap["address"] {
            CognitoHelper.user?.setAddress(address: address)
        }
        if let phoneNumber = attributeMap["phone_number"] {
            CognitoHelper.user?.setPhoneNumber(phoneNumber: phoneNumber)
        }
        if let email = attributeMap["email"] {
            CognitoHelper.user?.setEmail(email: email)
        }
    }
    
    func setHealthcareInformation(role:String, hospital:String, hospitalWebsite: String, healthcareProvider: String, healthcareWebsite:String, onDone: @escaping (_ success: Bool, _ errMessage: String)->Void) {
        // Check if user is valid
        
        // Set user role
        let map = ["custom:role":role, "custom:hospital":hospital, "custom:hospital_website":hospitalWebsite, "custom:healthcare_provider":healthcareProvider, "custom:healthcare_website":healthcareWebsite]
        AWSMobileClient.default().updateUserAttributes(attributeMap: map) { (details, err) in
            if let err = err as? AWSMobileClientError {
                onDone(false, err.message)
            } else {
                onDone(true, "")
            }
        }
        CognitoHelper.user?.setHealthSystem(hospital: hospital, hospitalWebsite: hospitalWebsite, healthcareProvider: healthcareProvider, healthcareWebsite: healthcareWebsite)
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
