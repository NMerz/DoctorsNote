//
//  ReportUserViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 3/31/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import MessageUI

class ReportUserViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var userTextField: CustomTextField!
    @IBOutlet weak var reasonTextField: CustomTextField!
    @IBOutlet weak var reportButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reportButton.backgroundColor = UIColor.systemBlue
        reportButton.layer.cornerRadius = DefinedValues.fieldRadius
        // Do any additional setup after loading the view.
    }
    
    @IBAction func reportUser(_ sender: Any) {
        sendReport()
    }
    

    func sendReport() {
        let userEmpty = userTextField.isEmpty()
        let reasonEmpty = userTextField.isEmpty()
        
        if (userEmpty || reasonEmpty) {
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        let toEmail = "bbh@purdue.edu"
        let subject = "Report Doctor'sNote User"
        var body = "Reporting: " + userTextField.text!
        body += "\n\n" + reasonTextField.text!
        
        // Configure the fields of the interface.
        composeVC.setToRecipients([toEmail])
        composeVC.setSubject(subject)
        composeVC.setMessageBody(body, isHTML: false)

        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.

        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

}
