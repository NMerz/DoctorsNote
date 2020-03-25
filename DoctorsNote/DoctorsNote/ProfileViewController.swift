//
//  ProfileViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import PopupKit
import AWSCognito
import AWSMobileClient

class ProfileViewController: UIViewController {
   
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var personalInfoView: PersonalInfoView!
    @IBOutlet weak var settingsButton: UIButton!
    var mask: CAShapeLayer?
    
    var p: PopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logOutButton.semanticContentAttribute = UIApplication.shared
        .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        
        personalInfoView.layer.shadowColor = UIColor.darkGray.cgColor
        personalInfoView.layer.shadowRadius = 5
        personalInfoView.layer.shadowOpacity = 0.5
        personalInfoView.layer.shadowOffset = CGSize.zero
        
        let widthConstraint = NSLayoutConstraint(item: personalInfoView!, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: -40)
        let horizontalConstraint = NSLayoutConstraint(item: personalInfoView!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([widthConstraint, horizontalConstraint])
        
        mask = CAShapeLayer()
        mask!.path = UIBezierPath(roundedRect: personalInfoView.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        
        AWSMobileClient.default().getUserAttributes { (attr, err) in
            if let err = err as? AWSMobileClientError {
                print("\(err.message)")
            }
            else if (attr != nil) {
                DispatchQueue.main.async {
                    self.navigationItem.title = attr!["name"]! + " " + attr!["family_name"]!
                }
            }
        }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mask?.frame = personalInfoView.bounds
        // Todo: Implement later, as it is not a huge priority. Currently has issues with resizing due to layout constraints
        //personalInfoView.layer.mask = mask!
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        AWSMobileClient.default().signOut()
    
    }
    
    @IBAction func showSettings(_ sender: Any) {
    
        let width : Int = Int(self.view.frame.width - 40)
        let height : Int = 160

        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        contentView.backgroundColor = UIColor.white
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 38.5).cgPath
        contentView.layer.mask = maskLayer

        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed
        
        let reportButton = UIButton(frame: CGRect(x: 25, y: 25, width: width - 50, height: 55))
        let reportLayer = CAShapeLayer()
        reportLayer.path = UIBezierPath(roundedRect: reportButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        reportButton.layer.mask = reportLayer
        reportButton.backgroundColor = UIColor.systemGray3
        reportButton.setTitle("Report an issue", for: .normal)
        reportButton.accessibilityIdentifier = "Report Button"
        reportButton.addTarget(self, action: #selector(sendReport), for: .touchUpInside)
    
        let closeButton = UIButton(frame: CGRect(x: width/2 - 45, y: 105, width: 90, height: 40))
        closeButton.setTitle("Done", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        closeButton.layer.mask = layer
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)

        contentView.addSubview(reportButton)
        contentView.addSubview(closeButton)

        let xPos = self.view.frame.width / 2
        let yPos = self.view.frame.height - CGFloat(height) + (tabBarController?.tabBar.frame.height)! - 20
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: (self.tabBarController?.view)!)
        
    }
    
    @objc func dismissPopup(sender: UIButton!) {
        p?.dismissType = .slideOutToBottom
        p?.dismiss(animated: true)
    }
    
    @objc func sendReport(sender: UIButton!) {
        let toEmail = "bbh@purdue.edu"
        let subject = "Doctors Note Issue Report".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        let urlString = "mailto:\(toEmail)?subject=\(subject!)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
}
