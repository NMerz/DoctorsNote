//
//  RemindersVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

// Global list of reminders for now, should start with empty
var remindersList = [String]()

class RemindersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var remindersTableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        remindersTableView.reloadData()
    }
    
    override func viewDidLoad() {
        navigationItem.title = "Reminders"
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "remindersCell")
        cell.textLabel?.text = remindersList[indexPath.row]
        return cell
    }
    
    // Delete a reminder
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        remindersList.remove(at: indexPath.row)
        remindersTableView.reloadData()
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
