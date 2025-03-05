//
//  SignUpView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseDatabase
import GoogleSignIn
import GoogleSignInSwift

// Make Auth conform to AuthServiceProtocol
extension Auth: AuthServiceProtocol {
    public func createUser(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: completion)
    }
}

struct SignUpView: View {
    @State var fullName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var isLoading: Bool = false
    @State var isSignedUp: Bool = false
    @State var isFullNameDirty: Bool = false
    @State var isEmailDirty: Bool = false
    @State var isPasswordDirty: Bool = false
    @State var errorMessage: String?
    @State var showError: Bool = false
    
    private let authService: AuthServiceProtocol
    
    // Test-specific initializer
    init(email: String = "", fullName: String = "", password: String = "", authService: AuthServiceProtocol = Auth.auth()) {
        _email = State(initialValue: email)
        _fullName = State(initialValue: fullName)
        _password = State(initialValue: password)
        _isEmailDirty = State(initialValue: !email.isEmpty)
        _isFullNameDirty = State(initialValue: !fullName.isEmpty)
        _isPasswordDirty = State(initialValue: !password.isEmpty)
        self.authService = authService
    }
    
    var isValidEmail: Bool {
        email.isValidEmail()
    }
    var isValidPassword: Bool {
        password.validatePassword().isEmpty
    }
    
    
    var isDisabled: Bool {
        !isValidEmail || !isValidPassword || fullName.isEmpty || isLoading
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Full name")
                TextFieldView(placeholder: "Email", text: $fullName)
                    .onChange(of: fullName) {
                        isFullNameDirty = true
                    }
                if isFullNameDirty {
                    let errors = fullName.validateFullName()
                    
                    ForEach(errors, id: \.self) { error in
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Text("Email")
                TextFieldView(placeholder: "Email", text: $email)
                    .onChange(of: email) {
                        isEmailDirty = true
                        
                    }
                if email.isEmpty && isEmailDirty {
                    Text("This field is required")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                if isEmailDirty && !isValidEmail {
                    Text("Invalid email")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                
                Text("Password")
                SecureFieldView(placeholder: "Password", password: $password)
                    .onChange(of: password) {
                        isPasswordDirty = true
                    }
                
                if password.isEmpty && isPasswordDirty {
                    Text("This field is required")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                if isPasswordDirty {
                    ForEach(password.validatePassword(), id: \.self) { error in
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Button {
                    print("Sign Up", fullName, email, password)
                    isLoading = true
                    onSignUpWithEmailPassword(email: email, password: password)
                } label: {
                    HStack {
                        Text("Sign up")
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .padding()
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 10)
                    
                }
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1)
                .navigationDestination(isPresented: $isSignedUp
                                       , destination: {
                    MainTabView()
                        .navigationBarBackButtonHidden(true)
                })
                .padding(.bottom,10)
                
                if showError  {
                    if let errorMessage = errorMessage  {
                        ErrorMessageView(errorMessage: errorMessage)
                    }
                  
                }
                
                
                
             
            }
            .padding()
            
        }
        
        
    }
    func onSignUpWithEmailPassword(email: String, password: String) {
        isLoading = true
        authService.createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error creating user: \(error)")
                    self.showError = true
                    self.errorMessage = error.localizedDescription
                    self.isSignedUp = false
                    self.isLoading = false
                    
                    // Hide error message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.showError = false
                    }
                } else if let user = authResult?.user {
                    print("User created successfully")
                    
                    // Create a change request to update the display name
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = self.fullName
                    
                    // Commit the change
                    changeRequest.commitChanges { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error updating display name: \(error)")
                                self.showError = true
                                self.errorMessage = error.localizedDescription
                                
                                // Hide error message after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    self.showError = false
                                }
                            } else {
                                print("Display name updated successfully")
                            }
                            self.isLoading = false
                            self.isSignedUp = true
                            self.showError = false
                        }
                    }
                }
            }
        }
    }
    
}

#Preview {
    SignUpView()
}
