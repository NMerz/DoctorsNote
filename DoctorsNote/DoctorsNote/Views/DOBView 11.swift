//
//  DOBView.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/15/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import UIKit

class DOBView: UIView {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet var backgroundView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("DOBView", owner: self, options: nil)
        self.addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        doneButton.layer.cornerRadius = doneButton.frame.height / 2
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}
