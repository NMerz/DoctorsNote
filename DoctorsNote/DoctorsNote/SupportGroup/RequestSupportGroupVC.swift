//
//  RequestSupportGroupVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/24/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class RequestSupportGroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var groupNameFieldLabel: UILabel!
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var hospitalNameFieldLabel: UILabel!
    @IBOutlet weak var hospitalDropdownButton: UIButton!
    @IBOutlet weak var descriptionFIeldLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    let transparentView = UIView()
    let dropdownTableView = UITableView()
    
    var selectedButton = UIButton()
    
    var hospitalList = [String]()
    
    var form: SupportGroupForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Request New Group"
        // Do any additional setup after loading the view.
        self.form = SupportGroupForm()
        self.hideKeyboardWhenTappedAround()
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
        dropdownTableView.register(DropdownCell.self, forCellReuseIdentifier: "DropdownCell")
    }
    
    func addTransparentView(frames: CGRect) {
        // Add transparent background
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first // shared.keyWindow depreciated
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        // Add dropdown table
        dropdownTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(dropdownTableView)
        dropdownTableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        // Update hospitalList
        dropdownTableView.reloadData()
        
        // Remove transparent background
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.transparentView.alpha = 0.2
            
            // 50 is height of one row
            self.dropdownTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.hospitalList.count * 50))
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, animations: {
            self.transparentView.alpha = 0
            self.dropdownTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
        }, completion: nil)
        
    }
    
    
    @IBAction func onClickHospitalDropdown(_ sender: Any) {
        // Connect hospital list to API later
        hospitalList = ["IU Health", "IU Arnett", "Hoag Hospital"]
        selectedButton = hospitalDropdownButton
        addTransparentView(frames: hospitalDropdownButton.frame)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.form?.groupName = groupNameField.text
        self.form?.hospital = hospitalDropdownButton.titleLabel?.text
        self.form?.groupDescription = descriptionField.text
        let requestConfirmation = segue.destination as! RequestGroupConfirmationVC
        requestConfirmation.form = self.form
    }
    
    // Check for invalid input
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        if let hospital = hospitalDropdownButton.titleLabel?.text, hospital == "Select Hospital" {
            let alertController2 = UIAlertController(title: "hol up", message: "Please select a hospital.", preferredStyle: .alert)
            alertController2.addAction(okAction)
            self.present(alertController2, animated: true, completion: nil)
            return false
        }
        if let name = groupNameField.text, name.count >= 4 {
            if let desc = descriptionField.text, desc.count >= 10 {
                return true
            }
            else {
                let alertController1 = UIAlertController(title: "hol up", message: "Description must be at least 10 characters long.", preferredStyle: .alert)
                alertController1.addAction(okAction)
                self.present(alertController1, animated: true, completion: nil)
                return false
            }
        }
        else {
            let alertController3 = UIAlertController(title: "hol up", message: "Group name must be at least 4 characters long.", preferredStyle: .alert)
            alertController3.addAction(okAction)
            self.present(alertController3, animated: true, completion: nil)
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitalList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
        cell.textLabel?.text = hospitalList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedButton.setTitle(hospitalList[indexPath.row], for: .normal)
        removeTransparentView()
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class DropdownCell: UITableViewCell {
    
}
