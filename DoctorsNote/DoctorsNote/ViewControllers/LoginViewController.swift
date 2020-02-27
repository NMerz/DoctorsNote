//
//  LoginViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/15/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import UIKit
import AWSCognito
import AWSMobileClient

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var passwordField: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: loginButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        loginButton.layer.mask = mask

    }
    
    @IBAction func login(_ sender: Any) {
        let emailEmpty = emailField.isEmpty()
        let emailValid = emailField.isValidEmail()
        let passwordEmpty = passwordField.isEmpty()
        
        if (emailEmpty || passwordEmpty || !emailValid) {
            return
        }
        
        if (!AWSMobileClient.default().isSignedIn) {
            AWSMobileClient.default().signIn(username: emailField.text!, password: passwordField.text!) { (result, err) in
                if let err = err as? AWSMobileClientError {
                    print("\(err.message)")
                    return
                } else {
                    print("user signed in ")
                }
            
            }
        }
        
        self.performSegue(withIdentifier: "go_to_main", sender: self)
    
    }
    

}
