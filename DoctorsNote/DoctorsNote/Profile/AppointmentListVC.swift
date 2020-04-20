//
//  AppointmentListVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 3/27/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSMobileClient
import EventKit
import EventKitUI
import PopupKit

class AppointmentListVC: UITableViewController, EKEventEditViewDelegate {
    
    var p: PopupView?
    var selectedEvent: Appointment?
    
    @IBOutlet var appointmentTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Pending Appointments"
        
        var connector = Connector()
        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
        let processor = ConnectionProcessor(connector: connector)
        do {
            appointmentList = try processor.processAppointments(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/appointmentlist")
        } catch let error {
            print((error as! ConnectionError).getMessage())
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Reload appointment list data
        var connector = Connector()
        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
        let processor = ConnectionProcessor(connector: connector)
        do {
            appointmentList = try processor.processAppointments(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/appointmentlist")
        } catch let error {
            print((error as! ConnectionError).getMessage())
        }
        appointmentTableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return appointmentList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appointment = appointmentList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentCell") as! AppointmentListCell
        cell.setAppointment(appointment: appointment)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }

    // Inspired by: https://www.ioscreator.com/tutorials/add-event-calendar-ios-tutorial
    func insertEvent(store: EKEventStore) {
        let calendar = store.defaultCalendarForNewEvents
        let startDate = selectedEvent?.getTimeScheduled()
        // 2 hours
        let endDate = startDate?.addingTimeInterval(60 * 60)
            
        // 4
        let event = EKEvent(eventStore: store)
        event.calendar = calendar
            
        event.title = "Doctor Appointment"
        event.startDate = startDate
        event.endDate = endDate
            
        presentEventCalendarDetailModal(event: event, store: store)
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let shareAction = UIContextualAction(style: .normal, title: "Export") { (_, _, completion) in
            completion(true)
            self.showInfo()
        }
        shareAction.backgroundColor = UIColor.systemBlue
        selectedEvent = appointmentList[indexPath.row]
          
        return UISwipeActionsConfiguration(actions: [shareAction])
    }
    
    // Inspired by: https://medium.com/@fede_nieto/manage-calendar-events-with-eventkit-and-eventkitui-with-swift-74e1ecbe2524
    func presentEventCalendarDetailModal(event: EKEvent, store: EKEventStore) {
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = store
        eventModalVC.editViewDelegate = self
        self.present(eventModalVC, animated: true, completion: nil)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
        p?.dismiss(animated: true)
    }
    
    func showInfo() {
    
        let width : Int = Int(self.view.frame.width - 20)
        let height = 250

        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        contentView.backgroundColor = UIColor.white
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 38.5).cgPath
        contentView.layer.mask = maskLayer

        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed
        
        // Apple Calendar Export Button
        let iCalButton = UIButton(frame: CGRect(x: width/2 - 90, y: 25, width: 180, height: 55))
        iCalButton.setTitle("Apple Calendar", for: .normal)
        iCalButton.backgroundColor = UIColor.systemBlue
        let iCalLayer = CAShapeLayer()
        iCalLayer.path = UIBezierPath(roundedRect: iCalButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        iCalButton.layer.mask = iCalLayer
        iCalButton.accessibilityLabel = "Apple Calendar Button"
        iCalButton.addTarget(self, action: #selector(addToAppleCalendar), for: .touchUpInside)
        
        // Google Calendar Export Button
        let gCalButton = UIButton(frame: CGRect(x: width/2 - 90, y: 105, width: 180, height: 55))
        gCalButton.setTitle("Google Calendar", for: .normal)
        gCalButton.backgroundColor = UIColor.systemBlue
        let gCalLayer = CAShapeLayer()
        gCalLayer.path = UIBezierPath(roundedRect: iCalButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        gCalButton.layer.mask = gCalLayer
        gCalButton.accessibilityLabel = "Google Calendar Button"
        gCalButton.addTarget(self, action: #selector(addToGoogleCalendar), for: .touchUpInside)

        // Close View Button
        let closeButton = UIButton(frame: CGRect(x: width/2 - 45, y: 185, width: 90, height: 40))
        closeButton.setTitle("Cancel", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        closeButton.layer.mask = layer
        closeButton.accessibilityLabel = "Close Button"
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)

        // Add buttons to view
        contentView.addSubview(iCalButton)
        contentView.addSubview(gCalButton)
        contentView.addSubview(closeButton)

        // Present view
        let xPos = self.view.frame.width / 2
        let yPos = (self.view.frame.height / 2) - (CGFloat(height) / 2)
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: self.view)
        
    }
    
    @objc func dismissPopup(sender: UIButton!) {
        p?.dismiss(animated: true)
    }
    
    @objc func addToAppleCalendar() {
        let eventStore = EKEventStore()

        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertEvent(store: eventStore)
            case .denied:
                print("Access denied")
            case .notDetermined:
                eventStore.requestAccess(to: .event, completion:
                  {[weak self] (granted: Bool, error: Error?) -> Void in
                      if granted {
                        self!.insertEvent(store: eventStore)
                      } else {
                            print("Access denied")
                      }
                })
                default:
                    print("Case default")
        }
    }
    
    @objc func addToGoogleCalendar() {
        let date = selectedEvent?.getTimeScheduled()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd'T'hhmmss'Z'"
        df.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let stringDate = df.string(from: date!)
        let urlString = "http://calendar.google.com/?action=create&title=Doctor+Appointment&dates=" + stringDate + "/" + stringDate
        let url = URL(string: urlString)!
        if UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)

         } else {
            //redirect to safari because the user doesn't have Google Calendar
            let safariString = "https://www.google.com/calendar/render?action=TEMPLATE&text=Doctor+Appointment&dates=" + stringDate + "/" + stringDate
            UIApplication.shared.open(URL(string: safariString)!)
        }
    }
    
}
