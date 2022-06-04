//
//  Contact.swift
//  ContactsDApp
//
//  Created by Yannis LANG on 17/05/2022.
//

import Foundation

struct Contact: Identifiable {
    var id = UUID()
    let name: String
    let phone: String
}
