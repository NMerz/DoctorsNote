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
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goForward(_ sender: Any) {
        //let email = emailField.text
        //let password = passwordField.text
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
class PersonalRegisterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var firstNameField: CustomTextField!
    @IBOutlet weak var middleNameField: CustomTextField!
    @IBOutlet weak var lastNameField: CustomTextField!
    @IBOutlet weak var DOBButton: UIButton!
    @IBOutlet weak var sexButton: UIButton!
    @IBOutlet weak var phoneField: CustomTextField!
    @IBOutlet weak var streetField: CustomTextField!
    @IBOutlet weak var cityField: CustomTextField!
    @IBOutlet weak var stateField: CustomTextField!
    @IBOutlet weak var zipField: CustomTextField!
    
    var p: PopupView?
    var DOBPicker: UIDatePicker?
    var sexPicker: UIPickerView?
    
    var DOB: String = ""
    var sex: String = ""
    
    let sexes = ["Male", "Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DOBButton.layer.borderColor = UIColor.systemBlue.cgColor
        sexButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        DOBButton.layer.borderWidth = 2
        sexButton.layer.borderWidth = 2
        
        DOBButton.layer.cornerRadius = DefinedValues.fieldRadius
        sexButton.layer.cornerRadius = DefinedValues.fieldRadius
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToVC(segue:UIStoryboardSegue) { }
    
    @IBAction func goForward(_ sender: Any) {
        // FIX THIS !!!!!
        if (!checkFields()) {
            self.performSegue(withIdentifier: "show_third", sender: self)
        }
    }
    
    func checkFields() -> Bool {
        let first = firstNameField.isNotEmpty()
        let middle = middleNameField.isNotEmpty()
        let last = lastNameField.isNotEmpty()
        let phone = phoneField.isNotEmpty()
        let street = streetField.isNotEmpty()
        let city = cityField.isNotEmpty()
        let state = stateField.isNotEmpty()
        let zip = zipField.isNotEmpty()
        
        var DOBFilled = false
        if (DOB == "") {
            DOBButton.layer.borderColor = UIColor.systemRed.cgColor
            DOBFilled = true
        } else {
            DOBButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
        
        var sexFilled = false
        if (sex == "") {
            sexButton.layer.borderColor = UIColor.systemRed.cgColor
            sexFilled = true
        } else {
            sexButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
        
        // False if fields filled
        return (
            first
            && middle
            && last
            && DOBFilled
            && sexFilled
            && phone
            && street
            && city
            && state
            && zip
        )
    }
    
    @IBAction func showDOB(_ sender: Any) {
        pressButton(tag: DOBButton.tag)
    }
    
    @IBAction func showSex(_ sender: Any) {
        pressButton(tag: sexButton.tag)
    }
    
    func pressButton(tag: Int) {
        let width : Int = Int(self.view.frame.width - 20)
        let height = 280
        
        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        contentView.backgroundColor = UIColor.white
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 38.5).cgPath
        contentView.layer.mask = maskLayer
        
        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed
        
        if (tag == 1) {
            DOBPicker = UIDatePicker(frame: CGRect(x: 5, y: 5, width: contentView.frame.width - 10, height: 200))
            DOBPicker?.datePickerMode = .date
            DOBPicker?.maximumDate = Date()
        }
        else if (tag == 2) {
            sexPicker = UIPickerView(frame: CGRect(x: 5, y: 5, width: contentView.frame.width - 10, height: 200))
            sexPicker?.dataSource = self
            sexPicker?.delegate = self
        }
        
        
        let closeButton = UIButton(frame: CGRect(x: width/2 - 45, y: height - 75, width: 90, height: 50))
        closeButton.setTitle("Done", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        closeButton.layer.mask = layer
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        closeButton.tag = tag
        
        contentView.addSubview(closeButton)
        if (tag == 1) {
            contentView.addSubview(DOBPicker!)
        }
        else if (tag == 2) {
            contentView.addSubview(sexPicker!)
        }
        
        let xPos = self.view.frame.width / 2
        let yPos = self.view.frame.height - (CGFloat(height) / 2) - 10
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: self.navigationController!.view)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = sexes[row]
        return row
    }
    
    @objc func dismissPopup(sender: UIButton!) {
        if (sender.tag == 1) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            DOB = dateFormatter.string(from: DOBPicker!.date)
            
            // TODO: ADD DATE FORMATTER
            DOBButton.setTitle(DOB, for: .normal)
            p?.dismissType = .slideOutToBottom
            p?.dismiss(animated: true)
        }
        else if (sender.tag == 2) {
            sex = sexes[(sexPicker?.selectedRow(inComponent: 0))!]
            sexButton.setTitle(sex, for: .normal)
            p?.dismissType = .slideOutToBottom
            p?.dismiss(animated: true)
        }
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
            
            //let main = UIStoryboard(name: "Main", bundle: nil)
            //let mainVC = main.instantiateInitialViewController()!
            //let presentationStyle : UIModalPresentationStyle = .overCurrentContext
            //self.modalPresentationStyle = presentationStyle
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
        let width : Int = Int(self.view.frame.width - 20)
        let height = 280
        
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
        closeButton.setTitle("Done", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        closeButton.layer.mask = layer
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
            
            selectHospitalButton.setTitle(hospital, for: .normal)
            p?.dismissType = .slideOutToBottom
            p?.dismiss(animated: true)
        }
        else if (picker?.tag == 2) {
            provider = providers[(picker?.selectedRow(inComponent: 0))!]
            selectHealthcareButton.setTitle(provider, for: .normal)
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

/*
 Adds padding to text fields
 Original source before modifications: https://stackoverflow.com/questions/3727068/set-padding-for-uitextfield-with-uitextborderstylenone
 */

class CustomTextField: UITextField {
    struct Constants {
        static let sidePadding: CGFloat = 15
        static let topPadding: CGFloat = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor.systemBlue.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = DefinedValues.fieldRadius
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.borderColor = UIColor.systemBlue.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = DefinedValues.fieldRadius
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: bounds.origin.x + Constants.sidePadding,
            y: bounds.origin.y,
            width: bounds.size.width - Constants.sidePadding * 2,
            height: bounds.size.height
        )
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    
    func isNotEmpty() -> Bool {
        if (self.text == "") {
            self.layer.borderColor = UIColor.systemRed.cgColor
            return false
        } else {
            self.layer.borderColor = UIColor.systemBlue.cgColor
            return false
        }
    }
}

