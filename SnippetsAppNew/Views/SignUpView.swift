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

struct SignUpView: View {
    @State var fullName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var isLoading: Bool = false
    @State var isSignedUp: Bool = false
    @State var isFullNameDirty: Bool = false
    @State var isEmailDirty: Bool = false
    @State var isPasswordDirty: Bool = false
    
    var isValidEmail: Bool {
        email.isValidEmail()
    }
    var isValidPassword: Bool {
        password.validatePassword().isEmpty
    }
    
    
    var isDisabled: Bool {
        !isValidEmail || password.isEmpty || email.isEmpty || fullName.isEmpty || isLoading ||  !isValidPassword
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
            }
            .padding()
            
        }
        
        
    }
    func onSignUpWithEmailPassword(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error)")
                isSignedUp = false
            } else {
                print("User created successfully")
                isLoading = false
                isSignedUp = true
                
            }
        }
    }
    
}

#Preview {
    SignUpView()
}
