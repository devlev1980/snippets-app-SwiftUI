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
    
    var appVersion: String {
           if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
               return version
           }
           return "Unknown"
       }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Indigo background with opacity 0.2 for the entire screen
                Color.indigo
                    .opacity(0.2)
                    .ignoresSafeArea()
                
                List {
                    NavigationLink {
                        AccountView(user: vm.currentUser!)
                    } label: {
                        HStack {
                            Image(systemName: "person.fill")
                            VStack(alignment: .leading) {
                                Text("Account")
                                if let user = vm.currentUser {
                                    Text(user.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    NavigationLink {
                        AppearanceView()
                    } label: {
                        HStack {
                            Image(systemName: "paintpalette")
                            Text("Appearance")
                        }
                    }

                    Button {
                        onSignOut()
                        
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            Text("Logout")
                        }
                       
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                    }
                }
                .scrollContentBackground(.hidden) // Make list background transparent
            }
            
            .navigationBarTitleDisplayMode(.inline)
            
            
                        
                     
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
