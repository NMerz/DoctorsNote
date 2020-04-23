//
//  ConversationViewController.swift
//  DoctorsNote
//
//  Created by Sanjana Koka on 2/15/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit
import AWSMobileClient

//private let reuseIdentifier = "Cell"

class ConversationViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {
    
    var activityIndicator = UIActivityIndicatorView()
    private let cellId = "cellId"
    private var conversationList: [Conversation]?
    private var filteredConversationList: [Conversation]?
    let searchController = UISearchController(searchResultsController: nil)
    var selectedConversation: Conversation?
    var selectedName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.style = .gray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Chats"
        navigationItem.searchController = searchController
        
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceVertical = true
        collectionView.register(FriendCell.self, forCellWithReuseIdentifier: cellId)
        
        self.activityIndicator.startAnimating()
        DispatchQueue.main.async {
            let authorizedConnector = Connector()
            AWSMobileClient.default().getTokens(authorizedConnector.setToken(potentialTokens:potentialError:))
            var tempList: [Conversation]?
            let processor : ConnectionProcessor = ConnectionProcessor(connector: authorizedConnector)
            (tempList, _) = processor.processConversationList(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/ConversationList")
            
            // Filter conversations to include only patient-doctor conversations
            self.conversationList = []
            if (tempList != nil && tempList!.count > 0) {
                for i in 0...tempList!.count - 1 {
                    if (tempList![i].getConverserID() != "N/A") {
                        self.conversationList?.append(tempList![i])
                    }
                }
            }
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.activityIndicator.stopAnimating()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredConversationList = conversationList!.filter({( conversation : Conversation) -> Bool in
            let searched = searchController.searchBar.text!.lowercased()
            let inName = conversation.getConversationName().lowercased().contains(searched)
            return inName
        })
        collectionView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print(conversationList?.count)
        if (isFiltering()) {
            return filteredConversationList!.count
        } else {
            if let l = conversationList {
                print("Count is: ", l.count)
                return l.count
            } else {
                print("NO ELEMENTS!")
                return 0
            }
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCell
        cell.delegate = self
        
        do {
            let authorizedConnector = Connector()
            AWSMobileClient.default().getTokens(authorizedConnector.setToken(potentialTokens:potentialError:))
            var tempList: [Conversation]?
            let processor : ConnectionProcessor = ConnectionProcessor(connector: authorizedConnector)
            let user = try processor.processUserInformation(uid: conversationList![indexPath.row].getConverserID())
            selectedName = user!.getFirstName() + " " + user!.getLastName()
            cell.nameLabel.text = selectedName
        } catch {
            cell.nameLabel.text = "Unknown"
            print("Error getting user from id")
        }
        
        let df = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(conversationList![indexPath.row].getLastMessageTime()) {
            df.dateFormat = "hh:mm"
        }
        else {
            df.dateFormat = "MM-dd-YYYY"
        }
        cell.timeLabel.text = df.string(from: conversationList![indexPath.row].getLastMessageTime())
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.activityIndicator.startAnimating()
        self.selectedConversation = conversationList![indexPath.row]
        self.performSegue(withIdentifier: "open_chat", sender: self)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "open_chat") {
            let dest = segue.destination as! ChatLogController
            dest.conversation = selectedConversation
            dest.converserName = selectedName
        }
    }
    
}

class FriendCell: BaseCellC {
    
    var delegate: ConversationViewController?
    var conversationID: Int?
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Doctor"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "       "
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:05 pm"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    let hasReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setupViews() {
        
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        profileImageView.image = UIImage(named: "doctor")
       // hasReadImageView.image = UIImage(named: "doctor")
        
        addConstraintsWithFormat(format: "H:|-12-[v0(68)]", views: profileImageView)
        
        addConstraintsWithFormat(format: "V:[v0(68)]", views: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat(format: "H:|-82-[v0]|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: dividerLineView)
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if(sender.state == .ended) {
            self.delegate!.performSegue(withIdentifier: "open_chat", sender: self.delegate!)
        }
    }
    
    private func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)
        addConstraintsWithFormat(format: "H:|-90-[v0]|", views: containerView)
        addConstraintsWithFormat(format: "V:[v0(50)]", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        containerView.addConstraintsWithFormat(format: "H:|[v0][v1(180)]-12-|", views: nameLabel, timeLabel)
        
        containerView.addConstraintsWithFormat(format: "V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        
        containerView.addConstraintsWithFormat(format: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
        
        containerView.addConstraintsWithFormat(format: "V:|[v0(24)]", views: timeLabel)
        
        containerView.addConstraintsWithFormat(format: "V:[v0(20)]|", views: hasReadImageView)
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
//        self.addGestureRecognizer(tapRecognizer)

    }
    
}

extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        //used to be views.enumerate()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
}

class BaseCellC: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = UIColor.blue
    }
}
