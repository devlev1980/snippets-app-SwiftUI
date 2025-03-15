//
//  TabView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct MainTabView: View {
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Access the ThemeManager from the environment
    @EnvironmentObject private var themeManager: ThemeManager
    let vm: SnippetsViewModel
    @State private var showingAddSnippet = false
    @State private var showingAddTag = false
    @State private var newTagName: String = "" // New tag name input
     @State private var showAddTagSheet: Bool = false
    @State private var newTagColor: Color = .blue // Color for the new tag
    var body: some View {
        TabView {
            NavigationView {
                MySnippetsView(vm: vm)
                    .navigationTitle("My snippets")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing:
                        Image(systemName: "plus")
                            .foregroundStyle(.indigo)
                            .onTapGesture {
                                showingAddSnippet = true
                            }
                    )
            }
            .tabItem {
                Label("My snippets", systemImage: "doc.text")
            }

            NavigationView {
                FavoritesView(vm: vm)
                    .navigationTitle("Favories")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }
            
            NavigationView {
                TagsView(vm: vm)
                    .navigationTitle("Tags")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing:
                        Image(systemName: "plus")
                            .foregroundStyle(.indigo)
                            .onTapGesture {
                                showAddTagSheet = true
                            }
                    )
                
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
            .tabItem {
                Label("Tags", systemImage: "tag")
            }
            
            NavigationView {
                SettingsView(vm: vm)
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(.indigo)
        // Apply additional accent coloring based on the theme
        .accentColor(.indigo)
        // This makes the tab bar adapt better to theme changes 
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().standardAppearance = appearance
        }
        
        .if(isIpad) { view in
            view.fullScreenCover(isPresented: $showingAddSnippet) {
                NavigationView {
                    AddSnippetView(viewModel: vm,selectedLanguage: "swift")
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button("Cancel") {
                                    showingAddSnippet = false
                                }
                                .tint(.indigo)
                            }
                        }
                }
            }
        }
               .if(!isIpad) { view in
                   view.sheet(isPresented: $showingAddSnippet) {
                       AddSnippetView(viewModel: vm,selectedLanguage: "swift")
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
                   // Remove print statement to avoid seeing it in console
                   // print("Error adding tag snippet: \(error.localizedDescription)")
               } else {
                   // Remove print statement to avoid seeing it in console
                   // print("Tag snippet successfully added!")
               }
           }
       }
}

#Preview {
    MainTabView(vm: SnippetsViewModel())
        .environmentObject(ThemeManager())
}
