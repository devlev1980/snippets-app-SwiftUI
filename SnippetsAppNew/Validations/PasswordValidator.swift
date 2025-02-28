//
//  PasswordValidator.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

public extension String {
    
    /// Validates the password based on several criteria.
    /// - Returns: An array of error messages. If empty, the password passed all validations.
    func validatePassword() -> [String] {
        var errors: [String] = []
        
        // Check for minimum length
        if self.count < 6 {
            errors.append("Password must be at least 6 characters long.")
        }
        
        // Check that the first character is capitalized
        if let first = self.first {
            if !first.isUppercase {
                errors.append("The first character must be capitalized.")
            }
        } else {
            errors.append("Password cannot be empty.")
        }
        
        // Check for at least one special character.
        // Define the regex pattern for special characters.
        // This pattern checks for any character in the set: !@#$%^&*(),.?":{}|<>
        let specialCharacterPattern = ".*[!@#$%^&*(),.?\":{}|<>].*"
        if self.range(of: specialCharacterPattern, options: .regularExpression) == nil {
            errors.append("Password must include at least one special character.")
        }
        
        return errors
    }
}
