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
    @IBOutlet weak var deleteMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"
        
        // FIXME: Actually implement
        self.hoursLabel.text = ""
        self.deleteMessageLabel.text = "Messages sent in DoctorsNote will be deleted after four weeks."
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

class SupportGroupInfoViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    
    var name: String?
    var desc: String?
    var numMembers: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = name
        descriptionLabel.text = desc
        membersLabel.text = numMembers
        
    }
    
}
