//
//  WalletView.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 16/05/2022.
//

import SwiftUI
import web3swift

struct WalletView: View {
    @EnvironmentObject var userManager: UserManager
    
    @StateObject private var walletImportViewViewModel = WalletImportViewViewModel()
    
    @Binding var show: Bool
    
    var body: some View {
        NavigationView {
            Form {
                currentWalletSection
                //TODO: Add by mnemonics
                addWalletByPKSection
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        show = false
                    }
                }
            }
            .navigationTitle("Wallet")
        }
    }
}

extension WalletView {
    private var addWalletByPKSection: some View {
        Section(
            header:
                HStack {
                    Text("ByPrivateKey")
                        .padding(.trailing)
                    if walletImportViewViewModel.working {
                        ProgressView()
                    }
                },
            footer: Text(walletImportViewViewModel.stateMessage).font(.footnote)
        ){
                SecureField("EnterNewPrivateKey", text: $walletImportViewViewModel.newPrivateKey)
                Button("AddWallet", action: {
                    Task.init {
                        await walletImportViewViewModel.addWalletByPrivateKey()
                    try? await userManager.loadKeystoreManager()
                }
            })
                .disabled(walletImportViewViewModel.working)
        }
    }
    
    private var currentWalletSection: some View {
        Group {
            if let currentAddress = userManager.keystoreManager?.mainAddress {
                Section(header: HStack{
                    Text("CurrentWallet")
                    Button("Delete", action: {
                        walletImportViewViewModel.removeWallet()
                        userManager.removeKeyStoreManager()
                    })
                }) {
                    Text(currentAddress.address)
                    Text("\(userManager.balance ?? "")ETH")
                }
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView(show: .constant(true))
            .environmentObject(UserManager())
    }
}
