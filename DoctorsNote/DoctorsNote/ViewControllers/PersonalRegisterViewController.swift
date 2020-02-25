//
//  RequestAccountTableViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/15/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import UIKit
import AWSCognito
import AWSMobileClient
import PopupKit

//
//
//
class AccountRegisterViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.layer.cornerRadius = DefinedValues.fieldRadius
        passwordField.layer.cornerRadius = DefinedValues.fieldRadius
        confirmField.layer.cornerRadius = DefinedValues.fieldRadius
        
        let emailPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: emailField.frame.height))
        let passwordPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: passwordField.frame.height))
        let confirmPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: confirmField.frame.height))
        
        emailField.leftView = emailPadding
        emailField.rightView = emailPadding
        passwordField.leftView = passwordPadding
        passwordField.rightView = passwordPadding
        confirmField.leftView = confirmPadding
        confirmField.rightView = confirmPadding

        emailField.leftViewMode = .always
        emailField.rightViewMode = .always
        passwordField.leftViewMode = .always
        passwordField.rightViewMode = .always
        confirmField.leftViewMode = .always
        confirmField.rightViewMode = .always
       
        emailField.layer.borderColor = navigationController?.navigationBar.tintColor.cgColor
        emailField.layer.borderWidth = 2
        passwordField.layer.borderColor = navigationController?.navigationBar.tintColor.cgColor
        passwordField.layer.borderWidth = 2
        confirmField.layer.borderColor = navigationController?.navigationBar.tintColor.cgColor
        confirmField.layer.borderWidth = 2
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goForward(_ sender: Any) {
        let email = emailField.text
        let password = passwordField.text
        if (fieldsCorrect()) {
            return
        }
        performSegue(withIdentifier: "show_profile", sender: self)
//        AWSMobileClient.default().signUp(username: email, password: password, userAttributes: ["name":"Ben", "middle_name":"Burk", "family_name":"Hardin", "gender":"Male", "birthdate":"06/19/2001", "address":"3980 N Graham Rd Madison IN 47250", "phone_number":"+18128017698"]) { (result, err) in
//            if let err = err as? AWSMobileClientError {
//                print("\(err.message)")
//            } else {
//                print("User signed up successfully.")
//            }
//        }
    }
        
    func fieldsCorrect() -> Bool {
        let emailEmpty = emailField.text == ""
        let passwordEmpty = passwordField.text == ""
        let confirmEmpty = confirmField.text == ""
        if (emailEmpty) {
            emailField.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            emailField.layer.borderColor = UIColor.systemBlue.cgColor
        }
        if (passwordEmpty) {
            passwordField.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            passwordField.layer.borderColor = UIColor.systemBlue.cgColor
        }
        if (confirmEmpty) {
            confirmField.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            confirmField.layer.borderColor = UIColor.systemBlue.cgColor
        }
        
        return (emailEmpty || passwordEmpty || confirmEmpty)
    }
    
}



//
//
//
class PersonalRegisterViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var insideView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The height element of this will need to be changed
        scrollView.isScrollEnabled = true
    }
    
    @IBAction func goBack(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToVC(segue:UIStoryboardSegue) { }
    
    @IBAction func showDOB(_ sender: Any) {
//        let height: CGFloat = 290
//        let width = self.view.frame.width - 20
//        let x = (self.view.frame.width / 2) - (width / 2)
//        let y = (self.view.frame.height / 2) - (height / 2)
//        
//        //FIXME: The storyboard name will need to be changed
//        let dobViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DOBView")
//        
//        present(dobViewController, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//        
//        let dateView = DOBView(frame: CGRect(x: x, y: y, width: width, height: height))
//        dateView.layer.shadowColor = UIColor.black.cgColor
//        dateView.layer.shadowRadius = 50
//        dateView.layer.shadowOpacity = 1.0
//        self.view.addSubview(dateView)
//    
    }
    
}



