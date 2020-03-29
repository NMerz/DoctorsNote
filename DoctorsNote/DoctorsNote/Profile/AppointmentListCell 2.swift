//
//  AppointmentListCell.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 3/26/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class AppointmentListCell: UITableViewCell {
    
    @IBOutlet weak var appointmentDoctor: UILabel!
    @IBOutlet weak var appointmentDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setAppointment(appointment: Appointment) {
        appointmentDoctor.text = appointment.getWithID()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy 'at' HH:mm"
        let formattedDateTime = dateFormatter.string(from: appointment.getTimeScheduled())
        appointmentDate.text = formattedDateTime
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
