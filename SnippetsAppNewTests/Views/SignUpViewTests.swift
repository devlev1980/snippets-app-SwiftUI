import XCTest
@testable import SnippetsAppNew

final class SignUpViewTests: XCTestCase {
    var sut: SignUpView!
    
    override func setUp() {
        super.setUp()
        sut = SignUpView()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Form Validation Tests
    
    func testEmailValidation() {
        // Invalid email cases
        sut.email = "invalid.email"
        XCTAssertFalse(sut.isValidEmail)
        
        sut.email = "@domain.com"
        XCTAssertFalse(sut.isValidEmail)
        
        sut.email = "user@"
        XCTAssertFalse(sut.isValidEmail)
        
        // Valid email cases
        sut.email = "test@example.com"
        XCTAssertTrue(sut.isValidEmail)
        
        sut.email = "user.name+tag@domain.co.uk"
        XCTAssertTrue(sut.isValidEmail)
    }
    
    func testPasswordValidation() {
        // Invalid password cases
        sut.password = "short"
        XCTAssertFalse(sut.isValidPassword)
        
        sut.password = "nouppercase123!"
        XCTAssertFalse(sut.isValidPassword)
        
        sut.password = "NOLOWERCASE123!"
        XCTAssertFalse(sut.isValidPassword)
        
        sut.password = "NoNumbers!"
        XCTAssertFalse(sut.isValidPassword)
        
        // Valid password case
        sut.password = "ValidPass123!"
        XCTAssertTrue(sut.isValidPassword)
    }
    
    func testFullNameValidation() {
        sut.fullName = ""
        var errors = sut.fullName.validateFullName()
        XCTAssertTrue(errors.contains("Full name is required"))
        
        sut.fullName = "A"
        errors = sut.fullName.validateFullName()
        XCTAssertTrue(errors.contains("Full name must be at least 2 characters"))
        
        sut.fullName = "John Doe"
        errors = sut.fullName.validateFullName()
        XCTAssertTrue(errors.isEmpty)
    }
    
    // MARK: - Button State Tests
    
    func testSignUpButtonDisabledState() {
        // Initially disabled
        XCTAssertTrue(sut.isDisabled)
        
        // Partially filled form
        sut.email = "test@example.com"
        sut.password = "ValidPass123!"
        XCTAssertTrue(sut.isDisabled) // Still disabled because fullName is empty
        
        // Complete valid form
        sut.fullName = "John Doe"
        XCTAssertFalse(sut.isDisabled)
        
        // Invalid email
        sut.email = "invalid.email"
        XCTAssertTrue(sut.isDisabled)
        
        // Invalid password
        sut.email = "test@example.com"
        sut.password = "short"
        XCTAssertTrue(sut.isDisabled)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorMessageState() {
        // Test error message state
        XCTAssertFalse(sut.showError)
        XCTAssertNil(sut.errorMessage)
        
        // Set error state
        sut.showError = true
        sut.errorMessage = "Test error message"
        
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Test error message")
    }
} 