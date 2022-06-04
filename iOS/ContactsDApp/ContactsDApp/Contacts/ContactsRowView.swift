//
//  ContactsRowView.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 19/05/2022.
//

import SwiftUI

struct ContactsRowView: View {
    let contact: Contact
    
    var body: some View {
        VStack(alignment: .leading){
            Text(contact.name)
                .font(.headline)
            Text(contact.phone)
        }
    }
}

struct ContactsRowView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsRowView(contact: Contact(name: "Yannis", phone: "0610101010"))
    }
}
