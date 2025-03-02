//
//  SnippetsViewModel.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 22/02/2025.
//

import Foundation
import Observation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI


@Observable
class SnippetsViewModel  {
    var snippets: [Snippet] = []
    var errorMessage: String = ""
    var isLoading: Bool = false
    var didAddSnippet: Bool = false
    var favoriteSnippets: [Snippet] = []
    var tags: [String] = []
    var selectedLanguage: String?
    var searchText: String = ""
    var currentUser: User?
    
    let backgroundColors: [Color ] = [.blue, .green, .yellow, .orange, .pink,.indigo,.purple,.mint,.teal,.red,.orange,.brown,.gray]
    
    
    var backgroundHexColors: [String] = [
            "#007AFF",  // blue
            "#34C759",  // green
            "#FFCC00",  // yellow
            "#FF9500",  // orange
            "#FF2D55",  // pink
            "#5856D6",  // indigo
            "#AF52DE",  // purple
            "#00C7BE",  // mint
            "#5AC8FA",  // teal
            "#FF3B30",  // red
            "#FF9500",  // duplicate orange
            "#A2845E",  // brown
            "#8E8E93"   // gray
        ]
        
    
    var backgroundColor: Color {
        backgroundColors.randomElement() ?? .indigo
    }
    
    @MainActor
    func fetchSnippets() {
        isLoading = true
        
        if currentUser == nil {
            getCurrentUserFromAuth()
        }
        
        guard let email = currentUser?.email else {
            print("No user is signed in")
            self.errorMessage = "User not authenticated"
            self.isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("SnippetsDB")
            .whereField("userEmail", isEqualTo: email)
            .getDocuments { snapshot, error in
                Task { @MainActor in
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "Error fetching snippets: \(error.localizedDescription)"
                        print("Firebase Error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        print("Snapshot is nil")
                        return
                    }
                    
                    print("Documents found: \(snapshot.documents.count)")
                    
                    self.snippets = snapshot.documents.compactMap { doc -> Snippet? in
                        let data = doc.data()
                        print("Document Data: \(data)")
                        
                        
                        guard let name = data["name"] as? String,
                              let description = data["description"] as? String,
                              let userEmail = data["userEmail"] as? String,
                              let tags = data["tags"] as? [String],
                              let isFavorite = data["isFavorite"] as? Bool,
                              let code = data["code"] as? String,
                              let timestamp = data["timestamp"] as? Timestamp,
                              let tagBgColors = data["tagBgColors"] as? [String: String] else {
                            print("Skipping document due to missing fields: \(doc.documentID)")
                            return nil
                        }
                        
 
                        var snippet = Snippet(name: name,
                                                description: description,
                                                timestamp: timestamp,
                                                isFavorite: isFavorite,
                                                tags: tags,
                                                code: code,
                                              userEmail: userEmail, tagBgColors: tagBgColors)
                        snippet.id = doc.documentID
                        return snippet
                    }
                    
                    // After collecting unique tags, add this:
                    // Update favoriteSnippets array with snippets where isFavorite is true
                    self.favoriteSnippets = self.snippets.filter { $0.isFavorite }
                    
                    // After loading snippets, collect all unique tags
                    var uniqueTags = Set<String>()
                    for snippet in self.snippets {
                        uniqueTags.formUnion(snippet.tags)
                    }
                    self.tags = Array(uniqueTags).sorted()
                    
                    print("Snippets loaded: \(self.snippets.count)")
                    print("Favorite snippets loaded: \(self.favoriteSnippets.count)")
                    print("Unique tags found: \(self.tags.count)")
                }
            }
    }
    @MainActor
    func addSnippet(snippet: Snippet) {
        // Use the provided tagBgColors if available, otherwise generate new ones
        var tagColors = snippet.tagBgColors ?? [:]
        
        // Generate colors for any tags that don't have them
        for tag in snippet.tags {
            if tagColors[tag] == nil {
                tagColors[tag] = randomHexColor()
            }
        }

        // Prepare data to be stored
        let snippetData: [String: Any] = [
            "name": snippet.name,
            "description": snippet.description,
            "tags": snippet.tags,
            "code": snippet.code,
            "userEmail": snippet.userEmail,
            "timestamp": snippet.timestamp,
            "isFavorite": snippet.isFavorite,
            "tagBgColors": tagColors
        ]
        
        let db = Firestore.firestore()
        var docRef : DocumentReference!
        // Add the snippet to Firestore.
        docRef = db.collection("SnippetsDB").addDocument(data: snippetData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error adding snippet: \(error.localizedDescription)"
                    print("Error adding snippet: \(error.localizedDescription)")
                } else {
                    // Create a new snippet with the document ID
                    var newSnippet = snippet
                    newSnippet.id = docRef.documentID
                    self.snippets.append(newSnippet)
                    print("Snippet added successfully with ID: \(docRef.documentID)")
                    self.isLoading = false
                    self.didAddSnippet = true
                }
            }
        }
    }
    @MainActor
    func addFavorite(isFavorite: Bool, snippet: Snippet) {
        // First try to find the snippet in our local array to get the correct document ID
        guard let existingSnippet = snippets.first(where: { $0.name == snippet.name }) else {
            print("Error: Snippet not found in local array")
            self.errorMessage = "Snippet not found in local array"
            return
        }
        
        guard let documentID = existingSnippet.id else {
            print("Error: Snippet does not have a valid document ID.")
            self.errorMessage = "Snippet document ID missing."
            return
        }
        
        // Create a new snippet with the correct ID for the favorites array
        var snippetWithId = snippet
        snippetWithId.id = documentID
        
        // Prepare the updated data dictionary while preserving existing data
        let updatedData: [String: Any] = [
            "name": snippet.name,
            "description": snippet.description,
            "tags": snippet.tags,
            "code": snippet.code,
            "userEmail": snippet.userEmail,
            "timestamp": snippet.timestamp,
            "isFavorite": isFavorite,
            "tagBgColors": snippet.tagBgColors ?? [:]
        ]
        
        let db = Firestore.firestore()
        
        db.collection("SnippetsDB").document(documentID).updateData(updatedData) { error in
            if let error = error {
                print("Error updating snippet: \(error.localizedDescription)")
                self.errorMessage = "Error updating snippet: \(error.localizedDescription)"
            } else {
                print("Snippet updated successfully.")
                // Update local arrays
                if let index = self.snippets.firstIndex(where: { $0.id == documentID }) {
                    self.snippets[index].isFavorite = isFavorite
                }
                
                if isFavorite {
                    if !self.favoriteSnippets.contains(where: { $0.id == documentID }) {
                        self.favoriteSnippets.append(snippetWithId)
                    }
                } else {
                    self.favoriteSnippets.removeAll { $0.id == documentID }
                }
            }
        }
    }
    @MainActor
    func onDeleteSnippet(index: IndexSet) {
        let snippetsToDelete = index.compactMap { i in snippets[i] }
           
           for snippet in snippetsToDelete {
               // Ensure the snippet has a valid document ID.
               guard let documentID = snippet.id else {
                   self.errorMessage = "Snippet document ID missing."
                   continue
               }
               
               // Delete the snippet from Firestore.
               let db = Firestore.firestore()
               db.collection("SnippetsDB").document(documentID).delete { error in
                   if let error = error {
                       // Update the error message on the main thread.
                       DispatchQueue.main.async {
                           self.errorMessage = "Error deleting snippet: \(error.localizedDescription)"
                       }
                   } else {
                       // On success, remove the snippet from both local arrays.
                       DispatchQueue.main.async {
                           self.snippets.removeAll { $0.id == documentID }
                           self.favoriteSnippets.removeAll { $0.id == documentID }
                       }
                   }
               }
           }
    }
    
    func onAddTag(tag: String) {
        tags.append(tag)
    }
    func onDeleteTag(at index: Int) {
        tags.remove(at: index)
    }
    
    // Add this function to generate random hex color
    func randomHexColor() -> String {
        let color = backgroundColors.randomElement() ?? .indigo
        let index = backgroundColors.firstIndex(of: color) ?? 0
        return backgroundHexColors[index]
    }
    
    func getTagBackgroundColor(tag: String) -> String? {
        // Look through all snippets to find the first occurrence of this tag
        // and return its background color
        for snippet in snippets {
            if snippet.tags.contains(tag),
               let color = snippet.tagBgColors?[tag] {
                return color
            }
        }
        return nil
    }
    
    @MainActor
    func deleteTag(tag: String) {
        let db = Firestore.firestore()
        
        // Get all snippets that contain this tag
        let snippetsToUpdate = snippets.filter { $0.tags.contains(tag) }
        
        for snippet in snippetsToUpdate {
            guard let documentID = snippet.id else { continue }
            
            // Remove the tag from the tags array
            let updatedTags = snippet.tags.filter { $0 != tag }
            
            // Remove the tag from tagBgColors
            var updatedColors = snippet.tagBgColors ?? [:]
            updatedColors.removeValue(forKey: tag)
            
            // Update Firestore
            db.collection("SnippetsDB").document(documentID).updateData([
                "tags": updatedTags,
                "tagBgColors": updatedColors
            ]) { error in
                if let error = error {
                    print("Error updating snippet: \(error.localizedDescription)")
                } else {
                    // Update local snippet
                    if let index = self.snippets.firstIndex(where: { $0.id == documentID }) {
                        self.snippets[index].tags = updatedTags
                        self.snippets[index].tagBgColors = updatedColors
                    }
                }
            }
        }
        
        // Remove tag from local tags array
        if let index = tags.firstIndex(of: tag) {
            tags.remove(at: index)
        }
    }
    
    @MainActor
    func updateTagColor(tag: String, color: String) {
        let db = Firestore.firestore()
        
        // Get all snippets that contain this tag
        let snippetsToUpdate = snippets.filter { $0.tags.contains(tag) }
        
        for snippet in snippetsToUpdate {
            guard let documentID = snippet.id else { continue }
            
            // Update the tag color in the tagBgColors dictionary
            var updatedColors = snippet.tagBgColors ?? [:]
            updatedColors[tag] = color // Set the new color for the tag
            
            // Update Firestore
            db.collection("SnippetsDB").document(documentID).updateData([
                "tagBgColors": updatedColors
            ]) { error in
                if let error = error {
                    print("Error updating tag color: \(error.localizedDescription)")
                } else {
                    // Update local snippet
                    if let index = self.snippets.firstIndex(where: { $0.id == documentID }) {
                        self.snippets[index].tagBgColors = updatedColors
                    }
                }
            }
        }
    }
    
    func setSelectedLanguage(language: String?) {
        selectedLanguage = language
    }
    
    // Filtered snippets based on search text
    var filteredSnippets: [Snippet] {
        if searchText.isEmpty {
            return snippets
        } else {
            let lowercasedQuery = searchText.lowercased()
            return snippets.filter { snippet in
                // Search by name
                if snippet.name.lowercased().contains(lowercasedQuery) {
                    return true
                }
                
                // Search by tag
                for tag in snippet.tags {
                    if tag.lowercased().contains(lowercasedQuery) {
                        return true
                    }
                }
                
                return false
            }
        }
    }
    
    // Filtered favorite snippets
    var filteredFavoriteSnippets: [Snippet] {
        if searchText.isEmpty {
            return favoriteSnippets
        } else {
            let lowercasedQuery = searchText.lowercased()
            return favoriteSnippets.filter { snippet in
                // Search by name
                if snippet.name.lowercased().contains(lowercasedQuery) {
                    return true
                }
                
                // Search by tag
                for tag in snippet.tags {
                    if tag.lowercased().contains(lowercasedQuery) {
                        return true
                    }
                }
                
                return false
            }
        }
    }
    
    // Filtered tags
    var filteredTags: [String] {
        if searchText.isEmpty {
            return tags
        } else {
            let lowercasedQuery = searchText.lowercased()
            return tags.filter { tag in
                tag.lowercased().contains(lowercasedQuery)
            }
        }
    }
    
    func setCurrentUser(name: String, email: String) {
        currentUser = User(name: name, email: email)
    }
    
    func getCurrentUserFromAuth() {
        if let user = Auth.auth().currentUser {
            let email = user.email ?? ""
            let name = user.displayName ?? email.components(separatedBy: "@").first ?? "User"
            setCurrentUser(name: name, email: email)
        }
    }
}

