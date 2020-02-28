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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        AWSMobileClient.default().getUserAttributes { (attr, err) in
            if let err = err as? AWSMobileClientError {
                
            } else if (attr != nil) {
                DispatchQueue.main.async {
                    self.emailLabel.text = attr!["name"]
                    self.phoneLabel.text = attr!["phone_number"]
                    self.DOBLabel.text = attr!["birthdate"]
                    self.addressLabel.text = attr!["address"]
                    self.sexLabel.text = attr!["gender"]
                    // TODO: ACTUALLY CONNECT TOGETHER
                    self.hospitalLabel.text = "IU Arnett"
                    self.providerLabel.text = "Humana"
                }
            }
            
        }
    }
    
}
