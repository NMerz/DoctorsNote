//
//  LocalCipher.swift
//  DoctorsNote
//
//  Created by Merz on 4/12/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

class LocalCipher {
    
    //getAESFromSecQ(q1, q2 ...) //Cat all into string then run string through PBKDF
    
    func getAESFromPass(password: String, username: String) -> Data {
        let saltData = username.data(using: .utf8)!
        var newKey = UnsafeMutablePointer<UInt8>.allocate(capacity: 256)
        var saltValue = [UInt8]()
        for char in username.cString(using: .utf8)! {
            saltValue.append(UInt8(char))
        }
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), password, password.count, saltValue, username.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512), 200000, newKey, 256)
        let localAESKey = Data(bytes: newKey, count: 256)
        return localAESKey
    }
}
