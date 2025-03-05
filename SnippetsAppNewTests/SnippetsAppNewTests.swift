import XCTest
@testable import SnippetsAppNew
import SwiftUI
import FirebaseAuth



final class SignUpViewTests: XCTestCase {
    var sut: SignUpView!
    
    override func setUp() {
        super.setUp()
        sut = SignUpView()
        //        MockAuth.reset()
    }
    
    override func tearDown() {
        sut = nil
        //        MockAuth.reset()
        super.tearDown()
    }
    
    // MARK: - Email Validation Tests
    
    func testEmailValidation_WithValidEmail_ShouldReturnTrue() {
        // Given
        let validEmail = "string1980@gmail.com"
        sut = SignUpView(email: validEmail)
        
        // Then
        XCTAssertEqual(sut.email, validEmail, "Email should be set correctly")
        XCTAssertTrue(sut.isValidEmail, "Email '\(sut.email)' should be valid")
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
            sut = SignUpView(email: email)
            XCTAssertFalse(sut.isValidEmail, "Email '\(email)' should be invalid")
        }
    }
    
    // MARK: - Password Validation Tests
    
    func testPasswordValidation_WithValidPassword_ShouldReturnTrue() {
        // Given
        let validPassword = "Password123!"
        sut = SignUpView(password: validPassword)
       
        
        // Then
        XCTAssertEqual(sut.password, validPassword, "Passwod should be set correctly")
        
        XCTAssertTrue(sut.isValidPassword)
    }
    
    func testPasswordValidation_WithInvalidPassword_ShouldReturnFalse() {
        // Given
        let invalidPasswords = ["", "short", "onlylowercase", "ONLYUPPERCASE", "12345678", "password"]
        
        // Then
        invalidPasswords.forEach { password in
            sut.password = password
            XCTAssertFalse(sut.isValidPassword)
        }
    }
    
    // MARK: - Form Validation Tests
    
    func testFormValidation_WithValidInput_ShouldEnableButton() {
        // Given
        let validEmail = "string1980@gmail.com"
        let validPassword = "Password123!"
        let validFullName = "John Doe"
        let isLoading = false
        sut = SignUpView(email: validEmail, fullName: validFullName, password: validPassword)
        
        
        
        sut.isLoading = isLoading
        
        // Then
        XCTAssertFalse(sut.isDisabled)
    }
    
    func testFormValidation_WithInvalidInput_ShouldDisableButton() {
        // Test empty fields
        XCTAssertTrue(sut.isDisabled)
        
        // Test invalid email
        sut.fullName = "John Doe"
        sut.email = "invalid-email"
        sut.password = "Password123!"
        XCTAssertTrue(sut.isDisabled)
        
        // Test invalid password
        sut.email = "test@example.com"
        sut.password = "weak"
        XCTAssertTrue(sut.isDisabled)
        
        // Test loading state
        sut.password = "Password123!"
        sut.isLoading = true
        XCTAssertTrue(sut.isDisabled)
    }
    
    // MARK: - State Change Tests
    
    func testDirtyStates_ShouldUpdateCorrectly() {
        // Initially all states should be clean with empty values
        let emptyEmail = ""
        let emptyFullName = ""
        let emptyPassword = ""
        sut = SignUpView(email: emptyEmail, fullName: emptyFullName, password: emptyPassword)
        
        // Verify initial state
        XCTAssertFalse(sut.isFullNameDirty, "Full name should not be dirty initially")
        XCTAssertFalse(sut.isEmailDirty, "Email should not be dirty initially")
        XCTAssertFalse(sut.isPasswordDirty, "Password should not be dirty initially")
        
        // Create new instance with non-empty values
        let validEmail = "test@example.com"
        let validFullName = "John Doe"
        let validPassword = "Password123!"
        sut = SignUpView(email: validEmail, fullName: validFullName, password: validPassword)
        
        // Verify dirty states are updated
        XCTAssertTrue(sut.isFullNameDirty, "Full name should be dirty with non-empty value")
        XCTAssertTrue(sut.isEmailDirty, "Email should be dirty with non-empty value")
        XCTAssertTrue(sut.isPasswordDirty, "Password should be dirty with non-empty value")
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
        sut = SignUpView(email: validEmail, fullName: validFullName, password: validPassword, authService: mockAuth)
        
        // Verify initial state
        XCTAssertEqual(sut.email, validEmail, "Email should be set correctly")
        XCTAssertEqual(sut.password, validPassword, "Password should be set correctly")
        XCTAssertEqual(sut.fullName, validFullName, "Full name should be set correctly")
        
        // When
        sut.onSignUpWithEmailPassword(email: validEmail, password: validPassword)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertFalse(self.sut.isSignedUp)
            XCTAssertFalse(self.sut.showError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

class MockAuthService: AuthServiceProtocol {
    func createUser(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        // Simulate successful user creation without actual Firebase types
        DispatchQueue.main.async {
            completion(nil, nil)
        }
    }
}
