//
//  EmailValidator.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import Foundation

public extension String {
    
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    

}
