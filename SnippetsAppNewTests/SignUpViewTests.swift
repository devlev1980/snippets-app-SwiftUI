//import XCTest
//@testable import SnippetsAppNew
//import SwiftUI
//import FirebaseAuth
//
//final class SignUpViewTests: XCTestCase {
//    var sut: SignUpView!
//    
//    override func setUp() {
//        super.setUp()
//        sut = SignUpView()
//        MockAuth.reset()
//    }
//    
//    override func tearDown() {
//        sut = nil
//        MockAuth.reset()
//        super.tearDown()
//    }
//    
//    // MARK: - Email Validation Tests
//    
//    func testEmailValidation_WithValidEmail_ShouldReturnTrue() {
//        // Given
//        let validEmails = [
//            "test@example.com",
//            "user.name@domain.com",
//            "user+label@domain.co.uk",
//            "firstname.lastname@domain.com"
//        ]
//        
//        // Then
//        validEmails.forEach { email in
//            sut.email = email
//            XCTAssertTrue(sut.isValidEmail, "Email \(email) should be valid")
//        }
//    }
//    
//    func testEmailValidation_WithInvalidEmail_ShouldReturnFalse() {
//        // Given
//        let invalidEmails = [
//            "",                     // Empty string
//            "test",                 // No @ symbol
//            "test@",               // No domain
//            "@example.com",        // No local part
//            "test@example",        // Incomplete domain
//            "test.com",            // No @ symbol
//            "test@.com",           // No domain name
//            "test@domain.",        // Domain ends with dot
//            "test space@domain.com" // Contains space
//        ]
//        
//        // Then
//        invalidEmails.forEach { email in
//            sut.email = email
//            XCTAssertFalse(sut.isValidEmail, "Email \(email) should be invalid")
//        }
//    }
//    
//    // MARK: - Password Validation Tests
//    
//    func testPasswordValidation_WithValidPassword_ShouldReturnTrue() {
//        // Given
//        sut.password = "Password123!"
//        
//        // Then
//        XCTAssertTrue(sut.isValidPassword)
//    }
//    
//    func testPasswordValidation_WithInvalidPassword_ShouldReturnFalse() {
//        // Given
//        let invalidPasswords = ["", "short", "onlylowercase", "ONLYUPPERCASE", "12345678", "password"]
//        
//        // Then
//        invalidPasswords.forEach { password in
//            sut.password = password
//            XCTAssertFalse(sut.isValidPassword)
//        }
//    }
//    
//    // MARK: - Form Validation Tests
//    
//    func testFormValidation_WithValidInput_ShouldEnableButton() {
//        // Given
//        sut.fullName = "John Doe"
//        sut.email = "test@example.com"
//        sut.password = "Password123!"
//        sut.isLoading = false
//        
//        // Then
//        XCTAssertFalse(sut.isDisabled)
//    }
//    
//    func testFormValidation_WithInvalidInput_ShouldDisableButton() {
//        // Test empty fields
//        XCTAssertTrue(sut.isDisabled)
//        
//        // Test invalid email
//        sut.fullName = "John Doe"
//        sut.email = "invalid-email"
//        sut.password = "Password123!"
//        XCTAssertTrue(sut.isDisabled)
//        
//        // Test invalid password
//        sut.email = "test@example.com"
//        sut.password = "weak"
//        XCTAssertTrue(sut.isDisabled)
//        
//        // Test loading state
//        sut.password = "Password123!"
//        sut.isLoading = true
//        XCTAssertTrue(sut.isDisabled)
//    }
//    
//    // MARK: - State Change Tests
//    
//    func testDirtyStates_ShouldUpdateCorrectly() {
//        // Initially all dirty states should be false
//        XCTAssertFalse(sut.isFullNameDirty)
//        XCTAssertFalse(sut.isEmailDirty)
//        XCTAssertFalse(sut.isPasswordDirty)
//        
//        // Update values
//        sut.fullName = "John"
//        sut.email = "test@example.com"
//        sut.password = "Password123!"
//        
//        // Dirty states should be updated
//        XCTAssertTrue(sut.isFullNameDirty)
//        XCTAssertTrue(sut.isEmailDirty)
//        XCTAssertTrue(sut.isPasswordDirty)
//    }
//    
//    // MARK: - Firebase Authentication Tests
//    
//    func testSignUp_Success() {
//        // Given
//        let expectation = XCTestExpectation(description: "Sign up success")
//        let mockUser = MockUser(uid: "123", email: "test@example.com", displayName: "John Doe")
//        let mockAuthResult = MockAuthDataResult(user: mockUser)
//        MockAuth.mockResult = (mockAuthResult, nil)
//        
//        sut.fullName = "John Doe"
//        sut.email = "test@example.com"
//        sut.password = "Password123!"
//        
//        // When
//        sut.onSignUpWithEmailPassword(email: sut.email, password: sut.password)
//        
//        // Then
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            XCTAssertTrue(self.sut.isSignedUp)
//            XCTAssertFalse(self.sut.isLoading)
//            XCTAssertFalse(self.sut.showError)
//            XCTAssertNil(self.sut.errorMessage)
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 1.0)
//    }
//    
//    func testSignUp_Failure() {
//        // Given
//        let expectation = XCTestExpectation(description: "Sign up failure")
//        let mockError = NSError(domain: "auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])
//        MockAuth.mockResult = (nil, mockError)
//        
//        sut.fullName = "John Doe"
//        sut.email = "test@example.com"
//        sut.password = "Password123!"
//        
//        // When
//        sut.onSignUpWithEmailPassword(email: sut.email, password: sut.password)
//        
//        // Then
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            XCTAssertFalse(self.sut.isSignedUp)
//            XCTAssertFalse(self.sut.isLoading)
//            XCTAssertTrue(self.sut.showError)
//            XCTAssertEqual(self.sut.errorMessage, "Failed to create user")
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 1.0)
//    }
//}
//
//// MARK: - Mock Objects
//
//class MockUser {
//    let uid: String
//    let email: String?
//    var displayName: String?
//    
//    init(uid: String, email: String?, displayName: String? = nil) {
//        self.uid = uid
//        self.email = email
//        self.displayName = displayName
//    }
//}
//
//class MockAuthDataResult {
//    let user: MockUser
//    
//    init(user: MockUser) {
//        self.user = user
//    }
//}
//
//// MARK: - Mock Auth
//
//class MockAuth {
//    static var mockResult: (MockAuthDataResult?, Error?)?
//    
//    static func reset() {
//        mockResult = nil
//    }
//    
//    static func createUser(withEmail email: String, password: String, completion: @escaping (MockAuthDataResult?, Error?) -> Void) {
//        completion(mockResult?.0, mockResult?.1)
//    }
//}
//
//// MARK: - Firebase Mock Implementations
