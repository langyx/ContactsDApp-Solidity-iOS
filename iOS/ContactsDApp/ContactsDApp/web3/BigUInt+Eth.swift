//
//  BigUInt+Eth.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 17/05/2022.
//

import Foundation
import BigInt
import web3swift

extension BigUInt {
    var eth: String? {
        Web3.Utils.formatToEthereumUnits(self, toUnits: .eth, decimals: 10)
    }
}
