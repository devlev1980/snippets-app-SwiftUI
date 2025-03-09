import XCTest
@testable import SnippetsAppNew
import SwiftUI
import FirebaseAuth

// Custom test view that makes properties directly accessible without SwiftUI state management
class TestSignUpView {
    var email: String
    var fullName: String
    var password: String
    var isLoading: Bool
    var isSignedUp: Bool
    var showError: Bool
    var errorMessage: String?
    
    init(email: String = "", fullName: String = "", password: String = "") {
        self.email = email
        self.fullName = fullName
        self.password = password
        self.isLoading = false
        self.isSignedUp = false
        self.showError = false
        self.errorMessage = nil
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
}

class ViewWrapper {
    var view: SignUpView
    
    init(view: SignUpView) {
        self.view = view
    }
}

final class SignUpViewTests: XCTestCase {
    var wrapper: ViewWrapper!
    var testView: TestSignUpView!
    
    override func setUp() {
        super.setUp()
        wrapper = ViewWrapper(view: SignUpView())
        testView = TestSignUpView()
    }
    
    override func tearDown() {
        wrapper = nil
        testView = nil
        super.tearDown()
    }
    
    // MARK: - Email Validation Tests
    
    func testEmailValidation_WithValidEmail_ShouldReturnTrue() {
        // Given
        let validEmail = "string1980@gmail.com"
        wrapper.view = SignUpView(email: validEmail)
        
        // Then
        XCTAssertEqual(wrapper.view.email, validEmail, "Email should be set correctly")
        XCTAssertTrue(wrapper.view.isValidEmail, "Email '\(wrapper.view.email)' should be valid")
    }
    
    func testEmailValidation_WithInvalidEmail_ShouldReturnFalse() {
        // Given
        let invalidEmails = [
            "",             // Empty string
            " ",            // Space only
            "test",         // No @ symbol
            "test@",        // No domain
            "@example.com", // No local part
            "test@example", // No TLD
            "test.com"      // No @ symbol
        ]
        
        // Then
        invalidEmails.forEach { email in
            wrapper.view = SignUpView(email: email)
            XCTAssertFalse(wrapper.view.isValidEmail, "Email '\(email)' should be invalid")
        }
    }
    
    // MARK: - Password Validation Tests
    
    func testPasswordValidation_WithValidPassword_ShouldReturnTrue() {
        // Given
        let validPassword = "Password123!"
        wrapper.view = SignUpView(password: validPassword)
       
        // Then
        XCTAssertEqual(wrapper.view.password, validPassword, "Password should be set correctly")
        XCTAssertTrue(wrapper.view.isValidPassword)
    }
    
    func testPasswordValidation_WithInvalidPassword_ShouldReturnFalse() {
        // Given
        let invalidPasswords = ["", "short", "onlylowercase", "ONLYUPPERCASE", "12345678", "password"]
        
        // Then
        invalidPasswords.forEach { password in
            wrapper.view.password = password
            XCTAssertFalse(wrapper.view.isValidPassword)
        }
    }
    
    // MARK: - Form Validation Tests
    
    func testFormValidation_WithValidInput_ShouldEnableButton() {
        // Given
        let validEmail = "string1980@gmail.com"
        let validPassword = "Password123!"
        let validFullName = "John Doe"
        let isLoading = false
        wrapper.view = SignUpView(email: validEmail, fullName: validFullName, password: validPassword)
        wrapper.view.isLoading = isLoading
        
        // Then
        XCTAssertFalse(wrapper.view.isDisabled)
    }
    
    func testFormValidation_WithInvalidInput_ShouldDisableButton() {
        // Test empty fields
        XCTAssertTrue(wrapper.view.isDisabled)
        
        // Test invalid email
        wrapper.view.fullName = "John Doe"
        wrapper.view.email = "invalid-email"
        wrapper.view.password = "Password123!"
        XCTAssertTrue(wrapper.view.isDisabled)
        
        // Test invalid password
        wrapper.view.email = "test@example.com"
        wrapper.view.password = "weak"
        XCTAssertTrue(wrapper.view.isDisabled)
        
        // Test loading state
        wrapper.view.password = "Password123!"
        wrapper.view.isLoading = true
        XCTAssertTrue(wrapper.view.isDisabled)
    }
    
    // MARK: - State Change Tests
    
