//
//  ContractCallView.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 18/05/2022.
//

import SwiftUI
import BigInt
import web3swift


struct UserPendingCallView: View {
    @EnvironmentObject var userManager: UserManager
    
    var contract: web3.Contract?
    let method: String
    let estimatedFees: BigUInt
    
    @State private var message = ""
    @State private var working = false
    
    var body: some View {
        NavigationView{
            Form {
                contractSection
                Section(header: Text("Transaction")){
                    Text(method)
                    HStack {
                        HStack {
                            Text("Fees")
                            Spacer()
                            Text("\(estimatedFees.eth ?? "")ETH")
                        }
                    }
                }
                actionsSection
            }
        }
    }
}

extension UserPendingCallView {
    var actionsSection: some View {
        Section {
            HStack{
                Button("Approve", action: approve)
                if working {
                    ProgressView()
                        .padding(.leading, 5)
                }
            }
            Button("Cancel", action: cancel)
                .foregroundColor(.red)
                .navigationTitle("PendingTransaction")
        } footer: {
            Text(message)
        }
        .disabled(working)
    }
    
    var contractSection: some View {
        Group {
            if let contract = contract {
                Section(header: Text("Contract")){
                    Text(contract.name)
                    Text(contract.address.address)
                }
            }
        }
    }
}

extension UserPendingCallView {
    func approve() {
        Task {
            working = true
            guard let address = userManager.keystoreManager?.mainAddress,
                  let call = userManager.pendingCall else {
                      return
                  }
            do {
                _ = try await call.execute(from: address)
                userManager.updateBalance()
                userManager.removePendingCall()
            }catch{
                message = error.localizedDescription
            }
            working = false
        }
    }
    
    func cancel() {
        userManager.pendingCall = nil
    }
}

struct UserPendingCallView_Previews: PreviewProvider {
    static var previews: some View {
        return UserPendingCallView(contract: web3.Contract(address: EthereumAddress("0xB4377216B0d556FFe0F7a7d0905dFf52b7B40A8e")!, name: "Contacts"), method: "addContact", estimatedFees: 2)
            .environmentObject(UserManager())
    }
}
