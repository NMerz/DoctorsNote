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

        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: recoverButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        recoverButton.layer.mask = mask
        
    }
    
    @IBAction func recover(_ sender: Any) {
        
        if (emailField.text == "") {
            emailField.layer.borderColor = UIColor.systemRed.cgColor
            return
        }
        
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
        
        //AWSMobileClient.default().confirmForgotPassword(username: <#T##String#>, newPassword: <#T##String#>, confirmationCode: <#T##String#>, completionHandler: <#T##((ForgotPasswordResult?, Error?) -> Void)##((ForgotPasswordResult?, Error?) -> Void)##(ForgotPasswordResult?, Error?) -> Void#>)
        
    }
    
    @objc func dismissPopup() {
        p?.dismissType = .slideOutToBottom
        p?.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
}
