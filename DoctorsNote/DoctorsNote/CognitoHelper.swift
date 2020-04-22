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
    public static var newPassword = ""
    
    init() {
        let defaults = UserDefaults.standard
        CognitoHelper.numFails = Int(defaults.string(forKey: "numFails") ?? "0")!
        print("NUM FAILS: ", CognitoHelper.numFails)
    }
    
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
            // Check if all the user's information is set up.
            CognitoHelper.user = User(uid: AWSMobileClient.default().username!)
            if dict!["name"] == nil {
                onDone(false)
                return
            }
            else if dict!["middle_name"] == nil {
                onDone(false)
                return
            }
            else if dict!["family_name"] == nil {
                onDone(false)
                return
            }
            else if dict!["address"] == nil {
                onDone(false)
            }
            else if dict!["birthdate"] == nil {
                onDone(false)
            }
            else if dict!["gender"] == nil {
                onDone(false)
            }
            else if dict!["phone_number"] == nil {
                onDone(false)
            }
            else if dict!["custom:healthcare_provider"] == nil {
                onDone(false)
            }
            else if dict!["custom:hospital"] == nil {
                onDone(false)
            }
            else if dict!["custom:healthcare_website"] == nil {
                onDone(false)
            }
            else if dict!["custom:hospital_website"] == nil {
                onDone(false)
            }
            else if dict!["custom:role"] == nil {
                onDone(false)
            }
            else if dict!["custom:securityquestion2"] == nil {
                onDone(false)
            }
            else if dict!["custom:securityanswer"] == nil {
                onDone(false)
            }
            else {
                CognitoHelper.user = User(uid: AWSMobileClient.default().username!, dict: dict!)
                onDone(true)
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
    
    func updateAttributes(attributeMap: [String:String], onDone: @escaping (_ success: Bool, _ errMessage: String)->Void) {
        AWSMobileClient.default().updateUserAttributes(attributeMap: attributeMap) { (details, err) in
            if let err = err as? AWSMobileClientError {
                onDone(false, err.message)
            } else {
                onDone(true, "")
                if let name = attributeMap["name"] {
                    CognitoHelper.user?.setFirstName(firstName: name)
                }
                if let middleName = attributeMap["middle_name"] {
                    CognitoHelper.user?.setMiddleName(middleName: middleName)
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
                if let workHours = attributeMap["custom:work_hours"] {
                    CognitoHelper.user?.setWorkHours(workHours: workHours)
                }
                if let securityQuestion = attributeMap["custom:securityquestion2"] {
                    CognitoHelper.user?.setSecurityQuestion(securityQuestion: securityQuestion)
                }
                if let securityAnswer = attributeMap["custom:securityanswer"] {
                    CognitoHelper.user?.setSecurityAnswer(securityAnswer: securityAnswer)
                }
            }
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
        CognitoHelper.user?.setRole(role: role)
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
