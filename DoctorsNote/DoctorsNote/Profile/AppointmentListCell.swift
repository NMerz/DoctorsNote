//
//  AppointmentListCell.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 3/26/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSMobileClient

class AppointmentListCell: UITableViewCell {
    
    @IBOutlet weak var doctor: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var processor: ConnectionProcessor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setAppointment(appointment: Appointment) {
        var withName = appointment.getWithID()
        var connector = Connector()
        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
        processor = ConnectionProcessor(connector: connector)
        do {
            withName = try processor!.processGetUserInfo(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/GetUserInfo", uid: appointment.getWithID())
        } catch let error {
            print((error as! ConnectionError).getMessage())
        }
        
        doctor.text = appointment.getContent() + " with " + withName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy 'at' HH:mm"
        let formattedDateTime = dateFormatter.string(from: appointment.getTimeScheduled())
        date.text = formattedDateTime
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
