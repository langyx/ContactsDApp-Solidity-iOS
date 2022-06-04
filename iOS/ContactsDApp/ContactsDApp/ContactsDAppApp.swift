//
//  ContactsDAppApp.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 16/05/2022.
//

import SwiftUI

@main
struct ContactsDAppApp: App {
    @StateObject private var userManager = UserManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(userManager)
        }
    }
}

extension ContactsDAppApp {
    enum EnclaveKeys: String {
        case pvk = "com.yannislang.BlockChainConnect.pvk"
    }
    
    enum KeychainKeys: String {
        case mainWallet
    }
}
