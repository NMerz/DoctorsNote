//
//  RequestAccountTableViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/15/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import UIKit

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
    
}



//
//
//
class PersonalRegisterViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The height element of this will need to be changed
        scrollView.frame = self.view.bounds
    }
    
    @IBAction func goBack(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
    }
    
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
class HealthRegisterViewController: UIViewController {
    
    @IBOutlet weak var requestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestButton.layer.cornerRadius = requestButton.frame.height / 2
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        //navigationController?.popViewController(animated: true)
    }
    
    @IBAction func requestAccount(_ sender: Any) {
    }
    
}

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

