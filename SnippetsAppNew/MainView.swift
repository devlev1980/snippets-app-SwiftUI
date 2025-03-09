//
//  ContentView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @State private var isUserAuthenticated: Bool = false
    @State private var vm: SnippetsViewModel = .init()
    
    var body: some View {
        Group {
            if isUserAuthenticated {
                MainTabView(vm: vm)
            } else {
                SignInView(viewModel: vm)
            }
        }
        .onAppear {
            setupAuthStateListener()
        }
    }
    
    private func setupAuthStateListener() {
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { auth, user in
            DispatchQueue.main.async {
                self.isUserAuthenticated = user != nil
                if let user = user {
                    // Update the ViewModel with current user info
                    let displayName = user.displayName ?? user.email?.components(separatedBy: "@").first ?? "User"
                    let email = user.email ?? ""
                    self.vm.setCurrentUser(name: displayName, email: email)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
