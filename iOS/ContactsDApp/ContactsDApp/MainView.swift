//
//  MainView.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 16/05/2022.
//

import SwiftUI
import YLKSecurity

struct MainView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        ContactsView()
            .environmentObject(userManager)
            .sheet(item: $userManager.pendingCall) { pendingCall in
                UserPendingCallView(contract: userManager.contract, method: pendingCall.method, estimatedFees: pendingCall.estimatedFees)
                    .environmentObject(userManager)
            }
            .onAppear {
                Task.init{
                    do {
                        try await userManager.loadKeystoreManager()
                    }catch{
                        print(error)
                    }
                }
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return MainView()
            .environmentObject(UserManager())
    }
}
