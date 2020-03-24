//
//  HealthSystem.swift
//  DoctorsNote
//
//  Created by Nathan Merz on 2/19/20.
//  Copyright © 2020 Nathan Merz. All rights reserved.
//

import Foundation

class HealthSystem {
    
    var hospital: String
    var hospitalWebsite: String
    var healthcareProvider: String
    var healthcareWebsite: String
    
    init(hospital: String, hospitalWebsite: String, healthcareProvider: String, healthcareWebsite: String) {
        self.hospital = hospital
        self.hospitalWebsite = hospitalWebsite
        self.healthcareProvider = healthcareProvider
        self.healthcareWebsite = healthcareWebsite
    }
    
    func getHospital() -> String {
        return hospital
    }
    
    func getHospitalWebsite() -> String {
        return hospitalWebsite
    }
    
    func getHealthcareProvider() -> String {
        return healthcareProvider
    }
    
    func getHealthcareWebsite() -> String {
        return healthcareWebsite
    }
    
}
