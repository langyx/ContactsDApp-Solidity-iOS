//
//  UserManager+PendingCall.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 19/05/2022.
//

import Foundation
import web3swift


extension UserManager {
    func add(_ call: web3.Contract.Call) {
        pendingCall = call
    }
    
    func removePendingCall() {
        guard let pendingCall = self.pendingCall else {
            return
        }
        lastCall = pendingCall
        self.pendingCall = nil
    }
}
