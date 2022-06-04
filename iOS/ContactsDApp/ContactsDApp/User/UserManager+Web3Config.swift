//
//  UserManager+Web3Config.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 19/05/2022.
//

import Foundation
import web3swift

extension UserManager {
    internal func loadWeb3Config(file: String = "Web3") -> [String: Any]? {
        guard let path = Bundle.main.path(forResource: file, ofType: "plist") else {
            return nil
        }
        return NSDictionary(contentsOfFile: path) as? [String : Any]
    }
    
    internal func loadWeb3ConfigProvider() -> URL? {
        guard let web3Config = self.web3Config,
        let provider = web3Config["provider"] as? String else {
            return nil
        }
        return URL(string: provider)
    }
    
    var contractAddress: EthereumAddress? {
        guard let web3Config = self.web3Config,
        let address = web3Config["contractAddress"] as? String else {
            return nil
        }
        return EthereumAddress(address)
    }
    
    var contract: web3.Contract? {
        guard let web3Config = self.web3Config,
              let contractAddress = contractAddress,
              let contractName = web3Config["contractName"] as? String
        else {
            return nil
        }
        return web3.Contract(address: contractAddress, name: contractName)
    }
}
