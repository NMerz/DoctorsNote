//
//  SearchGroupsViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/27/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
//import PopupKit

class SearchGroupsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

class SearchGroupCell: UITableViewCell {
    
    //var p: PopupView?
    
    @IBOutlet weak var nameLabel: NSLayoutConstraint!
    
    @IBAction func showInfo(_ sender: Any) {
    
//        let width : Int = Int(self.view.frame.width - 20)
//        let height = 500
//
//        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
//        contentView.backgroundColor = UIColor.white
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 38.5).cgPath
//        contentView.layer.mask = maskLayer
//
//        p = PopupView.init(contentView: contentView)
//        p?.maskType = .dimmed
//
//        let nameLabel = UILabel(frame: CGRect(x: 20, y: 20, width: width - 40, height: 100))
//        nameLabel.text = "Group Name\n\nGroup Description"
//        nameLabel.numberOfLines = 5
//        
//        let descriptionLabel = UILabel(frame: CGRect(x: 20, y: 20+nameLabel.frame.height+20, width: width - 20, height: 200))
//        
//        let messageLabel = UILabel(frame: CGRect(x: 20, y: 20+nameLabel.frame.height+20+descriptionLabel.height+20, width: width - 40, height: 25))
//        nameLabel.text = "## Members"
        
//
//        let closeButton = UIButton(frame: CGRect(x: width/2 - 45, y: height - 75, width: 90, height: 40))
//        closeButton.setTitle("Done", for: .normal)
//        closeButton.backgroundColor = UIColor.systemBlue
//        let layer = CAShapeLayer()
//        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
//        closeButton.layer.mask = layer
//        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
//
//        contentView.addSubview(closeButton)
//        contentView.addSubview(nameLabel)
//          contentView.addSubview(membersLabel)
//
//        let xPos = self.view.frame.width / 2
//        let yPos = self.view.frame.height - (CGFloat(height) / 2) - 10
//        let location = CGPoint.init(x: xPos, y: yPos)
//        p?.showType = .slideInFromBottom
//        p?.maskType = .dimmed
//        p?.dismissType = .slideOutToBottom
//        p?.show(at: location, in: self.navigationController!.view)
        
    }
    
//    @objc func dismissPopup(sender: UIButton!) {
//        p?.dismissType = .slideOutToBottom
//        p?.dismiss(animated: true)
//    }
//
    
}
