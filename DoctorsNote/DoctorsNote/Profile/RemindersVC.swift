//
//  RemindersVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

// Global list of reminders for now, should start with empty
//var remindersList = [String]()
var remindersList = [Reminder]()

class RemindersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var remindersTableView: UITableView!
    @IBOutlet weak var reminderInfoButton: UIButton!
    
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "remindersCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "remindersCell")
        }
        
        cell!.textLabel?.text = remindersList[indexPath.row].reminder
        let frequency = "\(remindersList[indexPath.row].numTimesADay ?? "nil") time(s) a day, every \(remindersList[indexPath.row].everyNumDays ?? "nil") day(s)"
        cell!.detailTextLabel?.text = frequency
        
        return cell!
        
//        let cell = UITableViewCell(style: .default, reuseIdentifier: "remindersCell")
//        cell.textLabel?.text = remindersList[indexPath.row].reminder
//        return cell
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
