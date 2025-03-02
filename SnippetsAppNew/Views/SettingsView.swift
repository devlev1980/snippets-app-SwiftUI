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
    let vm: SnippetsViewModel
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    AccountView(user: vm.currentUser!)
                } label: {
                    Image(systemName: "person")
                   Text("Account")
                }
                NavigationLink {
                    AppearanceView()
                } label: {
                    Image(systemName: "paintpalette")
                    Text("Appearance")
                }

                Button {
                    onSignOut()
                    
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Logout")
                    }
                   
                }
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                }
                
                
//                .buttonStyle(.borderedProminent)
//                .tint(.indigo)
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $navigateToSignInView) {
                    SignInView(viewModel: vm)
                        .navigationBarBackButtonHidden(true)
                            }
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
    
    let vm: SnippetsViewModel = .init()
    
    SettingsView(vm: vm)
}
