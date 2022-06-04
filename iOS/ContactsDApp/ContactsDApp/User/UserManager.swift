//
//  UserManager.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 16/05/2022.
//

import Foundation
import web3swift
import YLKSecurity
import Combine
import BigInt

@MainActor
class UserManager: ObservableObject {
    internal lazy var web3Config: [String: Any]? = { loadWeb3Config() }()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var web3Instance: web3?
    @Published var keystoreManager: KeystoreManager?
    
    @Published var pendingCall: web3.Contract.Call?
    @Published var lastCall: web3.Contract.Call?
    
    @Published var balanceValue: BigUInt?
    
    init() {
        $keystoreManager.sink { newKeyStoreManager in
            Task {
                self.web3Instance = await self.loadWeb3Instance()
                self.web3Instance?.addKeystoreManager(newKeyStoreManager)
                self.updateBalance()
            }
        }.store(in: &cancellables)
    }
}

extension UserManager {
    private func loadWeb3Instance() async -> web3? {
        let task = Task.detached { () throws -> web3 in
            guard let providerURL = await self.loadWeb3ConfigProvider() else {
                throw(KeyStoreError.badProviderURL)
            }
            return try Web3.new(providerURL)
        }
        return try? await task.value
    }
}

extension UserManager {
    func removeKeyStoreManager() {
        keystoreManager = nil
    }
    
    func loadKeystoreManager() async throws {
        let privateKey = try await YLKSecurity.getValue(for: ContactsDAppApp.EnclaveKeys.pvk.rawValue)
        guard let dataKey = Data.fromHex(privateKey),
              let keyStore = try EthereumKeystoreV3(privateKey: dataKey)else {
                  throw(KeyStoreError.badKey)
              }
//        await MainActor.run {
//            keystoreManager = KeystoreManager([keyStore])
//        }
    }
}

extension UserManager {
    func updateBalance()  {
        Task {
            self.balanceValue = try? await self.getBalance()
        }
    }
    
    func getBalance() async throws -> BigUInt {
        guard let mainAddress = keystoreManager?.mainAddress else {
            throw(KeyStoreError.noAddress)
        }
        guard let web3Instance = web3Instance else {
            throw(KeyStoreError.noWeb3Instance)
        }
        let balance = try await Task.detached { () throws -> BigUInt in
           return try web3Instance.eth.getBalance(address: mainAddress)
        }.value
        return balance
    }
    
    var balance: String? {
        guard let balanceValue = balanceValue else {return nil}
        return balanceValue.eth
    }
}

extension UserManager {
    enum KeyStoreError: Error {
        case badKey, badProviderURL, noAddress, noWeb3Instance
    }
}
