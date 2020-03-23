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

        // FIXME: Actually implement
        CognitoHelper.sharedHelper.getWorkHours(doctor: User.init(uid: "1234")) { (success, hours) in
            if (success) {
                DispatchQueue.main.async {
                    self.hoursLabel.text = hours
                }
            } else {
                print(hours)
            }
        }
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
