//
//  AddReminderVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class EditReminderVC: UIViewController {
    @IBOutlet weak var editReminderField: UITextField!
    @IBOutlet weak var editNumTimesADayField: UITextField!
    @IBOutlet weak var editEveryNumDaysField: UITextField!
    @IBOutlet weak var editReminderDescriptionField: UITextField!
//    @IBOutlet weak var editReminderButton: UIButton!
    
//    @IBAction func editReminderButtonAction(_ sender: Any) {
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit Reminder"
        // Do any additional setup after loading the view.
    }

}
