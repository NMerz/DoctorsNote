//
//  MessageVC.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/16/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import UIKit

class MessageVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showOutgoingMessage(width: 241, height: 141)
    }

    func showOutgoingMessage(width: CGFloat, height: CGFloat) {
        let bubbleImageSize = CGSize(width: width, height: height)

        let outgoingMessageView = UIImageView(frame:
            CGRect(x: view.frame.width - bubbleImageSize.width - 20,
                   y: view.frame.height - bubbleImageSize.height - 86,
                   width: bubbleImageSize.width,
                   height: bubbleImageSize.height))

        let bubbleImage = UIImage(named: "outgoing-message-bubble")?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                            resizingMode: .stretch)

        outgoingMessageView.image = bubbleImage

        view.addSubview(outgoingMessageView)
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
