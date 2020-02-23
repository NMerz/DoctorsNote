//
//  MessageCollectionVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/16/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MessageCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    var person: Person? {
        didSet {
              // Set navigation title and person-specific info here
        }
    }
    
    
    // Message text input container view
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    // Text field
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()

    var bottomConstraint: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
//        self.title = "Name"
        navigationItem.title = "Name"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView!.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        // Add subview for text input
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        // 765 for padding from top
        view.addConstraintsWithFormat(format: "V:|-765-[v0(48)]", views: messageInputContainerView)
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView , attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponents()
        
        // Listener for when keyboard shows up in text field, NSNotificationCenter?
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frameInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            let keyboardFrame = frameInfo?.cgRectValue
            
            // Text field goes negative height value from bottom
            bottomConstraint?.constant = -keyboardFrame!.height
        }
    }
    
    
    // Setup input text field
    private func setupInputComponents() {
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    /*override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/
    
    


    // Returns number of messages
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // TODO get message cells on separate line, left justify
        return 1
    }

    // Returns cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        // TODO fix dynamic height
        let width = Int(cell.messageTextView.text.count) % 30
        // let messageWidth = view.frame.width
        let messageWidth = width * 30
        if width != 0 {
            let messageHeight = CGFloat(((Int(cell.messageTextView.text.count) / 30) + 1) * 30)
            
            // 8 is left and right padding for text, 48 for profile image
            cell.messageTextView.frame = CGRect(x: 8+48, y: 0, width: 250, height: 100)
            cell.textBubbleView.frame = CGRect(x: 48, y: 0, width: 250+8, height: 100)
        }
        else {
            let height = CGFloat(Int(cell.messageTextView.text.count))

            cell.messageTextView.frame = CGRect(x: 8+48, y: 0, width: 250, height: 100)
            cell.textBubbleView.frame = CGRect(x: 48, y: 0, width: 250+8, height: 100)
        }


        // Configure the cell
        return cell
    }
    
    // Size of message cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let height: CGFloat = 100
        // TODO fix dynamic height
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        // Round message length up to nearest 30, aka length of row
        let width = Int(cell.messageTextView.text.count) % 30
        // let messageWidth = view.frame.width
        let messageWidth = CGFloat(width * 30)

        if width != 0 {
            let messageHeight = CGFloat(((Int(cell.messageTextView.text.count) / 30) + 1) * 30)
            return CGSize(250, 100) // width, height
        }
        else {
            let height = CGFloat(Int(cell.messageTextView.text.count))
            return CGSize(250, 100) // width, height
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}

class MessageCell: BaseCell {
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        //backgroundColor = UIColor.lightGray
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView )
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]|", views: profileImageView)
        addConstraintsWithFormat(format: "V:|[v0(30)]|", views: profileImageView)
        profileImageView.backgroundColor = UIColor.lightGray

    }
}
