//
//  LoginNavigationController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/22/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class LoginNavigationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.performSegue(withIdentifier: "show_that_thang", sender: self)
        //perform(#selector(showLoginController), with: nil, afterDelay: 0)
    }

    @objc func showLoginController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        //let loginController = storyboard.viewcontroller
        //loginController.modalPresentationStyle = .fullScreen
        //present(loginController, animated: true) {
            
        //}
    }

}
