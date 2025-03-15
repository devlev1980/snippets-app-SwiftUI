//
//  EmailValidator.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import Foundation

public extension String {
    func isValidEmail() -> Bool {
        let pattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        let result = predicate.evaluate(with: self)
        return result
    }
} 
