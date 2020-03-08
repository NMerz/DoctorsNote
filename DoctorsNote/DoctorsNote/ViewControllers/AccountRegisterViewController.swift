//
//  AccountRegisterViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 3/8/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import PopupKit
import AWSCognito
import AWSMobileClient

//
//
//
class AccountRegisterViewController: UIViewController {
    
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var passwordField: CustomTextField!
    @IBOutlet weak var confirmField: CustomTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var p: PopupView?
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        super.viewDidLoad()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        // TODO: REMOVE LATER
        AWSMobileClient.default().signOut()
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goForward(_ sender: Any) {
        if (fieldsCorrect()) {
            self.activityIndicator.startAnimating()
            // Sign up user with attributes to be added in the next controller
            AWSMobileClient.default().signUp(username: emailField.text!, password: passwordField.text!, userAttributes: ["name":"", "middle_name":"", "family_name":"", "gender":"", "birthdate":"", "address":"", "phone_number":""]) { (res, err) in
                if let err = err as? AWSMobileClientError {
                    switch err {
                    case .usernameExists, .invalidPassword:
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.errorLabel.text = "Error: " + err.message
                        }
                        return
                    default:
                        print("\(err.message)")
                    }
                }
                DispatchQueue.main.async {
                    self.errorLabel.text = ""
                    self.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "show_verification", sender: self)
                    return
                }
            }
        }
    }
    
    func showPopup(_ message: String) {
        let width : Int = Int(self.view.frame.width - 20)
        let height = 200

        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        contentView.backgroundColor = UIColor.white
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 38.5).cgPath
        contentView.layer.mask = maskLayer

        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed

        let label = UILabel(frame: CGRect(x: 20, y: 20, width: width - 40, height: 100))
        label.text = message
        label.numberOfLines = 5

        let closeButton = UIButton(frame: CGRect(x: width/2 - 45, y: height - 75, width: 90, height: 40))
        closeButton.setTitle("Done", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        closeButton.layer.mask = layer
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)

        contentView.addSubview(closeButton)
        contentView.addSubview(label)

        let xPos = self.view.frame.width / 2
        let yPos = self.view.frame.height - (CGFloat(height) / 2) - 10
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: self.navigationController!.view)
    }
        
    func fieldsCorrect() -> Bool {
        let emailEmpty = emailField.isEmpty()
        let emailValid = emailField.isValidEmail()
        let passwordEmpty = passwordField.isEmpty()
        let confirmEmpty = confirmField.isEmpty()
        let passwordsEqual = (passwordField.text! == confirmField.text!)
        if (passwordsEqual) {
            errorLabel.text = ""
        } else {
            errorLabel.text = "Error: Password entries do not match."
        }
        
        return (!emailEmpty && !passwordEmpty && !confirmEmpty && emailValid && passwordsEqual)
    }
    
    @objc func dismissPopup(sender: UIButton!) {
        p?.dismissType = .slideOutToBottom
        p?.dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! ConfirmAccountViewController
        nextVC.email = emailField.text!
    }
    
    @IBAction func hasCode(_ sender: Any) {
        self.performSegue(withIdentifier: "show_verification", sender: self)
    }
    

}









class ConfirmAccountViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var codeField: CustomTextField!
    @IBOutlet weak var createButton: UIButton!
    
    var email: String?
    var p: PopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        if (email != "") {
            emailLabel.isHidden = true
            emailField.isHidden = true
            
            emailLabel.isEnabled = false
            emailField.isEnabled = false
        }
        
        let requestLayer = CAShapeLayer()
        requestLayer.path = UIBezierPath(roundedRect: createButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        createButton.layer.mask = requestLayer
        
    }
    
    @IBAction func createUser(_ sender: Any) {
        // Verify code
            
        var emailEmpty = true
        var emailValid = false
        if (email == "") {
            // Email has not been passed to this controller
            email = emailField.text!
            emailEmpty = emailField.isEmpty()
            emailValid = emailField.isValidEmail()
        } else {
            emailEmpty = false
            emailValid = true
        }
        
        let codeEmpty = codeField.isEmpty()
        
        if (emailEmpty) {
            self.errorLabel.textColor = UIColor.systemRed
            self.errorLabel.text = "Error: Please enter an email."
            return
        }
        else if (!emailValid) {
            self.errorLabel.textColor = UIColor.systemRed
            self.errorLabel.text = "Error: Please enter an email in the correct format."
            return
        }
        else if (codeEmpty) {
            self.errorLabel.textColor = UIColor.systemRed
            self.errorLabel.text = "Error: Please enter a verification code."
            return
        }
        self.errorLabel.textColor = UIColor.black
        self.errorLabel.text = "Enter the verification code emailed to you below."
        
        AWSMobileClient.default().confirmSignUp(username: email!, confirmationCode: codeField.text!) { (res, err) in
            if let err = err as? AWSMobileClientError {
                DispatchQueue.main.async {
                    self.errorLabel.textColor = UIColor.systemRed
                    self.errorLabel.text = err.message
                }
            } else {
                DispatchQueue.main.async {
                    self.showPopup()
                }
            }
        }
    }
    
    func showPopup() {
        let width : Int = Int(self.view.frame.width - 20)
        let height = 200

        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        contentView.backgroundColor = UIColor.white
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 38.5).cgPath
        contentView.layer.mask = maskLayer

        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed

        let label = UILabel(frame: CGRect(x: 20, y: 20, width: width - 40, height: 100))
        label.text = "Account has been created! Sign in to finish setting up your profile."
        label.numberOfLines = 5

        let closeButton = UIButton(frame: CGRect(x: width/2 - 45, y: height - 75, width: 90, height: 40))
        closeButton.setTitle("Done", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        closeButton.layer.mask = layer
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)

        contentView.addSubview(closeButton)
        contentView.addSubview(label)

        let xPos = self.view.frame.width / 2
        let yPos = self.view.frame.height - (CGFloat(height) / 2) - 10
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: self.navigationController!.view)
    }
        
    @objc func dismissPopup(sender: UIButton!) {
        p?.dismissType = .slideOutToBottom
        p?.dismiss(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
