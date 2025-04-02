//
//  SettingsView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    @State var navigateToSignInView: Bool = false
    @State var navigateToSignUpView: Bool = false
    @State var showDeleteAccountAlert: Bool = false
    @State var isDeletingAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
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
                    
                    Button {
                        showDeleteAccountAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.minus")
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                    }
                    .disabled(isDeletingAccount)
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                    }
                }
                .scrollContentBackground(.hidden) // Make list background transparent
                
                if isDeletingAccount {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack {
                        ProgressView("Deleting account...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                }
                
                if showError {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .padding(.horizontal)
                        
                        Button("OK") {
                            showError = false
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .padding(.top)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToSignUpView) {
                SignUpView(viewModel: vm)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToSignInView) {
                SignInView(viewModel: vm)
                    .navigationBarBackButtonHidden(true)
            }
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
    }
    
    func onSignOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                navigateToSignInView = true
            }
        } catch let error as NSError {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        // First, reauthenticate the user
        let alert = UIAlertController(title: "Reauthenticate", message: "Please enter your password to confirm account deletion", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { _ in
            guard let password = alert.textFields?.first?.text else { return }
            
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
            
            isDeletingAccount = true  // Start loading state
            
            user.reauthenticate(with: credential) { result, error in
                if let error = error {
                    print("Reauthentication error: \(error.localizedDescription)")
                    isDeletingAccount = false  // Stop loading state
                    DispatchQueue.main.async {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                    return
                }
                
                // Delete all user's snippets first
                let db = Firestore.firestore()
                db.collection("SnippetsDB")
                    .whereField("userEmail", isEqualTo: user.email ?? "")
                    .getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error getting user's snippets: \(error.localizedDescription)")
                            isDeletingAccount = false  // Stop loading state
                            return
                        }
                        
                        // Create a batch to delete all snippets
                        let batch = db.batch()
                        querySnapshot?.documents.forEach { document in
                            batch.deleteDocument(document.reference)
                        }
                        
                        // Commit the batch delete
                        batch.commit { error in
                            if let error = error {
                                print("Error deleting user's snippets: \(error.localizedDescription)")
                                isDeletingAccount = false  // Stop loading state
                                return
                            }
                            
                            // Now delete the account
                            user.delete { error in
                                if let error = error {
                                    print("Error deleting account: \(error.localizedDescription)")
                                    isDeletingAccount = false  // Stop loading state
                                    return
                                }
                                
                                // Account and snippets deleted successfully
                                DispatchQueue.main.async {
                                    navigateToSignInView = false  // Ensure SignInView navigation is off
                                    navigateToSignUpView = true   // Force navigation to SignUpView
                                }
                            }
                        }
                    }
            }
        })
        
        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}

#Preview {
    let vm: SnippetsViewModel = .init()
    SettingsView(vm: vm)
}
