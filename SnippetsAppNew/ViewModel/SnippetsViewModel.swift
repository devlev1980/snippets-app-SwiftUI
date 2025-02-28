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
    
    let backgroundColors: [Color ] = [.blue, .green, .yellow, .orange, .pink,.indigo,.purple,.mint,.teal,.red,.orange,.black,.brown,.gray]
    
    
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
            "#000000",  // black
            "#A2845E",  // brown
            "#8E8E93"   // gray
        ]
        
    
    var backgroundColor: Color {
        backgroundColors.randomElement() ?? .indigo
    }
    
    
    
    @MainActor
    func fetchSnippets() {
        isLoading = true
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("No user is signed in")
            self.errorMessage = "User not authenticated"
            self.isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("SnippetsDB")
            .whereField("userEmail", isEqualTo: currentUserEmail) // Filter by userEmail
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
                              let timestamp = data["timestamp"] as? Timestamp // ✅ Extract Firestore Timestamp
                               else {
                            print("Skipping document due to missing fields: \(doc.documentID)")
                            return nil
                        }
 
                        let snippet = Snippet(name: name,
                                                description: description,
                                                timestamp: timestamp,
                                                isFavorite: isFavorite,
                                                tags: tags,
                                                code: code,
                                              userEmail: userEmail, tagBgColor: self.backgroundColor)
                          // Assign the document ID to the snippet.
                          return snippet
                    }
                    
                    print("Snippets loaded: \(self.snippets.count)")
                }
            }
    }
    @MainActor
    func addSnippet(snippet: Snippet) {

           // Prepare data to be stored.
           let snippetData: [String: Any] = [
               "name": snippet.name,
               "description": snippet.description,
               "tags": snippet.tags,
               "code": snippet.code,
               "userEmail": snippet.userEmail,
               "timestamp": snippet.timestamp,
               "isFavorite": snippet.isFavorite,
               "tagBgColor": snippet.tagBgColor ?? "#FFFFFF",
               
           ]
           
           let db = Firestore.firestore()
           
           // Create a mutable copy of the snippet so we can update its id.
           var newSnippet = snippet
        var ref: DocumentReference? = nil
           
           // Add the snippet to Firestore.
           ref = db.collection("SnippetsDB").addDocument(data: snippetData) { error in
               DispatchQueue.main.async {
                   if let error = error {
                       self.errorMessage = "Error adding snippet: \(error.localizedDescription)"
                       print("Error adding snippet: \(error.localizedDescription)")
                   } else {
                       // Capture and assign the document ID to the snippet.
//                       newSnippet.id = ref?.documentID
                       self.snippets.append(newSnippet)
                       print("Snippet added successfully with ID: \(String(describing: ref?.documentID))")
                       self.isLoading = false
                       self.didAddSnippet = true // Trigger sheet dismissal or UI update.
                   }
               }
           }
    }
    @MainActor
    func addFavorite(isFavorite: Bool,snippet: Snippet) {
        guard let documentID = snippet.id else {
            print("Error: Snippet does not have a valid document ID.")
            self.errorMessage = "Snippet document ID missing."
            return
        }
        
        guard let chosenColor = backgroundColors.randomElement(),
              let colorIndex = backgroundColors.firstIndex(of: chosenColor) else {
            self.errorMessage = "Error selecting color for tag."
            return
        }
        
        let hexColor = backgroundHexColors[colorIndex]
        
        // Prepare the updated data dictionary
        let updatedData: [String: Any] = [
            "name": snippet.name,
            "description": snippet.description,
            "tags": snippet.tags,
            "code": snippet.code,
            "userEmail": snippet.userEmail,
            "timestamp": hexColor,
            "isFavorite": isFavorite
        ]
        
        let db = Firestore.firestore()
        
        // Update the document in the "SnippetsDB" collection using its document ID.
        db.collection("SnippetsDB").document(documentID).updateData(updatedData) { error in
            if let error = error {
                print("Error updating snippet: \(error.localizedDescription)")
                self.errorMessage = "Error updating snippet: \(error.localizedDescription)"
            } else {
                print("Snippet updated successfully.")
                if isFavorite {
                    self.favoriteSnippets.append(snippet)
                }else{
                   self.favoriteSnippets.removeAll { $0.id == snippet.id }
                }
              
                // Optionally, update your local snippets array if needed.
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
        
        // Randomly select a background color and determine its HEX value.
//                guard let chosenColor = backgroundColors.randomElement(),
//                      let colorIndex = backgroundColors.firstIndex(of: chosenColor) else {
//                    self.errorMessage = "Error selecting color for tag."
//                    return
//                }
//                
//                let hexColor = backgroundHexColors[colorIndex]
                
                // Prepare the data to store in Firestore.
//                let tagData: [String: Any] = [
//                    "name": tag,
//                    "backgroundColor": hexColor
//                ]
                
                // Store the tag in the "TagsDB" collection.
//                let db = Firestore.firestore()
//        db.collection("TagsDB").addDocument(data: tagData) { error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("Error adding tag: \(error.localizedDescription)")
//                    self.errorMessage = "Error adding tag: \(error.localizedDescription)"
//                } else {
//                    print("Tag added successfully with HEX color: \(hexColor)")
//                }
//            }
//        }
        
    }
    func onDeleteTag(at index: Int) {
        tags.remove(at: index)
//            let db = Firestore.firestore()
//            
//            // Query Firestore for documents in "TagsDB" where the "name" matches.
//            db.collection("TagsDB").whereField("name", isEqualTo: index).getDocuments { snapshot, error in
//                if let error = error {
//                    DispatchQueue.main.async {
//                        self.errorMessage = "Error deleting tag: \(error.localizedDescription)"
//                    }
//                    return
//                }
//                
//                guard let snapshot = snapshot, !snapshot.documents.isEmpty else {
//                    // If no document is found, simply remove the tag locally.
//                    DispatchQueue.main.async {
//                        self.tags.remove(at: index)
//                        print("No matching tag found in Firebase. Removed locally.")
//                    }
//                    return
//                }
//                
//                // Use a dispatch group to wait for all deletion operations to complete.
//                let deletionGroup = DispatchGroup()
//                
//                for document in snapshot.documents {
//                    deletionGroup.enter()
//                    document.reference.delete { err in
//                        if let err = err {
//                            DispatchQueue.main.async {
//                                self.errorMessage = "Error deleting tag document: \(err.localizedDescription)"
//                            }
//                        }
//                        deletionGroup.leave()
//                    }
//                }
//                
//                // Once all deletions are complete, remove the tag from the local array.
//                deletionGroup.notify(queue: .main) {
//                    self.tags.remove(at: index)
//                    print("Tag '\(tagToDelete)' deleted successfully from Firebase.")
//                }
//            }
    }
    
}

