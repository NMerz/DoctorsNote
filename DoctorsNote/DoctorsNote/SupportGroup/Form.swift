//
//  Form.swift
//  DoctorsNote
//
//  Created by Ariana Zhu on 2/24/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import UIKit

class Form: NSObject {
    @IBOutlet var controls: [FormControl]?
    subscript(_ key: String) -> String? {
        return value(for: key)
    }
    func value(for key: String) -> String? {
        return controls?.first(where: { $0.key == key })?.text
    }
    func clear() {
        controls?.forEach { $0.clear() }
    }
}

@IBDesignable class TextField: UITextField {
    @IBInspectable var key: String?
}
extension TextField: FormControl {
    func clear() {
        text = nil
    }
}