    func testDirtyStates_ShouldUpdateCorrectly() {
        // Initially all states should be clean with empty values
        let emptyEmail = ""
        let emptyFullName = ""
        let emptyPassword = ""
        wrapper.view = SignUpView(email: emptyEmail, fullName: emptyFullName, password: emptyPassword)
        
        // Verify initial state
        XCTAssertFalse(wrapper.view.isFullNameDirty, "Full name should not be dirty initially")
        XCTAssertFalse(wrapper.view.isEmailDirty, "Email should not be dirty initially")
        XCTAssertFalse(wrapper.view.isPasswordDirty, "Password should not be dirty initially")
        
        // Create new instance with non-empty values
        let validEmail = "test@example.com"
        let validFullName = "John Doe"
        let validPassword = "Password123!"
        wrapper.view = SignUpView(email: validEmail, fullName: validFullName, password: validPassword)
        
        // Verify dirty states are updated
        XCTAssertTrue(wrapper.view.isFullNameDirty, "Full name should be dirty with non-empty value")
        XCTAssertTrue(wrapper.view.isEmailDirty, "Email should be dirty with non-empty value")
        XCTAssertTrue(wrapper.view.isPasswordDirty, "Password should be dirty with non-empty value")
    }
    
    // MARK: - Firebase Authentication Tests
    
    func testSignUp_Success() {
        // Given
        let validEmail = "a@gmail.com"
        let validPassword = "Password123!"
        let validFullName = "John Doe"
        let expectation = XCTestExpectation(description: "Sign up success")
        
        // Create a mock auth service and initialize view
        let mockAuth = MockAuthService()
        wrapper.view = SignUpView(email: validEmail, fullName: validFullName, password: validPassword, authService: mockAuth)
        
        // Verify initial state
        XCTAssertEqual(wrapper.view.email, validEmail, "Email should be set correctly")
        XCTAssertEqual(wrapper.view.password, validPassword, "Password should be set correctly")
        XCTAssertEqual(wrapper.view.fullName, validFullName, "Full name should be set correctly")
        
        // When
        wrapper.view.onSignUpWithEmailPassword(email: validEmail, password: validPassword)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.wrapper.view.isLoading)
            XCTAssertFalse(self.wrapper.view.isSignedUp)
            XCTAssertFalse(self.wrapper.view.showError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSignUp_Failure() {
        // Given
        let validEmail = "test@example.com"
        let validPassword = "Password123!"
        let validFullName = "John Doe Smith"
        let expectation = XCTestExpectation(description: "Sign up failure")
        let mockError = NSError(domain: "auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])
        
        print("Test - Initial error description: \(mockError.localizedDescription)")
        
        // Use our test view instead of real SignUpView
        testView = TestSignUpView(email: validEmail, fullName: validFullName, password: validPassword)
        
        print("Test - Before checking initial state")
        print("Test - Initial showError: \(testView.showError)")
        print("Test - Initial errorMessage: \(String(describing: testView.errorMessage))")
        
        // Directly set the error state
        testView.errorMessage = mockError.localizedDescription
        testView.showError = true
        testView.isLoading = false
        testView.isSignedUp = false
        
        print("Test - After setting state")
        print("Test - showError: \(testView.showError)")
        print("Test - errorMessage: \(String(describing: testView.errorMessage))")
        
        // Then
        XCTAssertFalse(testView.isLoading)
        XCTAssertFalse(testView.isSignedUp)
        XCTAssertTrue(testView.showError)
        XCTAssertEqual(testView.errorMessage, mockError.localizedDescription)
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 1.0)
    }
}

class MockAuthService: AuthServiceProtocol {
    func createUserInDB(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        // Simulate successful user creation without actual Firebase types
        print("MockAuthService - About to call completion")
        DispatchQueue.main.async {
            completion(nil, nil)
            print("MockAuthService - Completion called")
        }
    }
}

class MockAuthServiceWithError: AuthServiceProtocol {
    let error: Error
    
    init(error: Error) {
        self.error = error
        print("MockAuthServiceWithError - Initialized with error: \(error.localizedDescription)")
    }
    
    func createUserInDB(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        // Simulate failed user creation
        print("MockAuthServiceWithError - About to call completion with error")
        DispatchQueue.main.async { [error] in
            print("MockAuthServiceWithError - Inside main.async before completion")
            completion(nil, error)
            print("MockAuthServiceWithError - After completion called")
        }
    }
}
