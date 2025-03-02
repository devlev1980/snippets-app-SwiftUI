//
//  AccountView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 02/03/2025.
//

import SwiftUI

struct AccountView: View {
    let user: User
    
    var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
    
    var body: some View {
        ZStack {
            Color
                .indigo
                .opacity(0.1)
                .ignoresSafeArea()
            HStack {
                Image("Avatar")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("\(timeBasedGreeting), \(user.name)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text(user.email)
                        .font(.title3)
                        .fontWeight(.medium)
                }
              
            }
            
        }
        
    
    }
}

#Preview {
    AccountView(user: .init(name: "Yevgeny", email: "string1980@gmail.com"))
}
