//
//  TagsView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 24/02/2025.
//

import SwiftUI
import FirebaseFirestore

struct TagsView: View {
    @Environment(\.colorScheme) var colorScheme

    @State var vm: SnippetsViewModel // Ensure this is properly initialized
    @State private var selectedTag: String? // Track the selected tag
    @State private var showColorPicker: Bool = false // Control the color picker sheet
    @State private var choosenColor: String? = "#FFFFFF" // Default color as a hex string
    @State private var newTagName: String = "" // New tag name input
    @State private var showAddTagSheet: Bool = false // Show add tag sheet
    @State private var newTagColor: Color = .blue // Color for the new tag
    
    var textColor: Color {
        colorScheme == .light ? .black : .white
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Indigo background with opacity 0.2 for the entire screen
                Color.indigo
                    .opacity(0.2)
                    .ignoresSafeArea()
                
                Group {
                    if vm.filteredTags.isEmpty {
                        VStack {
                            Image(.noSnippets)
                            Text("No tags found")
                                .font(.title2)
                                .foregroundStyle(textColor.opacity(0.5))
                            Text("Please add some tags to your tags list")
                                .font(.headline)
                                .foregroundStyle(textColor.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top,190)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                        .padding()
                    }
                    
                    if vm.filteredTags.isEmpty && !vm.searchText.isEmpty {
                        Text("No tags match your search")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(vm.filteredTags, id: \.self) { tag in
                                    HStack(spacing: 5) {
                                        Rectangle()
                                            .fill(Color(hex: vm.getTagBackgroundColor(tag: tag) ?? "")?.opacity(0.5) ?? .clear)
                                            .frame(width: 10)
                                            .frame(maxHeight: .infinity)
                                        
                                        Text(tag)
                                            .padding(.leading, 5)
                                            .padding(.vertical, 12)
                                        
                                        Spacer()
                                    }
                                    .background(Color(UIColor.systemBackground))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedTag = tag
                                        choosenColor = vm.getTagBackgroundColor(tag: tag) ?? "#FFFFFF"
                                        showColorPicker = true
                                    }
                                    
                                    Divider()
                                }
                            }
                        }
                    }
                }
           
                .searchable(text: $vm.searchText, prompt: "Search tags")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAddTagSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showColorPicker) {
                let bindingColor = Binding<Color>(
                    get: {
                        if let hex = choosenColor, let color = Color(hex: hex) {
                            return color
                        }
                        return Color.clear
                    },
                    set: { newColor in
                        choosenColor = newColor.toHex() ?? "#FFFFFF"
                    }
                )
                
                VStack {
                    ColorPicker("Choose tag color", selection: bindingColor)
                        .padding()
                    
                    Button("Save") {
                        if let tag = selectedTag, let colorHex = choosenColor {
                            vm.updateTagColor(tag: tag, color: colorHex)
                        }
                        showColorPicker = false
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                }
                .presentationDetents([.height(200)])
            }
            // Sheet for adding a new tag
            .sheet(isPresented: $showAddTagSheet) {
                VStack(spacing: 20) {
                    Text("Add New Tag")
                        .font(.headline)
                        .padding(.top)
                    
                    TextField("Tag name", text: $newTagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    ColorPicker("Tag color", selection: $newTagColor)
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Cancel") {
                            newTagName = ""
                            showAddTagSheet = false
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Save") {
                            saveNewTag()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                        .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding()
                }
                .presentationDetents([.height(250)])
            }
        }
    }
    
    private func saveNewTag() {
        let trimmedTagName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedTagName.isEmpty {
            // Generate hex color from the selected color
            let hexColor = newTagColor.toHex() ?? "#007AFF"
            
            // Create a tag in the database
            createTagInDB(tagName: trimmedTagName, hexColor: hexColor)
            
            // Reset the input fields
            newTagName = ""
            showAddTagSheet = false
        }
    }
    
    // Function to create a tag in database
    @MainActor
    private func createTagInDB(tagName: String, hexColor: String) {
        // First add the tag to the local array
        vm.onAddTag(tag: tagName)
        
        // Create a simple empty snippet with just this tag to ensure it exists in the system
        let timestamp: Timestamp = .init()
        
        // Check if user exists
        if vm.currentUser == nil {
            vm.getCurrentUserFromAuth()
        }
        
        guard let userEmail = vm.currentUser?.email else {
            // Handle the case where user is not authenticated
            return
        }
        
        // Create a small dummy snippet for the tag to exist in
        let newSnippet = Snippet(
            name: "Tag: \(tagName)",
            description: "This is a system snippet to store the tag",
            timestamp: timestamp,
            tags: [tagName],
            code: "",
            userEmail: userEmail,
            tagBgColors: [tagName: hexColor]
        )
        
        // Add to Firestore using the existing method
        // This creates a snippet that contains the tag, giving the tag a place to exist in the system
        let db = Firestore.firestore()
        var snippetData: [String: Any] = [
            "name": newSnippet.name,
            "description": newSnippet.description,
            "tags": newSnippet.tags,
            "code": newSnippet.code,
            "userEmail": newSnippet.userEmail,
            "timestamp": newSnippet.timestamp,
            "isFavorite": false,
            "tagBgColors": [tagName: hexColor]
        ]
        
        db.collection("SnippetsDB").addDocument(data: snippetData) { error in
            if let error = error {
                print("Error adding tag snippet: \(error.localizedDescription)")
            } else {
                print("Tag snippet successfully added!")
            }
        }
    }
}

#Preview {
    TagsView(vm: .init())
} 