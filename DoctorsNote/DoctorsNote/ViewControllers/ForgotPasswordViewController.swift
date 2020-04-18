//
//  ForgotPasswordViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/26/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import PopupKit
import AWSCognito
import AWSMobileClient

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var recoverButton: UIButton!
    
    var p: PopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: recoverButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        recoverButton.layer.mask = mask
        
    }
    
    @IBAction func recover(_ sender: Any) {
        
        if (emailField.isEmpty()) {
            return
        }
        
        dismissKeyboard()
        
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
        label.text = "If an account with the specified email exists, an email will sent with a link to reset the password."
        label.numberOfLines = 5

        let closeButton = UIButton(frame: CGRect(x: width/2 - 45, y: height - 75, width: 90, height: 40))
        closeButton.setTitle("Done", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        closeButton.layer.mask = layer
        closeButton.accessibilityLabel = "Close Button"
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
        
        AWSMobileClient.default().forgotPassword(username: emailField!.text!) { (res, err) in
            if let err = err as? AWSMobileClientError {
                print("\(err.message)")
            } else {
                print("Password reset sent")
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! PasswordCodeViewController
        nextVC.email = emailField.text!
    }
    
    @IBAction func hasCode(_ sender: Any) {
        self.performSegue(withIdentifier: "input_code", sender: self)
    }
    
    @objc func dismissPopup() {
        p?.dismissType = .slideOutToBottom
        p?.dismiss(animated: true)
        self.performSegue(withIdentifier: "input_code", sender: self)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}








class PasswordCodeViewController: UIViewController {
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var codeField: CustomTextField!
    @IBOutlet weak var newPasswordField: CustomTextField!
    @IBOutlet weak var confirmField: CustomTextField!
    
    @IBOutlet weak var securityQuestionLabel: UILabel!
    @IBOutlet weak var securityAnswer: CustomTextField!
    
    
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        securityQuestionLabel.text = CognitoHelper.user!.getSecurityQuestion()
        
        if (email != "") {
            emailField.isHidden = true
            emailLabel.isHidden = true
            
            emailField.isEnabled = false
            emailLabel.isEnabled = false
        }
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: resetButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        resetButton.layer.mask = mask
        
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        
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
        let passwordEmpty = newPasswordField.isEmpty()
        let confirmEmpty = confirmField.isEmpty()
        let passwordsEqual = (self.newPasswordField.text! == self.confirmField.text!)
        
        // TODO test this
        let hashedAnswer = self.securityAnswer.text!.hash()
        let securityAnswerMatch = (hashedAnswer == CognitoHelper.user!.getSecurityAnswer())
        
        if (emailEmpty || codeEmpty || passwordEmpty || confirmEmpty || !passwordsEqual || !emailValid || !securityAnswerMatch) {
            return
        }
        
        AWSMobileClient.default().confirmForgotPassword(username: email!, newPassword: newPasswordField.text!, confirmationCode: codeField.text!) { (res, err) in
            if let err = err as? AWSMobileClientError {
                self.errorLabel.textColor = UIColor.systemRed
                self.errorLabel.text = err.message
            } else {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
