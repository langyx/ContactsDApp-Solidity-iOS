//
//  Web3+Contract.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 16/05/2022.
//

import Foundation
import UIKit
import web3swift
import BigInt

extension web3 {
    public struct Contract {
        var address: EthereumAddress
        var name: String
        
        var abi: String? {
            guard let asset = NSDataAsset(name: name) else { return nil }
            return String(data: asset.data, encoding: .utf8)
        }
    }
}


extension web3.Contract {
    public enum MethodType {
        case read, write
    }
    public enum RunMethodError: Error {
        case noWeb3Instance, cantLoadAbi, cantLoadContract, cantCreateTx
        case cantGetFees
    }
}


extension web3.Contract {
    public enum Transaction {
        case read(ReadTransaction), write(WriteTransaction)
    }
}

extension web3.Contract {
    public struct Call: Identifiable {
        public var id = UUID()
        var transaction: Transaction
        var estimatedGas: BigUInt
        var estimatedGasPrice: BigUInt
        
        var estimatedFees: BigUInt {
            return estimatedGas * estimatedGasPrice
        }
        var method: String {
            switch transaction {
            case .read(let readTransaction):
                return readTransaction.method
            case .write(let writeTransaction):
                return writeTransaction.method
            }
        }
    }
}

extension web3.Contract.Call {
    public func execute(from address: EthereumAddress) async throws ->  [String: Any] {
        let task = Task.detached { () throws -> [String: Any] in
            switch self.transaction {
            case .read(let readTransaction):
                let result = try readTransaction.call(transactionOptions: readTransaction.transactionOptions)
                return result
            case .write(let writeTransaction):
                var options = TransactionOptions.defaultOptions
                options.from = address
                options.gasPrice = .manual(self.estimatedGasPrice)
                options.gasLimit = .automatic
                _ = try writeTransaction.send(transactionOptions: options)
                return [:]
            }
        }
        return try await task.value
    }
}

extension web3 {
    public func prepareCall(_ method: String, type methodType: Contract.MethodType, on contract: Contract, from address: EthereumAddress, with parameters: [AnyObject] = []) async throws -> web3.Contract.Call {
        let task = Task.detached { () throws -> web3.Contract.Call  in
            let web3Instance = self
            guard let contractABI = contract.abi else { throw(Contract.RunMethodError.cantLoadAbi)
            }
            
            let abiVersion = 2
            let extraData: Data = Data()
            var options = TransactionOptions.defaultOptions
            options.from = address
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            
            guard let contract = web3Instance.contract(contractABI, at: contract.address, abiVersion: abiVersion) else {
                throw(Contract.RunMethodError.cantLoadContract)
            }
            
            var transaction: Contract.Transaction
            if methodType == .read {
                guard let tx = contract.read(
                    method,
                    parameters: parameters,
                    extraData: extraData,
                    transactionOptions: options) else{
                        throw(Contract.RunMethodError.cantCreateTx)
                    }
                transaction = .read(tx)
            }else{
                guard let tx = contract.write(
                    method,
                    parameters: parameters,
                    extraData: extraData,
                    transactionOptions: options) else{
                        throw(Contract.RunMethodError.cantCreateTx)
                    }
                transaction = .write(tx)
            }
            var estimatedGas: BigUInt?
            switch transaction {
            case .read(let readTransaction):
                estimatedGas = try? web3Instance.eth.estimateGas(readTransaction.transaction, transactionOptions: nil)
            case .write(let writeTransaction):
                estimatedGas = try? web3Instance.eth.estimateGas(writeTransaction.transaction, transactionOptions: nil)
            }
            let estimatedGasPrice = try? web3Instance.eth.getGasPrice()
            guard let estimatedGas = estimatedGas,
                  let estimatedGasPrice = estimatedGasPrice else {
                      throw(Contract.RunMethodError.cantGetFees)
                  }
            return Contract.Call(transaction: transaction, estimatedGas: estimatedGas, estimatedGasPrice: estimatedGasPrice)
        }
        return try await task.result.get()
    }
}
