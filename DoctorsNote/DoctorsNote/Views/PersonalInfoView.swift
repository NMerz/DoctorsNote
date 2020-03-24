//
//  PersonalInfoView.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSCognito
import AWSMobileClient

class PersonalInfoView: UIView {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var DOBLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var hospitalLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PersonalInfoView", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backgroundView.backgroundColor = UIColor.white
        self.emailLabel.text = CognitoHelper.user?.getEmail()
        self.phoneLabel.text = CognitoHelper.user?.getPhoneNumber()
        self.DOBLabel.text = CognitoHelper.user?.getDateOfBirthString()
        self.addressLabel.text = CognitoHelper.user?.getAddress()
        self.sexLabel.text = CognitoHelper.user?.getSex()
        self.hospitalLabel.text = CognitoHelper.user?.getHealthSystems()[0].getHospital()
        self.providerLabel.text = CognitoHelper.user?.getHealthSystems()[0].getHealthcareProvider()
    }
    
    @IBAction func goToHospitalWebsite(_ sender: Any) {
        if let url = URL(string: (CognitoHelper.user?.getHealthSystems()[0].getHospitalWebsite())!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func goToHealthcareWebsite(_ sender: Any) {
        if let url = URL(string: (CognitoHelper.user?.getHealthSystems()[0].getHealthcareWebsite())!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
