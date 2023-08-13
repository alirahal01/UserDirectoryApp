//
//  EncrpytionManager.swift
//  UserDirectory
//
//  Created by ali rahal on 13/08/2023.
//

import Foundation
import CryptoKit

class EncryptionManager {
    
    static let shared = EncryptionManager()
    
    public func encryptData(data: Data, key: SymmetricKey) -> Data? {
        do {
            let nonce = AES.GCM.Nonce()
            let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
            return sealedBox.combined
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    public func decryptData(data: Data, key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return decryptedData
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
}
