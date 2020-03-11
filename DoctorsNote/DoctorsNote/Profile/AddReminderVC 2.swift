//
//  AddReminderVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class AddReminderVC: UIViewController {
    @IBOutlet weak var newReminderField: UITextField!
    @IBOutlet weak var addReminderButton: UIButton!
    
    @IBAction func addReminderButtonAction(_ sender: Any) {
        if newReminderField.text != "" {
            remindersList.append(newReminderField.text!)
            newReminderField.text = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
