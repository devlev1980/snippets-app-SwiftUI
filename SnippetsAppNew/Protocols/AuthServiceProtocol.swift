//
//  AuthServiceProtocol.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import Foundation
import FirebaseAuth

public protocol AuthServiceProtocol {
    func createUserInDB(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void)
} 
