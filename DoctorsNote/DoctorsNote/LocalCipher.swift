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
    public func getAESFromPass(password: String, username: String) -> Data {
        let newKey = UnsafeMutablePointer<UInt8>.allocate(capacity: 256)
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), password, password.count, username, username.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512), 200000, newKey, 256)
        let localAESKey = Data(bytes: newKey, count: 256)
        return localAESKey
    }
    
    private func getAESFromSecurityQuestions(securityQuestionAnswers: [String], username: String) -> Data {
        let newKey = UnsafeMutablePointer<UInt8>.allocate(capacity: 256)
        var saltValue = [UInt8]()
        for char in username.cString(using: .utf8)! {
            saltValue.append(UInt8(char))
        }
        var combinedEntropy = username
        for answer in securityQuestionAnswers {
            combinedEntropy.append(answer)
        }
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), combinedEntropy, combinedEntropy.count, saltValue, username.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512), 200000, newKey, 256)
        let localAESKey = Data(bytes: newKey, count: 256)
        return localAESKey
    }
    
    public func generateKetSet(password: String, securityQuestionAnswers: [String], username: String) -> (Data, Data, Data) {
        let passwordAESKey = getAESFromPass(password: password, username: username)
        let (privateKeyExport, publicKeyExport) = generateKeyPair()
//        print("privateKeyExport: " + privateKeyExport.base64EncodedString())
        let passwordEncryptedPrivateKey = encryptKeyWithAES(keyExport: privateKeyExport, AESKey: passwordAESKey, iv: username)
        let securityAESKey = getAESFromSecurityQuestions(securityQuestionAnswers: securityQuestionAnswers, username: username)
        let secuiryQuestionEncryptedPrivateKey = encryptKeyWithAES(keyExport: privateKeyExport, AESKey: securityAESKey, iv: username)
        return (passwordEncryptedPrivateKey, secuiryQuestionEncryptedPrivateKey, publicKeyExport)
    }
    
    public func resetKeyPair(securityQuestionAnswers: [String], newPassword: String, username: String, connectionProcessor: ConnectionProcessor) throws {
        let (_, encryptedPrivateKeySQ) = try connectionProcessor.retrieveEncryptedPrivateKeys(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/retrievekeys")
        let AESKey = getAESFromSecurityQuestions(securityQuestionAnswers: securityQuestionAnswers, username: username)
        let keyDecrypter = try MessageCipher(uniqueID: username, localAESKey: AESKey)
        let (decryptedPrivateKey, publicKey) = try keyDecrypter.setAndReturnKeyPair(encryptedPrivateKey: encryptedPrivateKeySQ)
        let encryptedPrivateKeyP = encryptKeyWithAES(keyExport: decryptedPrivateKey, AESKey: getAESFromPass(password: newPassword, username: username), iv: username)
        try connectionProcessor.postKeys(url: "https://o2lufnhpee.execute-api.us-east-2.amazonaws.com/Development/addkeys", privateKeyP: encryptedPrivateKeyP.base64EncodedString(), privateKeyS: encryptedPrivateKeySQ, publicKey: publicKey.base64EncodedString())
    }
    
    private func generateKeyPair() -> (Data, Data) {
        let privateKeyAttributes = [ kSecAttrKeyType: kSecAttrKeyTypeRSA,
        kSecAttrKeySizeInBits: 2048,
        kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ] as [CFString : Any]
        let privateKey = SecKeyCreateRandomKey(privateKeyAttributes as CFDictionary, UnsafeMutablePointer<Unmanaged<CFError>?>.allocate(capacity: 100))!
        var error: Unmanaged<CFError>?
        let cfExportPrivate = SecKeyCopyExternalRepresentation(privateKey, &error)!
        let privateKeyExport = (cfExportPrivate as Data)
        let publicKey = SecKeyCopyPublicKey(privateKey)
        let cfExportPublic = SecKeyCopyExternalRepresentation(publicKey!, &error)!
        let publicKeyExport = (cfExportPublic as Data)
        return (privateKeyExport, publicKeyExport)
    }
    
    private func encryptKeyWithAES(keyExport: Data, AESKey: Data, iv: String) -> Data {
        //var toEncrypt = keyExport.base64EncodedString()
        var toEncrypt = [UInt8](keyExport)
        toEncrypt.reserveCapacity(toEncrypt.count / 128 * 128 + 128)
        let encrypted = UnsafeMutablePointer<UInt8>.allocate(capacity: (toEncrypt.count / 128 * 128 + 128))
        var bytesEncrypted = 0
        let AESKeyUnsafe = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 256)
        _ = AESKey.copyBytes(to: AESKeyUnsafe)
//        print("Pre encryption")
//        print(String(bytes: toEncrypt, encoding: .utf8))
        let encryptReturn = CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES128), CCOptions(), AESKeyUnsafe.baseAddress, kCCKeySizeAES256, iv, toEncrypt, toEncrypt.count / 128 * 128 + 128, encrypted,  (toEncrypt.count / 128 * 128 + 128), &bytesEncrypted)
        if encryptReturn != 0 {
            print("Encryption for key failed with return: " + encryptReturn.description)
        }
        let encryptedKey = Data(bytes: encrypted, count: (toEncrypt.count / 128 * 128 + 128))
//        print("Post encryption and encoding:")
//        print(encryptedKey.base64EncodedString())
        return encryptedKey
    }
    
}
