import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import GoogleSignIn
import GoogleSignInSwift

struct SignInView: View {
    @State var fullName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var isEmailDirty: Bool = false
    @State var isPasswordDirty: Bool = false
    @State var isLoading: Bool = false
    @State var isSignedIn: Bool = false
    
    
    var isValidEmail: Bool {
        email.isValidEmail()
    }
    var isValidPassword: Bool {
        password.validatePassword().isEmpty
    }
    
    
    var isDisabled: Bool {
        !isValidEmail || password.isEmpty || email.isEmpty || !isValidPassword
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                
                Text("Email")
                TextFieldView(placeholder: "Email", text: $email)
                    .onChange(of: email) {
                        isEmailDirty = true
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
                
//                if isPasswordDirty {
//                    ForEach(password.validatePassword(), id: \.self) { error in
//                        Text(error)
//                            .foregroundColor(.red)
//                            .font(.caption)
//                    }
//                }
                
                Button {
                    print("Sign In", fullName, email, password)
                    isLoading = true
                    onSignInWithEmailAndPassword(email: email, password: password)
                } label: {
                    HStack {
                        Text("Sign in")
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
                .navigationDestination(isPresented: $isSignedIn) {
                    MainTabView()
                        .navigationBarBackButtonHidden(true)
                }
                .padding(.bottom, 10)
                
                
                //                To SignUp
                
                HStack {
                    Text("Don't have an account?")
                    
                    NavigationLink(destination:  SignUpView()  ) {
                        Text("Sign up")
                            .foregroundStyle(.indigo)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity, alignment: .center)

            }
            .padding()
            
        }
        .onAppear() {
            checkAuthStatus()
        }
       
    }
    
    func onSignInWithEmailAndPassword(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error)")
            } else {
                print("Signed in successfully")
                isLoading = false
                isSignedIn = true
            }
        }
    }
    func onSignInWithGoogle() {
            // Retrieve client ID from Firebase configuration
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                print("No client ID found")
                return
            }
            
            // Create the Google Sign-In configuration
            let configuration = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = configuration
            
            // Retrieve the root view controller for presenting the sign-in UI
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                print("Unable to get the root view controller")
                return
            }
            
            // Start the sign-in flow using the updated API
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, completion: { signInResult, error in
                if let error = error {
                    print("Google sign in error: \(error.localizedDescription)")
                    return
                }
                
                guard let signInResult = signInResult else {
                    print("No sign in result")
                    return
                }
                
                // Retrieve the idToken and accessToken strings.
                guard let idToken = signInResult.user.idToken?.tokenString else {
                    print("Missing id token")
                    return
                }
                let accessToken = signInResult.user.accessToken.tokenString
                
                // Create a Firebase credential using the tokens.
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: accessToken)
                
                // Sign in to Firebase with the credential.
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase sign in error: \(error.localizedDescription)")
                        return
                    }
                    // Update UI on the main thread.
                    DispatchQueue.main.async {
                        self.fullName = signInResult.user.profile?.name ?? "User"
                        self.isSignedIn = true
                    }
                }
            })
        }

    
    func checkAuthStatus() {
        if Auth.auth().currentUser != nil {
            isSignedIn = true // User is logged in, update state
        }
        
    }
    
}




#Preview {
    SignInView()
}
