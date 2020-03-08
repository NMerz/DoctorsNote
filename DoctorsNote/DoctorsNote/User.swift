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
    private var firstName: String
    private var lastName: String
    private var dateOfBirth: Date
    private var address: String
    private var healthSystems: [HealthSystem]
    
    init (uid: Int, firstName: String, lastName: String, dateOfBirth: Date, address: String, healthSystems: [HealthSystem]) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.address = address
        self.healthSystems = healthSystems
    }
    
    convenience init! (uid: Int) {
        let connector = Connector()
        let connectionProcessor = ConnectionProcessor(connector: connector)
        let (potentialUser, potentialError) = connectionProcessor.processUser(url: ConnectionProcessor.standardUrl(), uid: uid)
        if (potentialError == nil && potentialUser != nil) {
            let user = potentialUser!
            self.init (uid: uid, firstName: user.getFirstName(), lastName: user.getLastName(), dateOfBirth: user.getDateOfBirth(), address: user.getAddress(), healthSystems: user.getHealthSystems())
        }
        //Below this is a temporary mock for functionality
        let user = potentialUser!
        self.init (uid: uid, firstName: user.getFirstName(), lastName: user.getLastName(), dateOfBirth: user.getDateOfBirth(), address: user.getAddress(), healthSystems: user.getHealthSystems())
//        return nil
    }
    
    func getUID() -> Int {
        return uid
    }
    
    func getFirstName() -> String {
        return firstName
    }
    
    func getLastName() -> String {
        return lastName
    }
    
    func getDateOfBirth() -> Date {
        return dateOfBirth
    }
    
    func getAddress() -> String {
        return address
    }
    
    func getHealthSystems() -> [HealthSystem] {
        return healthSystems
    }
}