//
//
//
class HealthRegisterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var selectHospitalButton: UIButton!
    @IBOutlet weak var selectHealthcareButton: UIButton!

    var p: PopupView?
    var picker: UIPickerView?
    // To be gathered later from the database
    let hospitals = ["IU Health Arnett Hospital", "Franciscan Health Lafayette East"]
    var hospital: String?
    
    let providers = ["Humana", "Aetna", "Other"]
    var provider: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestLayer = CAShapeLayer()
        requestLayer.path = UIBezierPath(roundedRect: requestButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        requestButton.layer.mask = requestLayer
        
        selectHospitalButton.layer.cornerRadius = DefinedValues.fieldRadius
        selectHealthcareButton.layer.cornerRadius = DefinedValues.fieldRadius
        
         selectHospitalButton.layer.borderColor = navigationController?.navigationBar.tintColor.cgColor
         selectHospitalButton.layer.borderWidth = 2
         selectHealthcareButton.layer.borderColor = navigationController?.navigationBar.tintColor.cgColor
         selectHealthcareButton.layer.borderWidth = 2
        
    }
    
    @IBAction func requestAccount(_ sender: Any) {
        
        let hospitalSelected = (hospital != nil)
        let providerSelected = (provider != nil)
        
        if (hospitalSelected) {
            selectHospitalButton.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            selectHospitalButton.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        if (providerSelected) {
            selectHealthcareButton.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            selectHealthcareButton.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        if (!hospitalSelected || !providerSelected) {
            return
        }
        
    //        AWSMobileClient.default().signOut()
    //        AWSMobileClient.default().signIn(username: email, password: password) { (result, err) in
    //            if let err = err as? AWSMobileClientError {
    //                print("\(err.message)")
    //            } else {
    //                print("user signed in ")
    //            }
    //        }
            
            let main = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = main.instantiateInitialViewController()!
            let presentationStyle : UIModalPresentationStyle = .overCurrentContext
            self.modalPresentationStyle = presentationStyle
    //        AWSMobileClient.default().confirmSignIn(challengeResponse: "809614") { (signInResult, error) in
    //            if let error = error as? AWSMobileClientError {
    //                print("\(error.message)")
    //            } else if let signInResult = signInResult {
    //                switch (signInResult.signInState) {
    //                case .signedIn:
    //                    print("User is signed in.")
    //
    //                default:
    //                    print("\(signInResult.signInState.rawValue)")
    //                }
    //            }
    //        }
        
        }
    
    @IBAction func selectHospital(_ sender: Any) {
        pressButton(tag: 1)
    }
    
    @IBAction func selectProvider(_ sender: Any) {
        pressButton(tag: 2)
    }
    
    func pressButton(tag: Int) {
        let color = UIColor.lightGray
        let width : Int = Int(self.view.frame.width - 20)
        let height = 280
        let distance = 20
        let buttonWidth = width - (distance * 2)
        let borderWidth : CGFloat = 2
        
        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        contentView.backgroundColor = UIColor.white
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 38.5).cgPath
        contentView.layer.mask = maskLayer
        
        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed
        
        picker = UIPickerView(frame: CGRect(x: 5, y: 5, width: contentView.frame.width - 10, height: 200))
        picker?.tag = tag
        picker?.dataSource = self
        picker?.delegate = self
        
        
        let closeButton = UIButton(frame: CGRect(x: width/2 - 45, y: height - 75, width: 90, height: 50))
        closeButton.layer.cornerRadius = 25
        closeButton.setTitle("Done", for: .normal)
        closeButton.backgroundColor = color
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        
        contentView.addSubview(closeButton)
        contentView.addSubview(picker!)
        
        let xPos = self.view.frame.width / 2
        let yPos = self.view.frame.height - (CGFloat(height) / 2) - 10
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: (self.view)!)
    }
    
    @IBAction func goBack(_ sender: Any) {
        //navigationController?.popViewController(animated: true)
        performSegue(withIdentifier: "unwindto2", sender: self)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1) {
            return hospitals.count
        }
        else if (pickerView.tag == 2) {
            return providers.count
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1) {
            let row = hospitals[row]
            return row
        }
        else if (pickerView.tag == 2) {
            let row = providers[row]
            return row
        }
        return ""
    }
    
    @objc func dismissPopup(sender: UIButton!) {
        if (picker?.tag == 1) {
            hospital = hospitals[(picker?.selectedRow(inComponent: 0))!]
            selectHospitalButton.titleLabel!.text = hospital
            p?.dismissType = .slideOutToBottom
            p?.dismiss(animated: true)
        }
        else if (picker?.tag == 2) {
            provider = providers[(picker?.selectedRow(inComponent: 0))!]
            selectHealthcareButton.titleLabel!.text = provider
            p?.dismissType = .slideOutToBottom
            p?.dismiss(animated: true)
        }
    }

}


//
// Segue classes
//
class SegueFromLeft: UIStoryboardSegue
{
    override func perform() {
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        src.navigationController!.view.layer.add(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
}

class SegueFromRight: UIStoryboardSegue
{
    override func perform() {
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        src.navigationController!.view.layer.add(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
}

