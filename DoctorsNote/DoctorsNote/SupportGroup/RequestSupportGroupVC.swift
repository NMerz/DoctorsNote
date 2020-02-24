//
//  RequestSupportGroupVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/24/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

@objc protocol FormControl {
    var key: String? { get }
    var text: String? { get }
    func clear()
}

class RequestSupportGroupVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Request New Group"
        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet var form: Form!
    
    @IBAction func submit() {
        print("Form Data:",
            form["firstName"],
            form["lastName"],
            form["age"])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
