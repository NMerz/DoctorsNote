//
//  DoctorProfileViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 3/14/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSMobileClient

class DoctorProfileViewController: UIViewController {

    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var deleteMessageLabel: UILabel!
    
    var conversationID: Int?
    var converserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = converserName ?? ""

        self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"
        
        // FIXME: Actually implement
        self.hoursLabel.text = ""
        self.deleteMessageLabel.text = "Messages sent in DoctorsNote will be deleted after four weeks."
    }
    
    @IBAction func confirmation() {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to leave this conversation", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
           // let currentUID = CognitoHelper.user!.getUID()
            //let convoID = 
            //CognitoHelper.sharedHelper.logout()
            print ("conversationID:" )
            print (self.conversationID!)
            var convoID = String(self.conversationID!)
            let connector = Connector()
            AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
            let processor = ConnectionProcessor(connector: connector)
            do {
                try processor.processLeaveConversation(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/leaveconversation", convoID: convoID)
            }
            catch let error {
                // Fails to delete user
                print("ERROR")
                print((error as! ConnectionError).getMessage())
            }
            print("left convo")
            self.performSegue(withIdentifier: "Conversation", sender: nil)
        }
        ))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
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
