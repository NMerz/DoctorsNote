//
//  SearchGroupsViewController.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/27/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import PopupKit
import AWSMobileClient

class SearchGroupsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var groups: [Conversation]?
    var filteredGroups: [Conversation]?
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.center = self.view.center
        activityIndicator.style = .gray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Support Groups"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Get all support groups from database
        DispatchQueue.main.async {
            let authorizedConnector = Connector()
            AWSMobileClient.default().getTokens(authorizedConnector.setToken(potentialTokens:potentialError:))
            var tempList: [Conversation]?
            let processor : ConnectionProcessor = ConnectionProcessor(connector: authorizedConnector)
            do {
                (self.groups, _) = try processor.processAllSupportGroups()
            } catch {
                // ADD ERROR HANDLING
            }
            
            // Filter conversations
//            self.conversationList = []
//            if (tempList != nil && tempList!.count > 0) {
//                for i in 0...tempList!.count - 1 {
//                    if (tempList![i].getConverserID() == "N/A") {
//                        self.conversationList?.append(tempList![i])
//                    }
//                }
//            }
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        filteredGroups = groups!.filter({( convo: Conversation ) -> Bool in
            let searched = searchText.lowercased()
            let include = convo.getConversationName().contains(searched)
            return (include)
        })
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFiltering()) {
            return filteredGroups!.count
        }
        return groups?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "search_cell") as! SearchGroupCell
        if (isFiltering()) {
            cell.conversation = filteredGroups![indexPath.row]
            cell.nameLabel.text = filteredGroups![indexPath.row].getConversationName()
        } else {
            cell.conversation = groups![indexPath.row]
            cell.nameLabel.text = groups![indexPath.row].getConversationName()
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
    var conversation: Conversation?
    
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

        let nameLabel = UILabel(frame: CGRect(x: 20, y: 20, width: width - 40, height: 35))
        nameLabel.text = "Name: " + conversation!.getConversationName()
        nameLabel.numberOfLines = 1
        nameLabel.accessibilityLabel = "Name Label"
        contentView.addSubview(nameLabel)
        
        let descriptionOffset = Int(nameLabel.frame.maxY)
        let descriptionLabel = UILabel(frame: CGRect(x: 20, y: descriptionOffset, width: width - 20, height: 200))
        descriptionLabel.numberOfLines = 5
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.text = "Description: " + conversation!.getDescription()
        descriptionLabel.accessibilityLabel = "Description Label"
        contentView.addSubview(descriptionLabel)
        
        let messageOffset = Int(descriptionLabel.frame.maxY) + 10
        let memberLabel = UILabel(frame: CGRect(x: 20, y: messageOffset, width: width - 40, height: 25))
        memberLabel.text = "Members: " + String(conversation!.getNumMembers())
        memberLabel.accessibilityLabel = "Member Label"
        contentView.addSubview(memberLabel)
        
        let closeButton = UIButton(frame: CGRect(x: width/2 + 10, y: height - 75, width: 90, height: 40))
        closeButton.setTitle("Cancel", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: closeButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        closeButton.layer.mask = layer
        closeButton.accessibilityLabel = "Close Button"
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)

        
        let joinButton = UIButton(frame: CGRect(x: width/2 - 90 - 10, y: height - 75, width: 90, height: 40))
        joinButton.setTitle("Join", for: .normal)
        joinButton.backgroundColor = UIColor.systemBlue
        let joinLayer = CAShapeLayer()
        joinLayer.path = UIBezierPath(roundedRect: joinButton.bounds, cornerRadius: DefinedValues.fieldRadius).cgPath
        joinButton.layer.mask = joinLayer
        joinButton.accessibilityLabel = "Join Button"
        joinButton.addTarget(self, action: #selector(joinSupportGroup), for: .touchUpInside)

        contentView.addSubview(joinButton)
        contentView.addSubview(closeButton)

        let xPos = self.delegate!.view.frame.width / 2
        let yPos = self.delegate!.view.frame.height / 2 
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: self.delegate!.tabBarController!.view)
        
    }
    
    @objc func dismissPopup(sender: UIButton!) {
        p?.dismiss(animated: true)
    }
    
    @objc func joinSupportGroup(sender: UIButton!) {
        var isError = false
        let connector = Connector()
        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
        let processor = ConnectionProcessor(connector: connector)
        do {
            try processor.processJoinSupportGroup(conversationID: conversation!.getConversationID())
        }
        catch let error {
            isError = true
            print((error as! ConnectionError).getMessage())
        }
        if (!isError) {
            setDisplayName()
        }

    }

    @objc func setDisplayName() {
        let alertController = UIAlertController(title: "Display Name", message: "You must set a name you like displayed for other group members to see.", preferredStyle: .alert)
        // ADD SOME SORT OF CHECKING TO ENSURE THAT THE NAME IS NOT ALREADY TAKEN.....
        // ERROR CHECKING TO KNOW IF IT IS THERE OWN NAME.
        let setNameAction = UIAlertAction(title: "Set Name", style: .default) { (action) in
            CognitoHelper.sharedHelper.setDisplayName(displayName: alertController.textFields![0].text!) { (success) in
                if (success) {
                    self.p?.dismiss(animated: true)
                    self.showJoinAlert()
                } else {
                    // Do something on error
                }
            }
        }
        setNameAction.accessibilityLabel = "Set Name Button"
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.accessibilityLabel = "Cancel Button"
        alertController.addAction(setNameAction)
        alertController.addAction(cancelAction)
        setNameAction.isEnabled = false
        
        alertController.addTextField { (textField) in
            textField.accessibilityLabel = "Display Name Field"
            textField.placeholder = "Enter Display Name"
            
            // This segment of code borrowed from:
            // https://gist.github.com/TheCodedSelf/c4f3984dd9fcc015b3ab2f9f60f8ad51
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                {_ in
                    // Being in this block means that something fired the UITextFieldTextDidChange notification.
                    
                    // Access the textField object from alertController.addTextField(configurationHandler:) above and get the character count of its non whitespace characters
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    
                    // If the text contains non whitespace characters, enable the OK Button
                    setNameAction.isEnabled = textIsNotEmpty
                
            })
            
        }
        
        self.delegate!.present(alertController, animated: true, completion: nil)
    }
    
    func showJoinAlert() {
        let joinAlert = UIAlertController(title: "Support Groups Notice", message: "Support groups are public forums. Do not post anything that you feel should not be shared with other group members.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        okAction.accessibilityLabel = "Ok Button"
        joinAlert.addAction(okAction)
        DispatchQueue.main.async {
            self.delegate!.present(joinAlert, animated: true, completion: nil)
        }
    }
    
}
