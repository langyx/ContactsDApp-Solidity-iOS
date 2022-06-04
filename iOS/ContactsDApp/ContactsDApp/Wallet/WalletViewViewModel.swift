//
//  WalletViewViewModel.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 16/05/2022.
//

import Foundation
import web3swift
import YLKSecurity

@MainActor
class WalletImportViewViewModel: ObservableObject{
    @Published var working = false
    @Published var stateMessage = ""
    @Published var newPrivateKey = ""
}

extension WalletImportViewViewModel {
    enum WalletError: String, Error, CustomStringConvertible {
        case InvalidPrivateKey, CantLoadKeystore
        
        var description: String {
            self.rawValue
        }
    }
}

extension WalletImportViewViewModel {
    func addWalletByPrivateKey() async {
        if working { return }
        working = true
        self.stateMessage = ""
        let task = Task.detached { () async throws -> EthereumAddress in
            let formattedKey = await self.newPrivateKey.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !formattedKey.isEmpty,
                  let dataKey = Data.fromHex(formattedKey) else {
                throw(WalletError.InvalidPrivateKey)
            }
            let keystore =  try EthereumKeystoreV3(privateKey: dataKey)
            guard let myWeb3KeyStore = keystore,
                  let address = myWeb3KeyStore.addresses?.first else {
                      throw(WalletError.CantLoadKeystore)
                  }
            try await YLKSecurity.save(value: self.newPrivateKey, for: ContactsDAppApp.EnclaveKeys.pvk.rawValue)
            return address
        }
        do {
            let address = try await task.value
            self.stateMessage = address.address
        }catch let walletError as WalletError {
            self.stateMessage = walletError.description
        }catch{
            self.stateMessage = error.localizedDescription
        }
        self.newPrivateKey = ""
        working = false
    }
    
    func removeWallet() {
        do {
            try YLKSecurity.removeValue(for: ContactsDAppApp.EnclaveKeys.pvk.rawValue)
        }catch{
            self.stateMessage = error.localizedDescription
        }
    }
}
