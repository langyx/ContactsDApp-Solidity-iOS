//
//  EnclaverHelper.swift
//  
//
//  Created by Yannis LANG on 16/05/2022.
//

import Foundation
import Security

@available(iOS 13, macOS 10.15, *)
struct EnclaverHelper {
    @discardableResult static func makeAndStoreKey(name: String,
                                                   requiresBiometry: Bool = false) throws -> SecKey {
        
        let flags: SecAccessControlCreateFlags = requiresBiometry ? [.privateKeyUsage, .biometryCurrentSet] : .privateKeyUsage
        let access =
        SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                        flags,
                                        nil)!
        let tag = name.data(using: .utf8)!
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag,
                kSecAttrAccessControl as String: access
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        return privateKey
    }
    
    static func loadKey(name: String) -> SecKey? {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecReturnRef as String             : true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)
    }
}

@available(iOS 13, macOS 10.15, *)
extension EnclaverHelper {
    static func cypher(key: SecKey, value: String) throws -> Data {
        guard let publicKey = SecKeyCopyPublicKey(key) else {
            throw(SecError.publicKeyError)
        }
        
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            throw(SecError.algorithmError)
        }
        var error: Unmanaged<CFError>?
        let valueData = value.data(using: .utf8)!
        let cipherValueData = SecKeyCreateEncryptedData(publicKey, algorithm,
                                                        valueData as CFData,
                                                        &error) as Data?
        guard let cipherValueData = cipherValueData else {
            throw (error!.takeRetainedValue() as Error)
        }
        return cipherValueData
    }
    
    static func uncypher(key: SecKey, data: Data) async throws -> String {
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(key, .decrypt, algorithm) else {
            throw(SecError.algorithmError)
        }
        
        do {
            let clearText = try await Task.detached { () throws -> String in
                var error: Unmanaged<CFError>?
                let clearTextData = SecKeyCreateDecryptedData(key,
                                                              algorithm,
                                                              data as CFData,
                                                              &error) as Data?
                guard let clearTextData = clearTextData else {
                    if let error = error {
                        throw(error.takeRetainedValue() as Error)
                    }
                    throw(SecError.cantDecrypt)
                }
                return String(decoding: clearTextData, as: UTF8.self)
            }.value
            return clearText
        }catch{
            throw(error)
        }
    }
}

@available(iOS 13, macOS 10.15, *)
extension EnclaverHelper {
    enum SecError: Error {
        case publicKeyError, algorithmError, cantDecrypt, noSecKey
    }
}
