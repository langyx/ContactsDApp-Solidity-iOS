//
//  KeyStore+Address.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 16/05/2022.
//

import Foundation
import web3swift

extension KeystoreManager: Equatable{
    public static func == (lhs: KeystoreManager, rhs: KeystoreManager) -> Bool {
        lhs.addresses?.count == rhs.addresses?.count
    }
}

extension KeystoreManager {
    enum KeyStoreError: Error {
        case noAddress
    }
}

extension KeystoreManager {
    var mainAddress: EthereumAddress? {
        addresses?.first
    }
}
