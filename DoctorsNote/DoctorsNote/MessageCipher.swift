//
//  MessageCipher.swift
//  DoctorsNote
//
//  Created by Merz on 4/12/20.
//  Copyright © 2020 Team7. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

class MessageCipher {
    private let localAESKey: Data
    
    private var saltValue: [UInt8]
    
    private var privateKey: SecKey? = nil
    private var publicKey: SecKey? = nil
    
    init(uniqueID: String, localAESKey: Data) {
        self.localAESKey = localAESKey
        saltValue = [UInt8]()
        for char in uniqueID.cString(using: .utf8)! {
            saltValue.append(UInt8(char))
        }
    }
    
    //Input: Private key data in base64 format -> encrypted -> base64 String
    public func setPrivateKey(encryptedPrivateKey: String) throws {
        if Data(base64Encoded: encryptedPrivateKey) == nil {
            throw CipherError(message: "Input key is note base64 encoded")
        }
        let toDecryptData = Data(base64Encoded: encryptedPrivateKey)!
        let toDecrypt = String(data: toDecryptData, encoding: .utf8)!
        
        let baseDecrypt = try decodePrivateKey(toDecrypt: toDecrypt)
        let decryptedText = Data(base64Encoded: baseDecrypt)!
        print(decryptedText.base64EncodedString())
        var unmanagedError: Unmanaged<CFError>? = nil
        let attributes = [ kSecAttrKeyType: kSecAttrKeyTypeRSA,
        kSecAttrKeySizeInBits: 2048,
        kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ] as [CFString : Any]
        let newPrivateKey = SecKeyCreateWithData(decryptedText as CFData, attributes as CFDictionary, UnsafeMutablePointer<Unmanaged<CFError>?>(&unmanagedError))
        privateKey = newPrivateKey
    }
    
    public func decodePrivateKey(toDecrypt: String) throws -> String  {
        let decrypted = UnsafeMutablePointer<UInt8>.allocate(capacity: (toDecrypt.count / 128 * 128 + 128))
        var bytesEncrypted = 0
        var AESKey = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 256)
        localAESKey.copyBytes(to: AESKey)
        let decryptReturn = CCCrypt(CCOperation(kCCDecrypt), CCAlgorithm(kCCAlgorithmAES128), CCOptions(), AESKey.baseAddress, kCCKeySizeAES256, saltValue, toDecrypt, (toDecrypt.count / 128 * 128 + 128), decrypted,  (toDecrypt.count / 128 * 128 + 128), &bytesEncrypted) //Note: this currently takes a nonbase64 data object, but the return from the API will be in base64. I just have to remember to use the base64 interpretation on it
        //To expand on the above: Export -> Base64->encode->base64->store->retrieve->non-base64->decode->nonbase64->import
        
        print("Decrypt return:")
        print(decryptReturn)
        let decryptedText = Data(bytes: decrypted, count: toDecrypt.count)
        
        print(decryptedText.base64EncodedString())
        return String(data:decryptedText, encoding: .utf8)!
    }
    
    public func decrypt(toDecrypt: String) throws -> String  {
        if privateKey == nil {
            throw CipherError(message: "Private key not set.")
        }
        return String(data: SecKeyCreateDecryptedData(privateKey!, .rsaEncryptionOAEPSHA512, toDecrypt as! CFData, nil)! as Data, encoding: .utf8)!
    }
    
    public func encrypt(toEncrypt: String) throws -> Data {
        if publicKey == nil {
            throw CipherError(message: "Public key not set.")
        }
        return SecKeyCreateEncryptedData(privateKey!, .rsaEncryptionOAEPSHA512, toEncrypt as! CFData, nil)! as Data
    }

}

class CipherError : Error {
    private let message: String
    init(message: String) {
        self.message = message
    }
    func getMessage() -> String {
        return message
    }
}
