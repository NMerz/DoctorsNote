//
//  MessageCollectionVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/16/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import UIKit

//private let reuseIdentifier = "Cell"

class MessageCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
        private let cellId = "cellId"
        
        /*var friend: Friend? {
            didSet {
                navigationItem.title = friend?.name
                
                messages = friend?.messages?.allObjects as? [Message]
                
                messages = messages?.sort(by: {$0.date!.compare($1.date!) == .OrderedAscending})
            }
        }*/
        
        var messages: [Message]?
        
        let messageInputContainerView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.white
            return view
        }()
        
        let inputTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Enter message..."
            return textField
        }()
        
        lazy var sendButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Send", for: [])
            let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
            button.setTitleColor(titleColor, for: [])
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            //button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
            return button
        }()
        
   /* @objc func handleSend() {
            print(inputTextField.text)
            
        let delegate = UIApplication.sharedApplication.delegate as! AppDelegate
            let context = delegate.managedObjectContext
            
            let message = FriendsController.createMessageWithText(inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
            
            do {
                try context.save()
                
                messages?.append(message)
                
                let item = messages!.count - 1
                let insertionIndexPath = NSIndexPath(forItem: item, inSection: 0)
                
                collectionView?.insertItemsAtIndexPaths([insertionIndexPath])
                collectionView?.scrollToItemAtIndexPath(insertionIndexPath, atScrollPosition: .Bottom, animated: true)
                inputTextField.text = nil
                
            } catch let err {
                print(err)
            }
        }*/
        
        var bottomConstraint: NSLayoutConstraint?
        
        /*func simulate() {
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = delegate.managedObjectContext
            let message = FriendsController.createMessageWithText("Here's a text message that was sent a few minutes ago...", friend: friend!, minutesAgo: 1, context: context)
            
            do {
                try context.save()
                
                messages?.append(message)
                
                messages = messages?.sort({$0.date!.compare($1.date!) == .OrderedAscending})
                
                if let item = messages?.indexOf(message) {
                    let receivingIndexPath = NSIndexPath(forItem: item, inSection: 0)
                    collectionView?.insertItemsAtIndexPaths([receivingIndexPath])
                }
                
            } catch let err {
                print(err)
            }
            
        }*/
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .Plain, target: self, action: #selector(simulate))
            
            tabBarController?.tabBar.isHidden = true
            
            collectionView?.backgroundColor = UIColor.white
            
           /* collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)*/
            
            view.addSubview(messageInputContainerView)
            view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
            view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
            
            bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            view.addConstraint(bottomConstraint!)
            
            //setupInputComponents()
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
    @objc func handleKeyboardNotification(notification: NSNotification) {
            
            if let userInfo = notification.userInfo {
                
                let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]) /*as AnyObject).CGRectValue()*/
                print(keyboardFrame)
                
                let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
                
                bottomConstraint?.constant = CGFloat(isKeyboardShowing ? -(keyboardFrame! as AnyObject).height : 0)
                
                UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    
                    self.view.layoutIfNeeded()
                    
                    }, completion: { (completed) in
                        
                        if isKeyboardShowing {
                            let indexPath = NSIndexPath(item: self.messages!.count - 1, section: 0)
                            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                        }
                        
                })
            }
        }
        
        /*override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            inputTextField.endEditing(true)
        }*/
        
        /*private func setupInputComponents() {
            let topBorderView = UIView()
            topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
            
            messageInputContainerView.addSubview(inputTextField)
            messageInputContainerView.addSubview(sendButton)
            messageInputContainerView.addSubview(topBorderView)
            
            messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
            
            messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
            messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
            
            messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
            messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)
        }*/
        
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if let count = messages?.count {
                return count
            }
            return 0
        }
        
        /*override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            /*let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! ChatLogMessageCell
            
            cell.messageTextView.text = messages?[indexPath.item].text
            
            if let message = messages?[indexPath.item], let messageText = message.text, let profileImageName = message.friend.profileImageName {
                
                cell.profileImageView.image = UIImage(named: profileImageName)
                
                let size = CGSizeMake(250, 1000)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: messageText).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(18)], context: nil)
                
                if message.isSender == nil || !message.isSender!.boolValue {
                    cell.messageTextView.frame = CGRectMake(48 + 8, 0, estimatedFrame.width + 16, estimatedFrame.height + 20)
                    
                    cell.textBubbleView.frame = CGRectMake(48 - 10, -4, estimatedFrame.width + 16 + 8 + 16, estimatedFrame.height + 20 + 6)
                    
                    cell.profileImageView.hidden = false
                    
    //                cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                    cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
                    cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                    cell.messageTextView.textColor = UIColor.blackColor()
                    
                } else {
                    
                    //outgoing sending message
                    
                    cell.messageTextView.frame = CGRectMake(view.frame.width - estimatedFrame.width - 16 - 16 - 8, 0, estimatedFrame.width + 16, estimatedFrame.height + 20)
                    
                    cell.textBubbleView.frame = CGRectMake(view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10, -4, estimatedFrame.width + 16 + 8 + 10, estimatedFrame.height + 20 + 6)
                    
                    cell.profileImageView.hidden = true
                    
    //                cell.textBubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                    cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                    cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                    cell.messageTextView.textColor = UIColor.whiteColor()*/
            //return cell
             showOutgoingMessage(text: "An arbitrary text which we use to demonstrate how our label sizes' calculation works.")
        }
        /*override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                showOutgoingMessage(text: "An arbitrary text which we use to demonstrate how our label sizes' calculation works.")
                
                //showIncomingMessage()
            }*/
            
            func showIncomingMessage() {
                let width: CGFloat = 0.66 * view.frame.width
                let height: CGFloat = width / 0.75
                
                let bezierPath = UIBezierPath()
                bezierPath.move(to: CGPoint(x: 22, y: height))
                bezierPath.addLine(to: CGPoint(x: width - 17, y: height))
                bezierPath.addCurve(to: CGPoint(x: width, y: height - 17), controlPoint1: CGPoint(x: width - 7.61, y: height), controlPoint2: CGPoint(x: width, y: height - 7.61))
                bezierPath.addLine(to: CGPoint(x: width, y: 17))
                bezierPath.addCurve(to: CGPoint(x: width - 17, y: 0), controlPoint1: CGPoint(x: width, y: 7.61), controlPoint2: CGPoint(x: width - 7.61, y: 0))
                bezierPath.addLine(to: CGPoint(x: 21, y: 0))
                bezierPath.addCurve(to: CGPoint(x: 4, y: 17), controlPoint1: CGPoint(x: 11.61, y: 0), controlPoint2: CGPoint(x: 4, y: 7.61))
                bezierPath.addLine(to: CGPoint(x: 4, y: height - 11))
                bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 4, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
                bezierPath.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
                bezierPath.addCurve(to: CGPoint(x: 11.04, y: height - 4.04), controlPoint1: CGPoint(x: 4.07, y: height + 0.43), controlPoint2: CGPoint(x: 8.16, y: height - 1.06))
                bezierPath.addCurve(to: CGPoint(x: 22, y: height), controlPoint1: CGPoint(x: 16, y: height), controlPoint2: CGPoint(x: 19, y: height))
                bezierPath.close()
                
                let incomingMessageLayer = CAShapeLayer()
                incomingMessageLayer.path = bezierPath.cgPath
                incomingMessageLayer.frame = CGRect(x: 0,
                                                    y: 0,
                                                    width: width,
                                                    height: height)
                
                let imageView = UIImageView(image: UIImage(named: "alpaca"))
                imageView.frame.size = CGSize(width: width, height: height)
                imageView.center = view.center
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layer.mask = incomingMessageLayer
                
                view.addSubview(imageView)
            }
            
            func showOutgoingMessage(text: String) {
                let label =  UILabel()
                label.numberOfLines = 0
                label.font = UIFont.systemFont(ofSize: 18)
                label.textColor = .white
                label.text = text
                
                let constraintRect = CGSize(width: 0.66 * view.frame.width,
                                            height: .greatestFiniteMagnitude)
                let boundingBox = text.boundingRect(with: constraintRect,
                                                    options: .usesLineFragmentOrigin,
                                                    attributes: [.font: label.font],
                                                    context: nil)
                label.frame.size = CGSize(width: ceil(boundingBox.width),
                                          height: ceil(boundingBox.height))
                
                let bubbleSize = CGSize(width: label.frame.width + 28,
                                             height: label.frame.height + 20)
                
                let width = bubbleSize.width
                let height = bubbleSize.height
                
                let bezierPath = UIBezierPath()
                bezierPath.move(to: CGPoint(x: width - 22, y: height))
                bezierPath.addLine(to: CGPoint(x: 17, y: height))
                bezierPath.addCurve(to: CGPoint(x: 0, y: height - 17), controlPoint1: CGPoint(x: 7.61, y: height), controlPoint2: CGPoint(x: 0, y: height - 7.61))
                bezierPath.addLine(to: CGPoint(x: 0, y: 17))
                bezierPath.addCurve(to: CGPoint(x: 17, y: 0), controlPoint1: CGPoint(x: 0, y: 7.61), controlPoint2: CGPoint(x: 7.61, y: 0))
                bezierPath.addLine(to: CGPoint(x: width - 21, y: 0))
                bezierPath.addCurve(to: CGPoint(x: width - 4, y: 17), controlPoint1: CGPoint(x: width - 11.61, y: 0), controlPoint2: CGPoint(x: width - 4, y: 7.61))
                bezierPath.addLine(to: CGPoint(x: width - 4, y: height - 11))
                bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width - 4, y: height - 1), controlPoint2: CGPoint(x: width, y: height))
                bezierPath.addLine(to: CGPoint(x: width + 0.05, y: height - 0.01))
                bezierPath.addCurve(to: CGPoint(x: width - 11.04, y: height - 4.04), controlPoint1: CGPoint(x: width - 4.07, y: height + 0.43), controlPoint2: CGPoint(x: width - 8.16, y: height - 1.06))
                bezierPath.addCurve(to: CGPoint(x: width - 22, y: height), controlPoint1: CGPoint(x: width - 16, y: height), controlPoint2: CGPoint(x: width - 19, y: height))
                bezierPath.close()
                
                let outgoingMessageLayer = CAShapeLayer()
                outgoingMessageLayer.path = bezierPath.cgPath
                outgoingMessageLayer.frame = CGRect(x: view.frame.width/2 - width/2,
                                                    y: view.frame.height/2 - height/2,
                                                    width: width,
                                                    height: height)
                outgoingMessageLayer.fillColor = UIColor(red: 0.09, green: 0.54, blue: 1, alpha: 1).cgColor
                
                view.layer.addSublayer(outgoingMessageLayer)
                
                label.center = view.center
                view.addSubview(label)
            }
                //return cell
                
}
            
            //return cell

        
        /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            if let messageText = messages?[indexPath.item].text {
                let size = CGSizeMake(250, 1000)
                let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
                let estimatedFrame = NSString(string: messageText).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(18)], context: nil)
                
                return CGSizeMake(view.frame.width, estimatedFrame.height + 20)
            }
            
            return CGSizeMake(view.frame.width, 100)
        }
        
        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsetsMake(8, 0, 0, 0)
        }
        
    }

    class ChatLogMessageCell: BaseCell {
        
        let messageTextView: UITextView = {
            let textView = UITextView()
            textView.font = UIFont.systemFontOfSize(18)
            textView.text = "Sample message"
            textView.backgroundColor = UIColor.clearColor()
            return textView
        }()
        
        let textBubbleView: UIView = {
            let view = UIView()
    //        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
            view.layer.cornerRadius = 15
            view.layer.masksToBounds = true
            return view
        }()
        
        let profileImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .ScaleAspectFill
            imageView.layer.cornerRadius = 15
            imageView.layer.masksToBounds = true
            return imageView
        }()
        
        static let grayBubbleImage = UIImage(named: "bubble_gray")!.resizableImageWithCapInsets(UIEdgeInsetsMake(22, 26, 22, 26)).imageWithRenderingMode(.AlwaysTemplate)
        static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImageWithCapInsets(UIEdgeInsetsMake(22, 26, 22, 26)).imageWithRenderingMode(.AlwaysTemplate)
        
        let bubbleImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = ChatLogMessageCell.grayBubbleImage
            imageView.tintColor = UIColor(white: 0.90, alpha: 1)
            return imageView
        }()
        
        override func setupViews() {
            super.setupViews()
            
            addSubview(textBubbleView)
            addSubview(messageTextView)
            
            addSubview(profileImageView)
            addConstraintsWithFormat("H:|-8-[v0(30)]", views: profileImageView)
            addConstraintsWithFormat("V:[v0(30)]|", views: profileImageView)
            profileImageView.backgroundColor = UIColor.redColor()
            
            textBubbleView.addSubview(bubbleImageView)
            textBubbleView.addConstraintsWithFormat("H:|[v0]|", views: bubbleImageView)
            textBubbleView.addConstraintsWithFormat("V:|[v0]|", views: bubbleImageView)
        }*/
*/
}
