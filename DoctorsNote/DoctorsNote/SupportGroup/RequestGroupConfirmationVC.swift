//
//  RequestGroupConfirmationVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/27/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class RequestGroupConfirmationVC: UIViewController {
    
    var form: Form?
    @IBOutlet weak var requestConfirmationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestConfirmationLabel.text = "Your request to create \(form!.groupName!) has been confirmed. If approved, an administrator at \(form!.hospital!) will reach out to you shortly."
        self.requestConfirmationLabel.sizeToFit()
        self.requestConfirmationLabel.layoutIfNeeded()
        // Do any additional setup after loading the view.
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
