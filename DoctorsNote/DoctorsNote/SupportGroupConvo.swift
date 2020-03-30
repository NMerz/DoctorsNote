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

class SupportGroupConvo: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {
    
    
    private let cellId = "cellId"
    private var conversationList: [Conversation]?
    private var filteredConversationList: [Conversation]?
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let convo1 = Conversation(conversationID: 5, conversationPartner: User(uid: 4, firstName: "your mom", lastName: "", dateOfBirth: "", address: "", healthSystems: nil), lastMessageTime: Date(), unreadMessages: false)
//        let convo2 = Conversation(conversationID: 5, conversationPartner: "Your Other Mom", lastMessageTime: Date(), unreadMessages: false)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Chats"
        navigationItem.searchController = searchController
        
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceVertical = true
        collectionView.register(FriendCellS.self, forCellWithReuseIdentifier: cellId)
        
         let authorizedConnector = Connector()
         AWSMobileClient.default().getTokens(authorizedConnector.setToken(potentialTokens:potentialError:))
        let processor : ConnectionProcessor = ConnectionProcessor(connector: authorizedConnector)
        (conversationList, _) = processor.processConversationList(url: "https://ro9koaka0l.execute-api.us-east-2.amazonaws.com/deploy/APITest") //{
        //}
        //print(conversationList)
        //print("The count is: ", conversationList?.count)
        //super.present(MessageCollectionVC(), animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredConversationList = conversationList!.filter({( conversation : Conversation) -> Bool in
            let searched = searchController.searchBar.text!.lowercased()
            let authorizedConnector = Connector()
             AWSMobileClient.default().getTokens(authorizedConnector.setToken(potentialTokens:potentialError:))
            let processor = ConnectionProcessor(connector: authorizedConnector)
            let (potentialUser, potentialError) = processor.processUser(url: "tdb", uid: conversation.getConverserID())
            if potentialError != nil {
                //TODO: handle this error
                //Must return if this is reached!
                return false
            }
            let user = potentialUser!
            let inFirstName = user.getFirstName().contains(searched)
            let inLastName = user.getLastName().contains(searched)
            return (inFirstName || inLastName)
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
        return 4
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCellS
        cell.delegate = self
        cell.conversationID = 16
        //cell.conversationID = conversationList![indexPath.row].getConversationID()
        /*cell.nameLabel.text = conversationList![indexPath.row].getConversationPartner().getFirstName() + " " + conversationList![indexPath.row].getConversationPartner().getLastName()*/
        
//        let df = DateFormatter()
//        let calendar = Calendar.current
//        if calendar.isDateInToday(conversationList![indexPath.row].getLastMessageTime()) {
//            df.dateFormat = "hh:mm"
//        }
//        else {
//            df.dateFormat = "MM-dd-YYYY"
//        }
//        cell.timeLabel.text = df.string(from: conversationList![indexPath.row].getLastMessageTime())
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100.0)
    }
    
//    func switchVC(ViewController: UIViewController) {
//        self.present(UIViewController(), animated: true)
//    }
    
   /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "") {
            // TODO: Update later
            let dest = segue.destination as! ChatLogController
            dest.conversationID = 15
            let path = collectionView.indexPathsForSelectedItems
            //dest.conversationID = conversationList![path![0].row].getConversationID()
            //segue.destination.title = conversationList![0].getConversationPartner().getFirstName()
        }
    }*/
    
}

class FriendCellS: BaseCellC {
    
    var delegate: SupportGroupConvo?
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
    
    let nameLabel: UILabel = {
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
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.addGestureRecognizer(tapRecognizer)

    }
    
}

/*extension UIView {
    
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

class BaseCellS: UICollectionViewCell {
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
}*/
