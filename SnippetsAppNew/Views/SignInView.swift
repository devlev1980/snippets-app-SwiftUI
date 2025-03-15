import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import GoogleSignIn
import GoogleSignInSwift

// Helper struct to manage user credentials
struct UserCredentials {
    private static let userDefaults = UserDefaults.standard
    private static let emailKey = "savedEmail"
    private static let passwordKey = "savedPassword"
    
    static func saveCredentials(email: String, password: String) {
        userDefaults.set(email, forKey: emailKey)
        userDefaults.set(password, forKey: passwordKey)
    }
    
    static func getEmail() -> String? {
        return userDefaults.string(forKey: emailKey)
    }
    
    static func getPassword() -> String? {
        return userDefaults.string(forKey: passwordKey)
    }
    
    static func clearCredentials() {
        userDefaults.removeObject(forKey: emailKey)
        userDefaults.removeObject(forKey: passwordKey)
    }
}

struct SignInView: View {
    @State var fullName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var isEmailDirty: Bool = false
    @State var isPasswordDirty: Bool = false
    @State var isLoading: Bool = false
    @State var isSignedIn: Bool = false
    @State var errorMessage: String?
    @State var showError: Bool = false
    @State var isResetPasswordLoading: Bool = false
    @State var showResetPasswordSuccess: Bool = false
    @State private var rememberCredentials: Bool = true
    @FocusState private var emailFieldIsFocused: Bool
    @FocusState private var passwordFieldIsFocused: Bool
    let viewModel: SnippetsViewModel
//    @Environment(SnippetsViewModel.self) private var viewModel
    
    
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
            ZStack {
                // Adaptive background for the entire screen
                Color.indigo
                    .opacity(0.2)
                    .ignoresSafeArea()
                
                // Adaptive background for the content
                VStack(alignment: .leading) {
                    
                    
                    Text("Email")
                        .foregroundColor(.primary)
                    TextFieldView(placeholder: "Email", text: $email)
                        .focused($emailFieldIsFocused)
                        .onChange(of: emailFieldIsFocused) { _, newValue in
                            // Only validate email when focus is lost
                            if !newValue {
                                isEmailDirty = true
                            }
                        }
                        // Also validate on submit (when user presses return/enter)
                        .onSubmit {
                            isEmailDirty = true
                        }
                    
                    if isEmailDirty && !isValidEmail {
                        Text("Please enter a valid email address.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Text("Password")
                        .foregroundColor(.primary)
                    SecureFieldView(placeholder: "Password", password: $password)
                        .onChange(of: password) { _, newValue in
                            // Validate password during typing
                            isPasswordDirty = true
                        }
                    
                    // Forgot password button
                    Button {
                        resetPassword()
                    } label: {
                        HStack {
                            Text("Forgot password?")
                            if isResetPasswordLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .indigo))
                                    .scaleEffect(0.8)
                            }
                        }
                        .foregroundColor(.indigo)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .disabled(email.isEmpty || !isValidEmail || isResetPasswordLoading)
                    .opacity((email.isEmpty || !isValidEmail) ? 0.5 : 1)
                    
                    if showResetPasswordSuccess {
                        Text("Password reset email sent. Please check your inbox.")
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.top, 2)
                    }
                    
                    if showError {
                        if let errorMessage = errorMessage {
                            ErrorMessageView(errorMessage: errorMessage)
                            
                            
                        }
                    }
                    
                    // Remember credentials toggle
                    Toggle("Remember me", isOn: $rememberCredentials)
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .padding(.vertical, 5)
                    
                    Button {
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
                        MainTabView(vm: viewModel )
                            .navigationBarBackButtonHidden(true)
                    }
                    .padding(.bottom, 10)
                    
                    
                    //                To SignUp
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.primary)
                        
