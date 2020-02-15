//
//  RequestAccountTableViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/15/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import UIKit

class AccountRegisterViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.layer.cornerRadius = DefinedValues.fieldRadius
        emailField.borderStyle = .roundedRect
        //emailField.layer.borderColor = UIColor.blue.cgColor
        //emailField.layer.borderWidth = 2
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

class PersonalRegisterViewController: UIViewController {
    let radius: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
}

class HealthRegisterViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
}
