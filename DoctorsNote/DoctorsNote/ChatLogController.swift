//
//  ChatLogController.swift
//  DoctorsNote
//
//  Created by Sanjana Koka on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//


import UIKit
import AWSMobileClient

//private let reuseIdentifier = "Cell"

class ChatLogController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellId = "cellId"
    private var connectionProcessor = ConnectionProcessor(connector: Connector())
    private var messages = [Message]()
    private var messagesShown = 5
    
    var conversation: Conversation?
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let connector = Connector()
        AWSMobileClient.default().getTokens(connector.setToken(potentialTokens:potentialError:))
        connectionProcessor = ConnectionProcessor(connector: connector)
        let tap = UITapGestureRecognizer(target:self.view,action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        //sendButton.delegate = self
        //messageText.delegate = self as! UITextFieldDelegate
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        

        // Register cell classes
        collectionView.alwaysBounceVertical = true
        collectionView.register(FriendCellM.self, forCellWithReuseIdentifier: cellId)
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView!.collectionViewLayout = layout

        let testString = "Hello, \nWorld!\n test"
        let testMessage = Message(messageID: -1, conversationID: conversation!.getConversationID(), content: (testString.data(using: .utf8))!, contentType: 0)
        // Do any additional setup after loading the view.
        messagesShown = 20;
        do {
            messages = try (connectionProcessor.processMessages(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/messagelist/", conversationID: conversation!.getConversationID(), numberToRetrieve: messagesShown) ?? messages)
            print(messages)
        } catch let error {
            print ((error as! ConnectionError).getMessage())
            print("ERROR!!!!!!!!!!!!")
        }
        
        let item = self.collectionView(self.collectionView, numberOfItemsInSection: 0) - 1
        let lastItemIndex = NSIndexPath(item: item, section: 0)
        self.collectionView.scrollToItem(at: lastItemIndex as IndexPath, at: .top, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Test Title"
    }
    
    // Inspired by: https://medium.com/@andrea.toso/uicollectionviewcell-dynamic-height-swift-b099b28ddd23
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width
        layout.estimatedItemSize = CGSize(width: width, height: 90)
        return layout
    }()
    
    @IBAction
    func ourSendButtonClick() {
        print("Pressed1")
        print (messageText.text!)
        //messages.append(messageText.text!)
        if messageText.text == nil || messageText.text!.isEmpty || (messageText!.text?.data(using: .utf8)) == nil {
            return
        }
        let newMessage = Message(messageID: -1, conversationID: conversation!.getConversationID(), content: (messageText!.text?.data(using: .utf8))!, contentType: 0)//TODO: Needs conversationID to be passed in dynamically based on the current conversation
        print(newMessage.getBase64Content())
        let err = connectionProcessor.processNewMessage(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/messageadd", message: newMessage)
        if (err != nil) {
            let alertController = UIAlertController(title: "Error Sending Message", message: "The message failed to send.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            // Turn this into a reminder eventually because it takes so long to determine that the message failed to send.
            self.present(alertController, animated: true, completion: nil)
        }
        reloadMessages()
        print("Pressed2")
    }
    
    //Credit for how to set up the ImagePickerDelagate goes to: https://www.youtube.com/watch?v=v8r_wD_P3B8
    @IBAction
    func imageSend() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //comment out the line below when using simulator
        //imagePicker.sourceType = .camera
        //imagePicker.allowsEditing = true
        imagePicker.delegate = self
        //imagePicker.sourceType = UIImagePickerController.SourceType.camera
        self.present(imagePicker, animated: false) {
            print("done picking")
        }
    }
    
    //Credit for how to set up the ImagePickerDelagate goes to: https://www.youtube.com/watch?v=v8r_wD_P3B8
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Controller")
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            dismiss(animated: false)
            return
        }
        print("pass guard")
        var quality = 1.0
        var content = image.jpegData(compressionQuality: 1)!
        print(content.base64EncodedString().count)
        while content.base64EncodedString().count > 2000000 { //AWS Gateway maxes out at 10 MB, ensure this is smaller. I was having issues with one of the stock simulator images at 8138448 bytes encoded, but had one working at 6.x MB and everything seems to work under 6MB.
            //Update: Responses max out at 6MB.
            //Note: There is apparent a limit on how far images can be compressed with jpeg and the flowers default image (original size 12MB) cannot be compressed below 1
            quality *= 0.5
            print("Shrinking to:" + String(quality))
            content = image.jpegData(compressionQuality: CGFloat(quality))!
            print(content.base64EncodedString().count)
        }
        let newMessage = Message(messageID: -1, conversationID: conversation!.getConversationID(), content: content, contentType: 1) //TODO: Needs conversationID to be passed in dynamically based on the current conversation

        //print(newMessage.getContent())
        let potentialError = connectionProcessor.processNewMessage(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/messageadd", message: newMessage)
        if (potentialError != nil) {
            print(potentialError?.getMessage())
        }
        dismiss(animated: false)
    }
    
    func reloadMessages() {
        messagesShown += 1
        do {
            messages = try connectionProcessor.processMessages(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/messagelist/", conversationID: conversation!.getConversationID(), numberToRetrieve: messagesShown)
            print(try connectionProcessor.processMessages(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/messagelist/", conversationID: conversation!.getConversationID(), numberToRetrieve: messagesShown))
        } catch let error {
            print ((error as! ConnectionError).getMessage())
            print("ERROR!!!!!!!!!!!!")
        }
        //collectionView.removeFromSuperview()
        collectionView.reloadData()
        //view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellM = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCellM
        cellM.delegate = self
        let nextMessage = self.messages[messages.count - indexPath.row - 1]
        if nextMessage.getContentType() == 0 {
            cellM.showOutgoingMessage(text: String(data: nextMessage.getRawContent(), encoding: .utf8)!)
        } else if nextMessage.getContentType() == 1 {
            cellM.showOutgoingMessage(image: UIImage(data: nextMessage.getRawContent()) ?? UIImage())
        }
        //print("Index path:" + ((indexPath as? String)!))

        return cellM
        // Configure the cell
    }
    
    
    @IBAction func onClick(_ sender: Any) {
        if (conversation?.getConversationName() == "Chat Conversation") {
            performSegue(withIdentifier: "chat", sender: self)
        }
        else {
            performSegue(withIdentifier: "support_group", sender: self)
        }
    }
    
    
//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of items
//        if (messages.count == 0) {
//            return 5
//        }
//        else {
//            return messages.count
//        }
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//        let cellM = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCellM
//        //let convo = Conversation(conversationID: 15)
//        cellM.delegate = self
//        // FIXME: Error with this when message fails to send
//        let nextMessage = self.messages[messages.count - indexPath.row - 1]
//        if nextMessage.getContentType() == 0 {
//            cellM.showOutgoingMessage(text: String(data: nextMessage.getRawContent(), encoding: .utf8)!)
//        } else if nextMessage.getContentType() == 1 {
//            cellM.showOutgoingMessage(image: UIImage(data: nextMessage.getRawContent()) ?? UIImage())
//        }
//        //print("Index path:" + ((indexPath as? String)!))
//
//        return cellM
//        // Configure the cell
//
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = nil
    }

    // Credit to: https://medium.com/@PaulWall43/how-to-raise-a-uitextfield-when-the-keyboard-shows-ccfa6553c911
    @objc func keyboardWillShow(notification: NSNotification) {
       if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if (self.view.frame.origin.y == 0) {
                self.view.frame.origin.y -= keyboardHeight
                self.view.frame.origin.y += (tabBarController?.tabBar.frame.height)!
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if (self.view.frame.origin.y != 0) {
            self.view.frame.origin.y = 0
        }
    }
    
}

/*extension ViewController = UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}*/



class FriendCellM: BaseCellM {
    
    var delegate: ChatLogController?
    var labelView: UILabel? = nil
    
    override func setupViews() {
        
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        contentView.addSubview(message)
        
        message.translatesAutoresizingMaskIntoConstraints = false
        
        message.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        contentView.topAnchor.constraint(greaterThanOrEqualTo: message.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: message.bottomAnchor).isActive = true
        
    }
    
    var message: UIView = {
        let view = UIView()
        return view
    }()
        
    func showOutgoingMessage(text: String) {
        if labelView != nil {
            labelView!.removeFromSuperview()
        }
        labelView =  UILabel()
        let label = labelView!
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.text = text
        
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.rightAnchor.constraint(equalTo: message.rightAnchor, constant: -10).isActive = true
        contentView.topAnchor.constraint(equalTo: label.topAnchor, constant: -10).isActive = true
        contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant:  10).isActive = true

        message.leftAnchor.constraint(equalTo: label.leftAnchor, constant: -10).isActive = true
        
        let constraintRect = CGSize(width: 0.66 * message.frame.width,
                                    height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: label.font],
                                            context: nil)
        label.frame.size = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
        
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
        outgoingMessageLayer.frame = label.bounds
        outgoingMessageLayer.fillColor = UIColor.systemBlue.cgColor
        
        message.layer.addSublayer(outgoingMessageLayer)

    }
    
    func showOutgoingMessage(image: UIImage) {
        if labelView != nil {
            labelView!.removeFromSuperview()
        }
        labelView =  UILabel()
        let label = labelView!
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        contentView.topAnchor.constraint(equalTo: label.topAnchor, constant: -10).isActive = true
        contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant:  10).isActive = true
        
        
        //Image embedding from https://jayeshkawli.ghost.io/add-image-to-uilabel-with-swift-ios/
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        
        message.leftAnchor.constraint(equalTo: label.leftAnchor, constant: -10).isActive = true
        
        let constraintRect = CGSize(width: 0.66 * message.frame.width,
                                    height: .greatestFiniteMagnitude)
        imageAttachment.bounds = CGRect(origin: label.center, size: CGSize(width: 200, height: 100))
        
        label.attributedText = NSAttributedString(attachment: imageAttachment)
        
        let boundingBox = imageAttachment.bounds/*(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: label.font],
                                            context: nil)*/
        label.frame.size = CGSize(width: ceil(boundingBox.width),
                                  height: ceil(boundingBox.height))
        
        let bubbleSize = CGSize(width: label.frame.width + 28,
                                     height: label.frame.height + 20)
        
        let width = bubbleSize.width
        let height = bubbleSize.height

//        let bezierPath = UIBezierPath()
//        bezierPath.move(to: CGPoint(x: width - 22, y: height))
//        bezierPath.addLine(to: CGPoint(x: 17, y: height))
//        bezierPath.addCurve(to: CGPoint(x: 0, y: height - 17), controlPoint1: CGPoint(x: 7.61, y: height), controlPoint2: CGPoint(x: 0, y: height - 7.61))
//        bezierPath.addLine(to: CGPoint(x: 0, y: 17))
//        bezierPath.addCurve(to: CGPoint(x: 17, y: 0), controlPoint1: CGPoint(x: 0, y: 7.61), controlPoint2: CGPoint(x: 7.61, y: 0))
//        bezierPath.addLine(to: CGPoint(x: width - 21, y: 0))
//        bezierPath.addCurve(to: CGPoint(x: width - 4, y: 17), controlPoint1: CGPoint(x: width - 11.61, y: 0), controlPoint2: CGPoint(x: width - 4, y: 7.61))
//        bezierPath.addLine(to: CGPoint(x: width - 4, y: height - 11))
//        bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width - 4, y: height - 1), controlPoint2: CGPoint(x: width, y: height))
//        bezierPath.addLine(to: CGPoint(x: width + 0.05, y: height - 0.01))
//        bezierPath.addCurve(to: CGPoint(x: width - 11.04, y: height - 4.04), controlPoint1: CGPoint(x: width - 4.07, y: height + 0.43), controlPoint2: CGPoint(x: width - 8.16, y: height - 1.06))
//        bezierPath.addCurve(to: CGPoint(x: width - 22, y: height), controlPoint1: CGPoint(x: width - 16, y: height), controlPoint2: CGPoint(x: width - 19, y: height))
//        bezierPath.close()
        
//        let outgoingMessageLayer = CAShapeLayer()
//        outgoingMessageLayer.path = bezierPath.cgPath
//        outgoingMessageLayer.frame = label.bounds
        
        let outgoingMessageLayer = CAShapeLayer()
        outgoingMessageLayer.path = UIBezierPath(roundedRect: label.bounds, cornerRadius: 10).cgPath
        outgoingMessageLayer.fillColor = UIColor.systemBlue.cgColor
        label.layer.mask = outgoingMessageLayer
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelView?.text = ""
        labelView?.layer.mask = nil
        message.layer.mask = nil
        let x = labelView!.bounds.minX
        let y = labelView!.bounds.minY
        message.bounds = CGRect(x: x, y: y, width: 0, height: 0)
        labelView?.bounds = CGRect()
    }
    
}

class BaseCellM: UICollectionViewCell {
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 90))
    }
    
    func setupViews() {
    }
}
