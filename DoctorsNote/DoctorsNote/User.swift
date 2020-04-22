//
//  User.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/19/20.
//  Copyright © 2020 Nathan Merz. All rights reserved.
//

import Foundation
import AWSMobileClient
import AWSCognito

class User {
    private let uid: String
    private var email: String
    private var firstName: String
    private var middleName: String
    private var lastName: String
    private var dateOfBirth: Date
    private var address: String
    private var sex: String
    private var phoneNumber: String
    private var role: String
    private var healthSystems: [HealthSystem]
    private var workHours: String
    
    private var securityQuestion: String
    private var securityAnswer: String

    
    init (uid: String, email: String, firstName: String, middleName: String, lastName: String, dateOfBirth: Date, address: String, sex: String, phoneNumber: String, role: String, healthSystems: [HealthSystem], workHours: String, securityQuestion: String, securityAnswer: String) {
        self.uid = uid
        self.email = email
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.address = address
        self.role = role
        self.healthSystems = healthSystems
        self.sex = sex
        self.phoneNumber = phoneNumber
        self.workHours = workHours
        self.securityQuestion = securityQuestion
        self.securityAnswer = securityAnswer
    }
    
    convenience init! (uid: String) {
        let connector = Connector()
        let connectionProcessor = ConnectionProcessor(connector: connector)
        let (potentialUser, potentialError) = connectionProcessor.processUser(url: ConnectionProcessor.standardUrl(), uid: uid)
        if (potentialError == nil && potentialUser != nil) {
            let user = potentialUser!
            self.init (uid: uid, email: user.getEmail(), firstName: user.getFirstName(), middleName: user.getMiddleName(), lastName: user.getLastName(), dateOfBirth: user.getDateOfBirth(), address: user.getAddress(), sex: user.getSex(), phoneNumber: user.getPhoneNumber(), role: user.getRole(), healthSystems: user.getHealthSystems(), workHours: user.getWorkHours(), securityQuestion: user.getSecurityQuestion(), securityAnswer: user.getSecurityAnswer())
        }
        //Below this is a temporary mock for functionality
        let user = potentialUser!
        self.init (uid: uid, email: user.getEmail(), firstName: user.getFirstName(), middleName: user.getMiddleName(), lastName: user.getLastName(), dateOfBirth: user.getDateOfBirth(), address: user.getAddress(), sex: user.getSex(), phoneNumber: user.getPhoneNumber(), role: user.getRole(), healthSystems: user.getHealthSystems(), workHours: user.getWorkHours(), securityQuestion: user.getSecurityQuestion(), securityAnswer: user.getSecurityAnswer())
//        return nil
    }
    
    init(uid: String, dict: [String:String]) {
        self.uid = uid
        self.email = dict["email"]!
        self.firstName = dict["name"]!
        if let middleName = dict["middle_name"] {
            self.middleName = middleName
        } else {
            self.middleName = ""
        }
        self.lastName = dict["family_name"]!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        self.dateOfBirth = dateFormatter.date(from: dict["birthdate"]!)!
        self.address = dict["address"]!
        self.sex = dict["gender"]!
        self.phoneNumber = dict["phone_number"]!
        self.role = dict["custom:role"]!
        let hospital = dict["custom:hospital"]!
        let hospitalWebsite = dict["custom:hospital_website"]!
        let healthcareProvider = dict["custom:healthcare_provider"]!
        let healthcareWebsite = dict["custom:healthcare_website"]!
        let system = HealthSystem(hospital: hospital, hospitalWebsite: hospitalWebsite, healthcareProvider: healthcareProvider, healthcareWebsite: healthcareWebsite)
        self.healthSystems = [system]
        if let hours = dict["custom:work_hours"] {
            self.workHours = hours
        } else {
            self.workHours = "" 
        }
        self.securityQuestion = dict["custom:securityquestion2"]!
        self.securityAnswer = dict["custom:securityanswer"]!
    }
    
    func getUID() -> String {
        return uid
    }
    
    func getEmail() -> String {
        return email
    }
    
    func getFirstName() -> String {
        return firstName
    }
    
    func getMiddleName() -> String {
        return middleName
    }
    
    func getLastName() -> String {
        return lastName
    }
    
    func getDateOfBirth() -> Date {
        return dateOfBirth
    }
    
    func getDateOfBirthString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: dateOfBirth)
    }
    
    func getAddress() -> String {
        return address
    }
    
    func getSex() -> String {
        return sex
    }
    
    func getPhoneNumber() -> String {
        return phoneNumber
    }
    
    func getRole() -> String {
        return role
    }
    
    func getHealthSystems() -> [HealthSystem] {
        return healthSystems
    }
    
    func getWorkHours() -> String {
        return workHours
    }
    
    func getSecurityQuestion() -> String {
        return securityQuestion
    }
    
    func getSecurityAnswer() -> String {
        return securityAnswer
    }
    
    func setEmail(email: String) {
        self.email = email
    }
    
    func setFirstName(firstName: String) {
        self.firstName = firstName
    }
    
    func setMiddleName(middleName: String) {
        if (middleName == "<empty>") {
            self.middleName = ""
        } else {
            self.middleName = middleName
        }
    }
    
    func setLastName(lastName: String) {
        self.lastName = lastName
    }
    
    func setSex(sex: String) {
        self.sex = sex
    }
    
    func setDOB(DOB: String) {
        self.dateOfBirth = convertDOBStringToDate(DOB: DOB)
    }
    
    func setAddress(address: String) {
        self.address = address
    }
    
    func setPhoneNumber(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    func convertDOBStringToDate(DOB: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: DOB)!
    }
    
    func setRole(role: String) {
        self.role = role
    }
    
    func setHealthSystem(hospital: String, hospitalWebsite: String, healthcareProvider: String, healthcareWebsite: String) {
        self.healthSystems = [HealthSystem(hospital: hospital, hospitalWebsite: hospitalWebsite, healthcareProvider: healthcareProvider, healthcareWebsite: healthcareWebsite)]
    }
    
    func setWorkHours(workHours: String) {
        self.workHours = workHours
    }
    
    func setSecurityQuestion(securityQuestion: String) {
        self.securityQuestion = securityQuestion
    }
    
    func setSecurityAnswer(securityAnswer: String) {
        self.securityAnswer = securityAnswer
    }
    
}
