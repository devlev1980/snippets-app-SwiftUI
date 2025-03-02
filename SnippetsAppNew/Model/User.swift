//
//  User.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 02/03/2025.
//

import Foundation
import SwiftUI


struct User: Identifiable, Codable {
    var id = UUID()
    var name: String
    var email: String
}
