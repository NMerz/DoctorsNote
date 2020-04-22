//
//  SearchGroupsViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/27/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import PopupKit

class SearchGroupsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var groups = ["Support Group 1", "Support Group 2"]
    var filteredGroups: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Support Groups"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        filteredGroups = groups.filter({( name : String) -> Bool in
            let searched = searchText.lowercased()
            let include = name.contains(searched)
            return (include)
        })
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFiltering()) {
            return filteredGroups!.count
        }
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "search_cell") as! SearchGroupCell
        if (isFiltering()) {
            cell.nameLabel.text = filteredGroups![indexPath.row]
        } else {
            cell.nameLabel.text = groups[indexPath.row]
        }
        cell.delegate = self
        
        return cell
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
}

class SearchGroupCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    var p: PopupView?
    var delegate: SearchGroupsTableViewController?
    
    @IBAction func showInfo(_ sender: Any) {
    
        let width : Int = Int(self.contentView.frame.width - 20)
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

        let xPos = self.delegate!.view.frame.width / 2
        let yPos = self.delegate!.view.frame.height / 2 
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: self.delegate!.view)
        
    }
    
    @objc func dismissPopup(sender: UIButton!) {
        p?.dismissType = .slideOutToBottom
        p?.dismiss(animated: true)
    }

    
}
