//
//  ReminderCell.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 3/15/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

protocol ReminderCellDelegate {
    func didTapReminderInfo(reminder: Reminder)
}

class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var reminderTitle: UILabel!
    @IBOutlet weak var reminderFrequency: UILabel!
    
    var delegate: ReminderCellDelegate?
    var reminderItem: Reminder!
    
    // get index of table cell
    var tableView: UITableView? {
        return superview as? UITableView
    }

    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setReminder(reminder: Reminder) {
        reminderItem = reminder
        reminderTitle.text = reminder.reminder
        reminderFrequency.text = "\(reminder.numTimesADay ?? "nil") time(s) a day, every \(reminder.everyNumDays ?? "nil") day(s)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    @IBAction func reminderInfoTapped(_ sender: UIButton) {
        delegate?.didTapReminderInfo(reminder: remindersList[indexPath!.row])
    }
    
    
}
