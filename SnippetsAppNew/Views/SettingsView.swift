//
//  SettingsView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @State var navigateToSignInView: Bool = false
    
    var body: some View {
        NavigationStack {
                        Button {
                            onSignOut()
                            
                        } label: {
                            Text("Logout")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationDestination(isPresented: $navigateToSignInView) {
                                        SignInView()
                                .navigationBarBackButtonHidden(true)
                                    }
                     
                }
    }
    func onSignOut() {
           do {
               try Auth.auth().signOut()
               print("User signed out successfully")
               // Trigger navigation to SignInView on the main thread.
               DispatchQueue.main.async {
                   navigateToSignInView = true
                   
               }
           } catch let error as NSError {
               print("Error signing out: \(error.localizedDescription)")
           }
       }
}

#Preview {
    SettingsView()
}
