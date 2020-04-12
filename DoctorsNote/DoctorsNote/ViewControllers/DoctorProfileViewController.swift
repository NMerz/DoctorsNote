//
//  DoctorProfileViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 3/14/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class DoctorProfileViewController: UIViewController {

    @IBOutlet weak var hoursLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"
        
        // FIXME: Actually implement
        self.hoursLabel.text = ""
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
