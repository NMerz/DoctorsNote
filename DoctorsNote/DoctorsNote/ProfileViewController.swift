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
    
    var p: PopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logOutButton.semanticContentAttribute = UIApplication.shared
        .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        
        personalInfoView.layer.shadowColor = UIColor.darkGray.cgColor
        personalInfoView.layer.shadowRadius = 5
        personalInfoView.layer.shadowOpacity = 0.5
        personalInfoView.layer.shadowOffset = CGSize.zero
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: personalInfoView.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        
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
        //personalInfoView.layer.mask = mask
        
    }

    @IBAction func logOut(_ sender: Any) {
        
        AWSMobileClient.default().signOut()
    
    }
    
    @IBAction func showSettings(_ sender: Any) {
    
        let width : Int = Int(self.view.frame.width - 20)
        let height = 500

        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        contentView.backgroundColor = UIColor.white
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 38.5).cgPath
        contentView.layer.mask = maskLayer

        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed

        let nameLabel = UILabel(frame: CGRect(x: 20, y: 20, width: width - 40, height: 100))
        nameLabel.text = "Group Name\n\nGroup Description"
        nameLabel.numberOfLines = 5
        
        let descriptionOffset = Int(nameLabel.frame.height) + 40
        let descriptionLabel = UILabel(frame: CGRect(x: 20, y: descriptionOffset, width: width - 20, height: 200))
        
        let messageOffset = 60 + Int(nameLabel.frame.height) + Int(descriptionLabel.frame.height)
        let messageLabel = UILabel(frame: CGRect(x: 20, y: messageOffset, width: width - 40, height: 25))
        nameLabel.text = "## Members"
    
        let closeButton = UIButton(frame: CGRect(x: width/2 - 45, y: height - 75, width: 90, height: 40))
        closeButton.setTitle("Done", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        closeButton.layer.mask = layer
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)

        
        let joinButton = UIButton(frame: CGRect(x: width/2 - 45, y: height - 75, width: 90, height: 40))
        let joinLayer = CAShapeLayer()
        joinLayer.path = UIBezierPath(roundedRect: joinButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        joinButton.layer.mask = joinLayer

        contentView.addSubview(joinButton)
        contentView.addSubview(closeButton)
        contentView.addSubview(nameLabel)

        let xPos = self.view.frame.width / 2
        let yPos = self.view.frame.height / 2
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
    
}
