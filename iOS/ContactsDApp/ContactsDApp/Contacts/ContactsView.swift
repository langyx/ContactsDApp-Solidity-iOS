//
//  ContactsView.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 17/05/2022.
//

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject var userManager: UserManager
    
    @StateObject var contactsViewModel = ContactsViewModel()
    
    var body: some View {
        NavigationView {
            List{
                addContactSection
                contactsSection
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    walletButton
                }
            }
        }
        .onAppear {
            userManager.$web3Instance
                .prefix(2)
                .sink { web3Instance in
                    guard let _ = web3Instance else { return }
                    contactsViewModel.updateContacts(userManager: userManager)
                }.store(in: &contactsViewModel.cancellables)
            userManager.$lastCall
                .sink { lastCall in
                    guard let lastCall = lastCall else { return }
                    guard lastCall.method == ContactsViewModel.Method.addContact.rawValue else {
                        return
                    }
                    contactsViewModel.updateContacts(userManager: userManager)
                }.store(in: &contactsViewModel.cancellables)
        }
    }
}

extension ContactsView {
    var addContactSection: some View {
        Section {
            TextField("Name", text: $contactsViewModel.newContactName)
            TextField("Phone", text: $contactsViewModel.newContactPhone)
                .keyboardType(.phonePad)
            Button("AddContact") {
                Task {
                    await contactsViewModel.addContact(userManager: userManager)
                }
            }
            .disabled(contactsViewModel.working)
        } header: {
            Text("NewContact")
        } footer: {
            Text(contactsViewModel.newContactMessage)
        }
        
    }
    
    var contactsSection: some View {
        Section {
            ForEach(contactsViewModel.contacts) { contact in
                ContactsRowView(contact: contact)
            }
        } header: {
            HStack(spacing: 5){
                Text("Contacts")
                if contactsViewModel.working {
                    ProgressView()
                }
            }
        }
    }
}

extension ContactsView {
    var walletButton: some View {
        Button("Wallet") {
            contactsViewModel.showWalletView = true
        }
        .sheet(isPresented: $contactsViewModel.showWalletView) {
            WalletView(show: $contactsViewModel.showWalletView)
                .environmentObject(userManager)
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView()
            .environmentObject(UserManager())
    }
}
