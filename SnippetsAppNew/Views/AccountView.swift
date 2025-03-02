//
//  AccountView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 02/03/2025.
//

import SwiftUI

struct AccountView: View {
    let user: User
    var body: some View {
        Text("Welcome \(user.name)")
        Text("Email: \(user.email)")
    }
}

#Preview {
    AccountView(user: .init(name: "Yevgeny", email: "string1980@gmail.com"))
}
