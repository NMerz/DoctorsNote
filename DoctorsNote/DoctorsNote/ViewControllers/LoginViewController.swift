//
//  LoginViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/15/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: loginButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        loginButton.layer.mask = maskLayer
        
        let emailPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: emailField.frame.height))
        let passwordPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: passwordField.frame.height))
         
        emailField.leftView = emailPadding
        emailField.rightView = emailPadding
        passwordField.leftView = passwordPadding
        passwordField.rightView = passwordPadding
        
        emailField.leftViewMode = .always
        emailField.rightViewMode = .always
        passwordField.leftViewMode = .always
        passwordField.rightViewMode = .always
        
        emailField.layer.borderColor = UIColor.systemBlue.cgColor
        emailField.layer.borderWidth = 2
        passwordField.layer.borderColor = UIColor.systemBlue.cgColor
        passwordField.layer.borderWidth = 2
        
        emailField.layer.cornerRadius = DefinedValues.fieldRadius
        passwordField.layer.cornerRadius = DefinedValues.fieldRadius
    }
    

}
