//
//  AddSnippetView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 22/02/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

// Add import for our utilities
import Foundation

struct AddSnippetView: View {
    @State var viewModel : SnippetsViewModel
    @State private var snippetTitle: String = ""
    @State private var snippetDescription: String = ""
    @State private var currentTag: String = ""
    @State private var snippetTags: [String] = []
    @State private var snippetCode: String = ""
    @State private var index: Int = 0
    @State private var isLoading: Bool = false
    @State private var isChecked = false
    @State private var tagBgColors: [String: String] = [:]
    @State var selectedLanguage: String = "typescript"
    @State private var selectedTheme: String? = nil
    @State private var showThemeOptions: Bool = false
    @State private var forceCodeViewRefresh: UUID = UUID()
    
    let options: [String] = ["swift", "python", "javascript", "java", "c++", "ruby", "go", "kotlin", "c#", "php", "bash", "sql", "typescript", "scss", "less", "html", "xml", "markdown", "json", "yaml", "dart", "rust", "swiftui", "objective-c", "kotlinxml", "scala", "elixir", "erlang", "clojure", "groovy", "swiftpm", "css"]

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    var isDisabled: Bool {
        snippetTitle.isEmpty || snippetDescription.isEmpty || selectedLanguage.isEmpty || snippetCode.isEmpty
    }
    
    private func detectLanguage() {
        // Use our CoreML language detector
        if let detectedLanguage = ProgrammingLanguageDetector.shared.detectLanguage(from: snippetCode) {
            selectedLanguage = detectedLanguage
        } else {
            // Default fallback if detection fails
            selectedLanguage = "plaintext"
        }
        
        // Update the ViewModel's selected language
        viewModel.setSelectedLanguage(language: selectedLanguage)
    }
    
    private func updateTheme() {
        // Load saved theme based on current language and color scheme
        selectedTheme = CodeEditorView.ThemePreferences.getTheme(
            forLanguage: selectedLanguage == "" ? "swift" : selectedLanguage,
            isDarkMode: colorScheme == .light
        )
        // Force CodeView to redraw
        forceCodeViewRefresh = UUID()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.indigo
                    .opacity(0.2)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        Text("Title")
                        TextFieldView(placeholder: "Title", text: $snippetTitle)
                        
                        Text("Description")
                        TextFieldView(placeholder: "Description", text: $snippetDescription)
                        
                        
                        Text("Tags")
                        TagInputView(currentTag: $currentTag, onAddTag: addTag)
                  
                        HStack {
                            Toggle("Add to favorites", isOn: $isChecked)
                                .toggleStyle(SwitchToggleStyle())
                                .padding(.vertical, 5)
                            Spacer()
                            
                            Picker("Select an option", selection: $selectedLanguage) {
                                           ForEach(options, id: \.self) { option in
                                               Text(option).tag(option)
                                                   .foregroundStyle(.indigo)
                                           }
                                       }
                                       .pickerStyle(MenuPickerStyle())
                                       .background(RoundedRectangle(cornerRadius: 8).stroke(Color.indigo, lineWidth: 1))
                                       .tint(Color.indigo)
                                       .onChange(of: selectedLanguage) {
                                           viewModel.setSelectedLanguage(language: selectedLanguage)
                                       }
                            
                            Spacer()
                            
                        }
                        
                      
                        
                        if !snippetTags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(Array(snippetTags.enumerated()), id: \.element) { index, tag in
                                        
                                        HStack {
                                            TagView(
                                                tag: tag,
                                                hexColor:  ""
                                                
                                            )
                                            .font(.caption)
                                         
                                            
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.indigo)
                                                .onTapGesture {
                                                    removeTag(at: index)
                                                }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .foregroundStyle(.indigo)
                                        .background(Color(hex: tagBgColors[tag] ?? "")?.opacity(0.3))
                                        .clipShape(.rect(cornerRadius: 10))
                                        
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        
                        
                        
                        Section(header: Text("Code")) {
                            VStack(alignment: .trailing) {
                                CodeView(
                                    code: $snippetCode,
                                    language: selectedLanguage,
                                    isDisabled: false,
                                    showLineNumbers: false,
                                    fontSize: 14,
                                    theme: selectedTheme
                                )
                                .frame(minHeight: 200)
                                .padding(.vertical, 8)
                                .id(forceCodeViewRefresh)
                                .onChange(of: snippetCode) { _ in
                                    detectLanguage()
                                }
                            }
                        }
                        
                        
                        Button {
                            isLoading = true
                            
                            onSaveSnippet()
                        } label: {
                            HStack {
                                Text("Add snippet")
                                    .fontWeight(.bold)
                                
                               

                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                
                            }
                        
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            
                        }
                        .disabled(isDisabled)
                        
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                        .padding(.top,isIpad ? 10 :  10)
                    }
                    .padding()
                    .onChange(of: viewModel.didAddSnippet) {
                        if viewModel.didAddSnippet {
                            dismiss()
                        }
                      
                        viewModel.didAddSnippet = false
                    }
                }
            }
         
            
            
            .navigationTitle("Add Snippet")
            
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.indigo)
                }
            }
        }
        .onAppear {
            // Load saved theme
            forceCodeViewRefresh = UUID()
            updateTheme()
        }
        .onChange(of: colorScheme) { _ in
            // Update theme when color scheme changes
            updateTheme()
        }
        .onChange(of: selectedLanguage) { _ in
            // Update theme when language changes
            updateTheme()
        }
        .onChange(of: selectedTheme) { _ in
            // Force redraw of the CodeView when theme changes
            // This is needed to make sure the theme is applied immediately
            forceCodeViewRefresh = UUID()
        }
    }
    
    func addTag() {
        let trimmedTag = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedTag.isEmpty {
            snippetTags.append(trimmedTag)
            let hexColor = viewModel.randomHexColor()
            tagBgColors[trimmedTag] = hexColor
            
            // Note: We no longer need to clear currentTag here
            // as the TagInputView component now handles this
        }
    }
    func removeTag(at index: Int) {
        snippetTags.remove(at: index)
//        viewModel.onDeleteTag(at: index)
    }
    func onSaveSnippet() {
        if viewModel.currentUser == nil {
            viewModel.getCurrentUserFromAuth()
        }
        
        guard let userEmail = viewModel.currentUser?.email else {
            // Handle the case where user is not authenticated
            return
        }
        
        let timestamp: Timestamp = .init()
        
        
        let trimmedTag = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedTag.isEmpty {
            snippetTags.append(trimmedTag)
            let hexColor = viewModel.randomHexColor()
            tagBgColors[trimmedTag] = hexColor
            viewModel.onAddTag(tag: trimmedTag)
            DispatchQueue.main.async {
                currentTag = ""
            }
        }
        
        
        let newSnippet: Snippet = .init(
            name: snippetTitle,
            description: snippetDescription,
            timestamp: timestamp,
            isFavorite: isChecked,
            tags: snippetTags,
            code: snippetCode,
            userEmail: userEmail,
            tagBgColors: tagBgColors
        )
        
        viewModel.addSnippet(snippet: newSnippet)
        if isChecked {
            viewModel.addFavorite(isFavorite: isChecked, snippet: newSnippet)
        }
        

        
        
       
        
       
        
        
        
    }
    
    
    
}

#Preview {
    AddSnippetView(viewModel: .init(),selectedLanguage: "swift")
}