                        NavigationLink(destination:  SignUpView()  ) {
                            Text("Sign up")
                                .foregroundStyle(.indigo)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    

                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 5)
                .padding()
            }
            
        }
        .onAppear() {
            checkAuthStatus()
        }
       
    }
    
    func onSignInWithEmailAndPassword(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                showError = true
                isLoading = false
                errorMessage = error.localizedDescription
                
                // Hide error message after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showError = false
                }
            } else {
                // Save credentials for next login if user has opted in
                if self.rememberCredentials {
                    UserCredentials.saveCredentials(email: email, password: password)
                } else {
                    UserCredentials.clearCredentials()
                }
                
                if let user = authResult?.user {
                    let displayName = user.displayName ?? email.components(separatedBy: "@").first ?? "User"
                    let userEmail = user.email ?? email
                    
                    // Save the user in the ViewModel
                    DispatchQueue.main.async {
                        self.viewModel.setCurrentUser(name: displayName, email: userEmail)
                        self.isLoading = false
                        self.isSignedIn = true
                        self.showError = false
                    }
                }
            }
        }
    }
    
    func resetPassword() {
        // Ensure the email is valid before proceeding
        guard isValidEmail else {
            showError = true
            errorMessage = "Please enter a valid email address"
            
            // Hide error message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showError = false
            }
            return
        }
        
        isResetPasswordLoading = true
        showError = false
        showResetPasswordSuccess = false
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            isResetPasswordLoading = false
            
            if let error = error {
                showError = true
                errorMessage = error.localizedDescription
                
                // Hide error message after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showError = false
                }
            } else {
                showResetPasswordSuccess = true
                
                // Hide success message after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showResetPasswordSuccess = false
                }
            }
        }
    }
    
    func onSignInWithGoogle() {
            // Retrieve client ID from Firebase configuration
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                return
            }
            
            // Create the Google Sign-In configuration
            let configuration = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = configuration
            
            // Retrieve the root view controller for presenting the sign-in UI
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                return
            }
            
            // Start the sign-in flow using the updated API
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, completion: { signInResult, error in
                if let error = error {
                    return
                }
                
                guard let signInResult = signInResult else {
                    return
                }
                
                // Retrieve the idToken and accessToken strings.
                guard let idToken = signInResult.user.idToken?.tokenString else {
                    return
                }
                let accessToken = signInResult.user.accessToken.tokenString
                
                // Create a Firebase credential using the tokens.
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: accessToken)
                
                // Sign in to Firebase with the credential.
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        return
                    }
                    // Update UI on the main thread.
                    DispatchQueue.main.async {
                        let userName = signInResult.user.profile?.name ?? "User"
                        let userEmail = authResult?.user.email ?? ""
                        
                        // Save just the email for Google sign-in if user opted in
                        if self.rememberCredentials && !userEmail.isEmpty {
                            UserCredentials.saveCredentials(email: userEmail, password: "")
                        } else {
                            UserCredentials.clearCredentials()
                        }
                        
                        // Save user to the ViewModel
                        self.viewModel.setCurrentUser(name: userName, email: userEmail)
                        self.fullName = userName
                        self.isSignedIn = true
                    }
                }
            })
        }

    
    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            // Get user information
            let displayName = user.displayName ?? user.email?.components(separatedBy: "@").first ?? "User"
            let email = user.email ?? ""
            
            // Save user to the ViewModel
            viewModel.setCurrentUser(name: displayName, email: email)
            isSignedIn = true // User is logged in, update state
        } else {
            // Load saved credentials if available
            let savedEmail = UserCredentials.getEmail()
            let savedPassword = UserCredentials.getPassword()
            
            if let savedEmail = savedEmail {
                self.email = savedEmail
            }
            
            if let savedPassword = savedPassword {
                self.password = savedPassword
            }
            
            // Update the rememberCredentials toggle state based on whether credentials exist
            self.rememberCredentials = (savedEmail != nil) || (savedPassword != nil)
        }
    }
    
}




#Preview {
    let vm: SnippetsViewModel = .init()
    SignInView(viewModel: vm)
}
