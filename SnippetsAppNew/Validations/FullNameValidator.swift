//
//  FullNameValidator.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

public extension String {
    
    /// Validates the full name based on several criteria.
    /// - Returns: An array of error messages. If empty, the full name passed all validations.
    func validateFullName() -> [String] {
        var errors: [String] = []
        
        // Check for minimum length.
        if self.count < 10 {
            errors.append("Full name must be at least 10 characters long.")
        }
        
        // Split the string into words using spaces.
        let words = self.split(separator: " ")
        
        // Check that the first character of the first word is capitalized.
        if let firstWord = words.first, let firstChar = firstWord.first {
            if !firstChar.isUppercase {
                errors.append("The first character must be capitalized.")
            }
        } else {
            errors.append("Full name cannot be empty.")
        }
        
        // Check that the first character of each subsequent word is capitalized.
        if words.count > 1 {
            for word in words.dropFirst() {
                if let firstChar = word.first, !firstChar.isUppercase {
                    errors.append("The first character after a space must be capitalized.")
                    break
                }
            }
        }
        
        return errors
    }
}
