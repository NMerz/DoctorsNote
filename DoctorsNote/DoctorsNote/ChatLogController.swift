//
//  ChatLogController.swift
//  DoctorsNote
//
//  Created by Sanjana Koka on 2/28/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout{

    private let cellId = "cellId"
    
    /*override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.register(FriendCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
    }*/
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        collectionView.alwaysBounceVertical = true
        collectionView.register(FriendCellM.self, forCellWithReuseIdentifier: cellId)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 4
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let cellM = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCellM
        cellM.delegate = self
        cellM.setupViews()
        cellM.showOutgoingMessage(text: "TEST")
        return cellM
        // Configure the cell
    
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
        //return CGSize(width: 250.0, height: 200.0)
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

class FriendCellM: BaseCellM {
    
    var delegate: ChatLogController?
    
    
    override func setupViews() {
        
        //addSubview(profileImageView)
        //addSubview(dividerLineView)
        addSubview(message)
        setupContainerView()
        
       // hasReadImageView.image = UIImage(named: "doctor")
        
        
    }
    
    
    private func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)
        addSubview(message)
        
        //containerView.addConstraintsWithFormat(format: "V:|[v0][v1(24)]|", views: message)
        //showOutgoingMessage(text: "adjslfsdgkdkg")
        //showOutgoingMessage(text: "TEST")
    }
    
    let message: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.blue
        //view.layer.masksToBounds = true
        
        return view
    }()
        
        func showOutgoingMessage(text: String) {
            let label =  UILabel()
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 18)
            label.textColor = .white
            label.text = text
            
            let constraintRect = CGSize(width: 0.66 * message.frame.width,
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
            outgoingMessageLayer.frame = CGRect(x: message.frame.width/2 - width/2,
                                                y: message.frame.height/2 - height/2,
                                                width: width,
                                                height: height)
            outgoingMessageLayer.fillColor = UIColor(red: 0.09, green: 0.54, blue: 1, alpha: 1).cgColor
            
            message.layer.addSublayer(outgoingMessageLayer)
            
            label.center = message.center
            message.addSubview(label)
        }
    
}

class BaseCellM: UICollectionViewCell {
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
