//
//  ProfileViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSCognito
import AWSMobileClient

class ProfileViewController: UIViewController {
   
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var personalInfoView: PersonalInfoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logOutButton.semanticContentAttribute = UIApplication.shared
        .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        
        personalInfoView.layer.shadowColor = UIColor.darkGray.cgColor
        personalInfoView.layer.shadowRadius = 5
        personalInfoView.layer.shadowOpacity = 0.5
        personalInfoView.layer.shadowOffset = CGSize.zero
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: personalInfoView.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        
        AWSMobileClient.default().getUserAttributes { (attr, err) in
            if let err = err as? AWSMobileClientError {
                print("\(err.message)")
            }
            else if (attr != nil) {
                DispatchQueue.main.async {
                    self.navigationItem.title = attr!["name"]! + " " + attr!["family_name"]!
                }
            }
        }
        //personalInfoView.layer.mask = mask
        
    }

    @IBAction func logOut(_ sender: Any) {
        
        AWSMobileClient.default().signOut()
    
    }
    
}
