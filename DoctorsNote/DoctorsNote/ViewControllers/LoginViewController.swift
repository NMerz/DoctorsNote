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
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (CognitoHelper.sharedHelper.isLoggedIn()) {
            decideNextController()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: loginButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        loginButton.layer.mask = mask
        

        let tap = UITapGestureRecognizer(target:self.view,action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func login(_ sender: Any) {
        
        let emailEmpty = emailField.isEmpty()
        let emailValid = emailField.isValidEmail()
        let passwordEmpty = passwordField.isEmpty()
        
        if (emailEmpty) {
            errorLabel.text = "Error: Please enter an email."
            return
        }
        else if (!emailValid) {
            errorLabel.text = "Error: Please enter email in the correct format."
            return
        }
        else if (passwordEmpty) {
            errorLabel.text = "Error: Please enter a password."
            return
        }
        errorLabel.text = ""
        
        let defaults = UserDefaults.standard
        defaults.set(passwordField.text!, forKey: "newPassword")
        CognitoHelper.sharedHelper.login(email: emailField.text!, password: passwordField.text!) { (success, err) -> (Void) in
            if (!success) {
                DispatchQueue.main.async {
                    self.errorLabel.text = err.message
                }
            } else {
                self.decideNextController()
            }
            
        }
        
    
    }
    
    func decideNextController() {
        CognitoHelper.sharedHelper.isUserSetUp { (setUp) in
            if (setUp) {
                DispatchQueue.main.async {
                    // User has all properties set
                    self.performSegue(withIdentifier: "go_to_main", sender: self)
                }
            } else {
                DispatchQueue.main.async {
                    // User needs to finish creating profile
                    self.performSegue(withIdentifier: "show_profile_setup", sender: self)
                }
            }
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}

// Inspired by: https://stackoverflow.com/questions/30794076/correct-way-of-removing-deleting-a-view-viewcontroller-from-the-stack-after-se
class ManualSegue: UIStoryboardSegue {

  override func perform() {
    source.present(destination, animated: true) {
        self.source.navigationController!.popToRootViewController(animated: false)
        UIApplication.shared.delegate?.window??.rootViewController = self.destination.navigationController
    }
  }
}

class LoginNavController: UINavigationController {
    
}
