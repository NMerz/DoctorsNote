//
//  SupportGroupChatVC.swift
//  DoctorsNote
//
// Followed tutorial from Kasey Schlaudt
//
//  Created by Ariana Zhu on 2/23/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class SupportGroupMessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messageId: String!
    var messages = [Message]()
    var message: Message!
    var recipient: String!

    override func viewDidLoad() {
        navigationItem.title = recipient
        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 300
        
        if messageId != "" && messageId != nil {
            // load data
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.moveToBottom()
        }

        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardHeight
            }
        }
    }
    
    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func moveToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        dismissKeyboard()
        
        // database stuff
        if (messageField.text != nil && messageField.text != "") {
            if (messageId == nil) {
                
            }
            else if (messageId == "") {
                
            }
            messageField.text = ""
        }
        
        moveToBottom()
    }
    
    // Unused function for now
    @IBAction func backPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Message") as? MessagesCell {
            cell.configCell(message: message)
            return cell
        }
        else {
            return MessagesCell()
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

class MessagesCell: UITableViewCell {
    @IBOutlet weak var receivedMessageLabel: UILabel!
    @IBOutlet weak var receivedMessageView: UIView!
    @IBOutlet weak var sentMessageLabel: UILabel!
    @IBOutlet weak var sentMessageView: UIView!
    
    var message: Message!
    var currentUser: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(message: Message) {
        self.message = message
        
//        if message.sender == currentUser {
        if currentUser {
            sentMessageView.isHidden = false
            sentMessageLabel.text = String(bytes: message.getContent(), encoding: .utf8)
            receivedMessageView.isHidden = true
            receivedMessageLabel.text = ""
        }
        else {
            sentMessageView.isHidden = true
            sentMessageLabel.text = ""
            receivedMessageView.isHidden = false
            receivedMessageLabel.text = String(bytes: message.getContent(), encoding: .utf8)
        }
        
        
    }
}

