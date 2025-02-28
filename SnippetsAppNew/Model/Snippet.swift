//
//  Snippet.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 22/02/2025.
//
import SwiftUI
import Foundation
import FirebaseCore
import FirebaseFirestore

struct Snippet : Identifiable {
    @DocumentID var id: String?
    let name: String
    let description: String
    let code: String
    var timestamp: Timestamp
    var isFavorite: Bool
    var tags: [String]
    var userEmail: String
    var tagBgColors: [String: String]? // Map tag names to hex color strings
    
    init(
        name: String,
        description: String,
        timestamp: Timestamp,
        isFavorite: Bool = false,
        tags: [String] = [],
        code: String,
        userEmail: String,
        tagBgColors: [String: String]? = nil
    ) {
        self.name = name
        self.description = description
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.tags = tags
        self.code = code
        self.userEmail = userEmail
        self.tagBgColors = tagBgColors
    }
    
  
}
