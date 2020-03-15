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
    private let uid: Int
    private var email: String
    private var firstName: String
    private var middleName: String
    private var lastName: String
    private var dateOfBirth: Date
    private var address: String
    private var sex: String
    private var phoneNumber: String
    private var healthSystems: [HealthSystem]
    
    init (uid: Int, email: String, firstName: String, middleName: String, lastName: String, dateOfBirth: Date, address: String, sex: String, phoneNumber: String, healthSystems: [HealthSystem]) {
        self.uid = uid
        self.email = email
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.address = address
        self.healthSystems = healthSystems
        self.sex = sex
        self.phoneNumber = phoneNumber
    }
    
    convenience init! (uid: Int) {
        let connector = Connector()
        let connectionProcessor = ConnectionProcessor(connector: connector)
        let (potentialUser, potentialError) = connectionProcessor.processUser(url: ConnectionProcessor.standardUrl(), uid: uid)
        if (potentialError == nil && potentialUser != nil) {
            let user = potentialUser!
            self.init (uid: uid, email: user.getEmail(), firstName: user.getFirstName(), middleName: user.getMiddleName(), lastName: user.getLastName(), dateOfBirth: user.getDateOfBirth(), address: user.getAddress(), sex: user.getSex(), phoneNumber: user.getPhoneNumber(), healthSystems: user.getHealthSystems())
        }
        //Below this is a temporary mock for functionality
        let user = potentialUser!
        self.init (uid: uid, email: user.getEmail(), firstName: user.getFirstName(), middleName: user.getMiddleName(), lastName: user.getLastName(), dateOfBirth: user.getDateOfBirth(), address: user.getAddress(), sex: user.getSex(), phoneNumber: user.getPhoneNumber(), healthSystems: user.getHealthSystems())
//        return nil
    }
    
    init(uid: Int, dict: [String:String]) {
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
        // FIXME: Placeholder
        self.healthSystems = [HealthSystem()]
    }
    
    func getUID() -> Int {
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
    
    func getHealthSystems() -> [HealthSystem] {
        return healthSystems
    }
}
