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
                
        if (emailEmpty || codeEmpty || passwordEmpty || confirmEmpty || !passwordsEqual || !emailValid) {
            return
        }
        

        let password = newPasswordField.text!
        
        AWSMobileClient.default().confirmForgotPassword(username: email!, newPassword: password, confirmationCode: codeField.text!) { (res, err) in
            if let err = err as? AWSMobileClientError {
                DispatchQueue.main.async {
                    self.errorLabel.textColor = UIColor.systemRed
                    self.errorLabel.text = err.message
                }
            } else {
                // Login with new password
                    CognitoHelper.sharedHelper.login(email: self.email!, password: password) { (success, err) in
                    if (!success) {
                        if let err = err as? AWSMobileClientError {
                            DispatchQueue.main.async {
                                self.errorLabel.textColor = UIColor.systemRed
                                self.errorLabel.text = err.message
                            }
                        }
                    } else {
                        CognitoHelper.sharedHelper.isUserSetUp { (success) in
                            if (success) {
                                DispatchQueue.main.async {
                                    // Confirm security question
                                    let alertController = UIAlertController(title: "Confirm Security Question", message: CognitoHelper.user!.getSecurityQuestion(), preferredStyle: .alert)
                                    
                                    let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
                                        let response = alertController.textFields![0].text!
                                        let hash = response.my_hash()
                                        let ans = CognitoHelper.user!.getSecurityAnswer()
                                        let answersEqual = (hash == ans)
                                        if (!answersEqual) {
                                            self.displayTryAgain()
                                        } else {
                                            let connector = Connector()
                                            AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
                                            let connectionProcessor = ConnectionProcessor(connector: connector)
                                            do {
                                                let cipher = LocalCipher()
                                                try cipher.resetKeyPair(securityQuestionAnswers: [response], newPassword: self.newPasswordField.text!, username: CognitoHelper.user!.getUID(), connectionProcessor: connectionProcessor)
                                            } catch let error as CipherError {
                                                print(error.getMessage())
                                                return
                                            } catch let error as ConnectionError {
                                                print(error.getMessage())
                                            } catch let error {
                                                print(error.localizedDescription)
                                            }
                                            self.displaySuccess()
                                        }
                                    }
                                    submitAction.accessibilityLabel = "Submit Button"
                                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                    cancelAction.accessibilityLabel = "Cancel Button"
                                    alertController.addAction(submitAction)
                                    alertController.addAction(cancelAction)
                                    submitAction.isEnabled = false
                                    
                                    alertController.addTextField { (textField) in
                                        textField.accessibilityLabel = "Display Name Field"
                                        textField.placeholder = "Enter Display Name"
                                        
                                        // This segment of code borrowed from:
                                        // https://gist.github.com/TheCodedSelf/c4f3984dd9fcc015b3ab2f9f60f8ad51
                                        
                                        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                                            {_ in
                                                // Being in this block means that something fired the UITextFieldTextDidChange notification.
                                                
                                                // Access the textField object from alertController.addTextField(configurationHandler:) above and get the character count of its non whitespace characters
                                                let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                                                let textIsNotEmpty = textCount > 0
                                                
                                                // If the text contains non whitespace characters, enable the OK Button
                                                submitAction.isEnabled = textIsNotEmpty
                                            
                                            })
                                    }
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            } else {
                                self.performSegue(withIdentifier: "go_set_up", sender: self)
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func displayTryAgain() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error: Incorrect security answer.", message: "Please request a new password reset verification code and try again.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            CognitoHelper.sharedHelper.logout()
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func displaySuccess() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Success", message: "Your password was successfully updated!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            CognitoHelper.sharedHelper.logout()
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
