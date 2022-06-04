//
//  ContactsViewModel.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 17/05/2022.
//

import Foundation
import web3swift
import Combine
import BigInt

@MainActor
class ContactsViewModel: ObservableObject {
    @Published var working = false
    @Published var showWalletView = false
    
    @Published var contacts: [Contact] = []
    
    @Published var newContactMessage = ""
    @Published var newContactName = ""
    @Published var newContactPhone = ""
    
    var cancellables = Set<AnyCancellable>()
}

extension ContactsViewModel {
    enum Method: String {
        case getCount, getContact, addContact
    }
}

extension ContactsViewModel {
    enum FetchError: String, Error {
        case web3InstanceNotReady, badMethodReturn, cantGetContactsCount
        var description: String {self.rawValue}
    }
}

extension ContactsViewModel {
    enum NewContactMessage: String {
        case invalidForm
    }
}

extension ContactsViewModel {
    func load(userManager: UserManager) async {
        let task = Task.detached { () throws -> [Contact] in
            guard let contractAddress = await userManager.contractAddress,
                  let web3Instance = await userManager.web3Instance,
                  let address = await userManager.keystoreManager?.mainAddress else {
                      throw(FetchError.web3InstanceNotReady)
                  }
            let contract = web3.Contract(address: contractAddress, name: "Contacts")
            guard let contactsCount = try await self.getContactCount(web3Instance: web3Instance, address: address, contract: contract) else {
                throw(FetchError.cantGetContactsCount)
            }
            return await self.getContacts(web3Instance: web3Instance, address: address, contract: contract, contactsCount: contactsCount)
        }
        do {
            self.contacts = try await task.value
        }catch let fetchError as FetchError {
            print(fetchError.description)
        }catch{
            print(error)
        }
    }
}

extension ContactsViewModel {
    private func getContactCount(web3Instance: web3, address: EthereumAddress, contract: web3.Contract) async throws -> BigUInt? {
        let call = try await web3Instance.prepareCall(Method.getCount.rawValue, type: .read, on: contract, from: address)
        let result = try await call.execute(from: address)
        return result["0"] as? BigUInt
    }
    
    private func getContacts(web3Instance: web3, address: EthereumAddress, contract: web3.Contract, contactsCount: BigUInt) async -> [Contact] {
        var contacts: [Contact] = []
        for index in 0..<contactsCount {
            guard let contact = try? await getContact(web3Instance: web3Instance, address: address, contract: contract, index: index) else {
                continue
            }
            contacts.append(contact)
        }
        return contacts
    }
    
    private func getContact(web3Instance: web3, address: EthereumAddress, contract: web3.Contract, index: BigUInt) async throws -> Contact {
        let call = try await web3Instance.prepareCall(Method.getContact.rawValue, type: .read, on: contract, from: address, with: [index as AnyObject])
        let result = try await call.execute(from: address)
        guard let name = result["0"] as? String,
              let phone = result["1"] as? String else {
                  throw(FetchError.badMethodReturn)
              }
        return Contact(name: name, phone: phone)
    }
}

extension ContactsViewModel {
    func addContact(userManager: UserManager) async {
        guard !newContactName.isEmpty, !newContactPhone.isEmpty else {
            newContactMessage = NewContactMessage.invalidForm.rawValue
            return
        }
        guard let address = userManager.keystoreManager?.mainAddress,
              let contract = userManager.contract,
              let web3Instance = userManager.web3Instance
        else {
            newContactMessage = FetchError.web3InstanceNotReady.description
            return
        }
        
        let task = Task.detached { () throws -> web3.Contract.Call in
            return try await web3Instance.prepareCall(Method.addContact.rawValue, type: .write, on: contract, from: address, with: [self.newContactName as AnyObject, self.newContactPhone as AnyObject])
        }
        do {
            userManager.pendingCall = try await task.value
            newContactName = ""
            newContactPhone = ""
        }catch{
            newContactMessage = error.localizedDescription
        }
    }
}

extension ContactsViewModel{
    func updateContacts(userManager: UserManager)  {
        Task{
            working = true
            await load(userManager: userManager)
            working = false
        }
    }
}
