//
//  MySnippetDetailsView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 22/02/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import Foundation



struct MySnippetDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var vm: SnippetsViewModel
    @State var isBookmarked: Bool = false
    @State var editableName: String = ""
    @State var editableCode: String = ""
    let navigateFrom: NavigateFromView
    @State private var currentSnippet: Snippet
    @State var isEditing: Bool = false
    @State var isEditingCode: Bool = false
    @State var isEditingTags: Bool = false
    @State var isEditingDescription: Bool = false
    @State private var editableDescription: String = ""
    @State private var editableTags: [String] = []
    @State private var newTag: String = ""
    @State private var tagBgColors: [String: String] = [:]
    @State private var showSaveSuccess: Bool = false
    @State private var successMessage: String = "Snippet updated successfully!"
    @State private var isDisabledCode: Bool = true
    @State private var detectedLanguage: String = "typescript"
    @State private var selectedTheme: String? = nil
    @State private var showThemeOptions: Bool = false
    @State private var selectedTag: String? = nil
    @State private var showColorPicker: Bool = false
    @State private var choosenColor: String? = "#FFFFFF"
    
    let options: [String] = ["swift", "python", "javascript", "java", "c++", "ruby", "go", "kotlin", "c#", "php", "bash", "sql", "typescript", "scss", "less", "html", "xml", "markdown", "json", "yaml", "dart", "rust", "swiftui", "objective-c", "kotlinxml", "scala", "elixir", "erlang", "clojure", "groovy", "swiftpm", "css"]
    
    init(vm: SnippetsViewModel, isBookmarked: Bool = false, navigateFrom: NavigateFromView, snippet: Snippet, isEditing: Bool = false) {
        self._vm = State(initialValue: vm)
        self._isBookmarked = State(initialValue: isBookmarked)
        self.navigateFrom = navigateFrom
        self._currentSnippet = State(initialValue: snippet)
        self._isEditing = State(initialValue: isEditing)
    }
    
    private func detectLanguage() {
        // Use CoreML for language detection
        if let detectedLanguage = ProgrammingLanguageDetector.shared.detectLanguage(from: currentSnippet.code) {
            self.detectedLanguage = detectedLanguage
        } else {
            // Default fallback if detection fails
            self.detectedLanguage = "typescript"
        }
        
        // Update the ViewModel's selected language
        vm.selectedLanguage = detectedLanguage
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Indigo background with opacity 0.2 for the entire screen
                Color.indigo
                    .opacity(0.2)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading) {
                        // Title section
                        HStack {
                            if isEditing {
                                TextField(currentSnippet.name, text: $editableName)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .textFieldStyle(.plain)
                                    .padding(.bottom, 4)
                                    .background(
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.gray)
                                            .offset(y: 12)
                                    )
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.red)
                                        .onTapGesture {
                                            editableName = currentSnippet.name
                                            isEditing = false
                                        }
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                        .onTapGesture {
                                            saveSnippetName()
                                        }
                                }
                            } else {
                                Text(currentSnippet.name)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                Spacer()
                                Image(systemName: "pencil")
                                    .onTapGesture {
                                        editableName = currentSnippet.name
                                        isEditing.toggle()
                                    }
                                
                              
                                
                                if navigateFrom == .mySnippetsView {
                                    Image(systemName: isBookmarked ? "star.fill" : "star")
                                        .foregroundStyle(.indigo)
                                        .onTapGesture {
                                            isBookmarked.toggle()
                                            onAddToFavoriteSnippets(snippet: currentSnippet)
                                        }
                                }
                            }
                        }
                        
                        // Description section
//                    Text("Description")
//                        .font(.headline)
                        
                        HStack(alignment: .top){
                            if isEditingDescription {
                                TextField(currentSnippet.description, text: $editableDescription)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                    .textFieldStyle(.plain)
                                    .padding(.bottom, 4)
                                    .background(
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.gray)
                                            .offset(y: 12)
                                    )
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.red)
                                        .onTapGesture {
                                            editableDescription = currentSnippet.description
                                            isEditingDescription = false
                                        }
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                        .onTapGesture {
                                            saveSnippetDescription()
                                        }
                                }
                            } else {
                                Text(currentSnippet.description)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                    .padding(.bottom)
                                    .padding(.top,5)
                                Spacer()
                                Image(systemName: "pencil")
                                    .onTapGesture {
                                        editableDescription = currentSnippet.description
                                        isEditingDescription = true
                                    }
                            }
                        }
                    
                        
                        // Tags section
                        HStack {
                            Text("Tags")
                                .font(.headline)
                            Spacer()
                            
                            if isEditingTags {
                                HStack(spacing: 10) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.red)
                                        .onTapGesture {
                                            // Just exit editing mode without saving any changes
                                            isEditingTags = false
                                            // Clear any partially edited data
                                            editableTags = []
                                            newTag = ""
                                            // No need to modify the database on cancel
                                            // Discard any changes by not calling saveSnippetTags()
                                        }
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                        .onTapGesture {
                                            saveSnippetTags()
                                        }
                                }
                            } else {
                                Image(systemName: "pencil")
                                    .onTapGesture {
                                        // Initialize editable tags from current snippet when entering edit mode
                                        editableTags = currentSnippet.tags
                                        tagBgColors = currentSnippet.tagBgColors ?? [:]
                                        isEditingTags.toggle()
                                    }
                            }
                        }
                        
                       
                        if isEditingTags {
                            VStack(alignment: .leading) {
                                // Tag input field
                                TagInputView(currentTag: $newTag, onAddTag: {
                                    // Try to add the tag first
                                    addTag()
                                })
                                .padding(.vertical, 8)
                                
                                // Display editable tags
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(Array(editableTags.enumerated()), id: \.element) { index, tag in
                                            HStack {
                                                TagView(
                                                    tag: tag,
                                                    hexColor: tagBgColors[tag] ?? ""
                                                )
                                                .contentShape(Rectangle())
                                                
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(Color.red)
                                                    .onTapGesture {
                                                        removeTag(at: index)
                                                    }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.bottom)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(currentSnippet.tags, id: \.self) { tag in
                                        TagView(
                                            tag: tag,
                                            hexColor: (currentSnippet.tagBgColors?[tag])!
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedTag = tag
                                            choosenColor = vm.getTagBackgroundColor(tag: tag) ?? "#FFFFFF"
                                            showColorPicker = true
                                        }
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                     
                        
                       
                        
                        // Code section
                      
                        VStack(alignment: .trailing) {
                            HStack {
                                Text("Code")
                                    .font(.headline)
                                Spacer()
                                HStack {
                                    
                                    if !isEditingCode {
                                        Image(systemName: "pencil")
                                            .onTapGesture {
                                                editableCode = currentSnippet.code
                                                isEditingCode.toggle()
                                                isDisabledCode = false
                                            }
                                    } else {
                                        HStack(spacing: 10) {
                                            Picker("Select language", selection: $detectedLanguage) {
                                                ForEach(options, id: \.self) { option in
                                                    Text(option).tag(option)
                                                        .foregroundStyle(.indigo)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.indigo, lineWidth: 1))
                                            .tint(Color.indigo)
                                            .onChange(of: detectedLanguage) {
                                                vm.setSelectedLanguage(language: detectedLanguage)
                                            }
                                            
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(Color.red)
                                                .onTapGesture {
                                                    editableCode = currentSnippet.code
                                                    isEditingCode = false
                                                    isDisabledCode = true
                                                }
                                            
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.green)
                                                .onTapGesture {
                                                    saveSnippetCode()
                                                    isDisabledCode = true
                                                }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                         
                       
                            
                            if isEditingCode {
                                CodeView(
                                    code: $editableCode,
                                    language: detectedLanguage,
                                    isDisabled: false,
                                    showLineNumbers: false,
                                    fontSize: 14,
                                    theme: selectedTheme
                                )
                                .frame(minHeight: 200)
                                .padding(.vertical, 8)
                                .id(detectedLanguage)
                                .onChange(of: editableCode) { _ in
                                    detectLanguage(from: editableCode)
                                }
                            } else {
                                CodeView(
                                    code: .constant(currentSnippet.code),
                                    language: detectedLanguage,
                                    isDisabled: true,
                                    showLineNumbers: false,
                                    fontSize: 14,
                                    theme: selectedTheme
                                )
                                .frame(minHeight: 200)
                                .padding(.vertical, 8)
                                .id(detectedLanguage)
                            }
                        }
                        
                        // Success message
                        if showSaveSuccess {
                            Text(successMessage)
                                .font(.caption)
                                .foregroundStyle(Color.green)
                                .padding(5)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(5)
                                .transition(.opacity)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                
                    .padding()
                    .padding()
               
                }
                .background(Color.clear)
            }
         
        }
        .onAppear {
            isDisabledCode = true
            detectLanguage()
            if currentSnippet.isFavorite {
                isBookmarked = true
            } else {
                isBookmarked = false
            }
        }
        .onChange(of: colorScheme) { _ in
            // Update theme when color scheme changes
            updateTheme()
        }
        .onChange(of: detectedLanguage) { _ in
            // Update theme when language changes
            updateTheme()
        }
    }
    
    func onAddToFavoriteSnippets(snippet: Snippet) {
        let newFavoriteStatus = !snippet.isFavorite
        vm.addFavorite(isFavorite: newFavoriteStatus, snippet: snippet)
    }
    
    func updateTagColor(tag: String, color: String) {
        // Update the tag color in the ViewModel
        vm.updateTagColor(tag: tag, color: color)
        
        // Update the current snippet with the new color
        var updatedTagBgColors = currentSnippet.tagBgColors ?? [:]
        updatedTagBgColors[tag] = color
        
        // Create a new snippet with the updated colors
        var newSnippet = currentSnippet
        newSnippet.tagBgColors = updatedTagBgColors
        
        // Update the current snippet
        currentSnippet = newSnippet
        
        // Show success message
        successMessage = "Tag color updated successfully!"
        withAnimation {
            showSaveSuccess = true
        }
        
        // Hide the success message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSaveSuccess = false
            }
        }
    }
    
    func saveSnippetName() {
        // Only save if the name has actually changed
        if editableName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Don't allow empty names
            editableName = currentSnippet.name
            isEditing = false
            return
        }
        
        if editableName != currentSnippet.name {
            // Update the name in Firebase
            vm.updateSnippetName(snippet: currentSnippet, newName: editableName)
            
            // Create a new snippet with the updated name and preserve the ID
            let updatedSnippet = currentSnippet
            var newSnippet = Snippet(
                name: editableName,
                description: updatedSnippet.description,
                timestamp: updatedSnippet.timestamp,
                isFavorite: updatedSnippet.isFavorite,
                tags: updatedSnippet.tags,
                code: updatedSnippet.code,
                highlightedText: updatedSnippet.highlightedText,
                userEmail: updatedSnippet.userEmail,
                tagBgColors: updatedSnippet.tagBgColors
            )
            
            // Preserve the ID
            newSnippet.id = updatedSnippet.id
            
            // Update the current snippet immediately with the new name
            currentSnippet = newSnippet
            
            // Also refresh from Firebase to ensure consistency
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task {
                  vm.fetchSnippets()
                    
                    // Find the updated snippet in the refreshed list
                    if let refreshedSnippet = vm.snippets.first(where: { $0.id == currentSnippet.id }) {
                        currentSnippet = refreshedSnippet
                    }
                }
            }
            
            // Show success message
            successMessage = "Name updated successfully!"
            withAnimation {
                showSaveSuccess = true
            }
            
            // Hide the success message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSaveSuccess = false
                }
            }
        }
        
        // Exit editing mode
        isEditing = false
    }
    
    func saveSnippetCode() {
        // Only save if the code has actually changed
        if editableCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Don't allow empty codes
            editableCode = currentSnippet.code
            isEditingCode = false
            isDisabledCode = true
            return
        }
        
        if editableCode != currentSnippet.code {
            // Update the code in Firebase
            vm.updateSnippetCode(snippet: currentSnippet, newCode: editableCode)
            
            // Create a new snippet with the updated code and preserve the ID
            let updatedSnippet = currentSnippet
            var newSnippet = Snippet(
                name: updatedSnippet.name,
                description: updatedSnippet.description,
                timestamp: updatedSnippet.timestamp,
                isFavorite: updatedSnippet.isFavorite,
                tags: updatedSnippet.tags,
                code: editableCode,
                highlightedText: updatedSnippet.highlightedText,
                userEmail: updatedSnippet.userEmail,
                tagBgColors: updatedSnippet.tagBgColors
            )
            
            // Preserve the ID
            newSnippet.id = updatedSnippet.id
            
            // Update the current snippet immediately with the new code
            currentSnippet = newSnippet
            
            // Also refresh from Firebase to ensure consistency
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task {
                    vm.fetchSnippets()
                    
                    // Find the updated snippet in the refreshed list
                    if let refreshedSnippet = vm.snippets.first(where: { $0.id == currentSnippet.id }) {
                        currentSnippet = refreshedSnippet
                    }
                }
            }
            
            // Show success message
            successMessage = "Code updated successfully!"
            withAnimation {
                showSaveSuccess = true
            }
            
            // Hide the success message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSaveSuccess = false
                }
            }
        }
        
        // Exit editing mode but maintain theme
        isEditingCode = false
        isDisabledCode = true
    }

    private func updateTheme() {
        // Load saved theme when color scheme changes
        selectedTheme = CodeEditorView.ThemePreferences.getTheme(
            forLanguage: detectedLanguage,
            isDarkMode: colorScheme == .dark
        )
    }

    private func detectLanguage(from code: String) {
        // Use CoreML for language detection
        if let detectedLanguage = ProgrammingLanguageDetector.shared.detectLanguage(from: code) {
            self.detectedLanguage = detectedLanguage
        } else {
            // Default fallback if detection fails
            self.detectedLanguage = "typescript"
        }
    }
    
    func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedTag.isEmpty && !editableTags.contains(trimmedTag) {
            editableTags.append(trimmedTag)
            
            // Generate a random color for the new tag
            let hexColor = vm.randomHexColor()
            tagBgColors[trimmedTag] = hexColor
            
            // Note: We no longer need to clear newTag here
            // as the TagInputView component now handles this
        }
    }
    
    func removeTag(at index: Int) {
        if index >= 0 && index < editableTags.count {
            let tagToRemove = editableTags[index]
            editableTags.remove(at: index)
            tagBgColors.removeValue(forKey: tagToRemove)
            
            // Clear the input field after removing a tag
            newTag = ""
        }
    }
    
    func saveSnippetTags() {
        // Only save if the tags have actually changed
        if editableTags != currentSnippet.tags {
            // Make a local copy of the tags and colors before exiting edit mode
            let tagsToSave = editableTags
            
            // Create clean tagBgColors dictionary with only current tags
            var updatedTagBgColors: [String: String] = [:]
            for tag in tagsToSave {
                updatedTagBgColors[tag] = tagBgColors[tag] ?? vm.randomHexColor()
            }
            
            // Exit editing mode 
            isEditingTags = false
            
            // Update Firestore
            guard let documentID = currentSnippet.id else {
                return
            }
            
            // Immediately update the current snippet to reflect changes
            // This ensures the UI updates immediately
            var updatedSnippet = currentSnippet
            updatedSnippet.tags = tagsToSave
            updatedSnippet.tagBgColors = updatedTagBgColors
            currentSnippet = updatedSnippet
            
            // Also update the ViewModel's copy of the snippet
            if let index = vm.snippets.firstIndex(where: { $0.id == documentID }) {
                vm.snippets[index].tags = tagsToSave
                vm.snippets[index].tagBgColors = updatedTagBgColors
            }
            
            // Update in Firestore
            let db = Firestore.firestore()
            db.collection("SnippetsDB").document(documentID).updateData([
                "tags": tagsToSave,
                "tagBgColors": updatedTagBgColors
            ]) { error in
                if let error = error {
                    print("Error updating tags: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        // Refresh from Firebase as a backup, but we've already updated the UI
                        Task {
                            self.vm.fetchSnippets()
                            
                            DispatchQueue.main.async {
                                // Find and update the refreshed snippet
                                if let refreshedSnippet = self.vm.snippets.first(where: { $0.id == documentID }) {
                                    self.currentSnippet = refreshedSnippet
                                }
                                
                                // Show success message
                                self.successMessage = "Tags updated successfully!"
                                withAnimation {
                                    self.showSaveSuccess = true
                                }
                                
                                // Hide the success message after 2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        self.showSaveSuccess = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            // No changes to save, just exit editing mode
            isEditingTags = false
        }
    }

    func saveSnippetDescription() {
        // Only save if the description has actually changed
        if editableDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Don't allow empty descriptions
            editableDescription = currentSnippet.description
            isEditingDescription = false
            return
        }
        
        if editableDescription != currentSnippet.description {
            // Update the description in Firebase
            vm.updateSnippetDescription(snippet: currentSnippet, newDescription: editableDescription)
            
            // Create a new snippet with the updated description and preserve the ID
            let updatedSnippet = currentSnippet
            var newSnippet = Snippet(
                name: updatedSnippet.name,
                description: editableDescription,
                timestamp: updatedSnippet.timestamp,
                isFavorite: updatedSnippet.isFavorite,
                tags: updatedSnippet.tags,
                code: updatedSnippet.code,
                highlightedText: updatedSnippet.highlightedText,
                userEmail: updatedSnippet.userEmail,
                tagBgColors: updatedSnippet.tagBgColors
            )
            
            // Preserve the ID
            newSnippet.id = updatedSnippet.id
            
            // Update the current snippet immediately with the new description
            currentSnippet = newSnippet
            
            // Also refresh from Firebase to ensure consistency
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task {
                    vm.fetchSnippets()
                    
                    // Find the updated snippet in the refreshed list
                    if let refreshedSnippet = vm.snippets.first(where: { $0.id == currentSnippet.id }) {
                        currentSnippet = refreshedSnippet
                    }
                }
            }
            
            // Show success message
            successMessage = "Description updated successfully!"
            withAnimation {
                showSaveSuccess = true
            }
            
            // Hide the success message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSaveSuccess = false
                }
            }
        }
        
        // Exit editing mode
        isEditingDescription = false
    }
}

#Preview {
    @Previewable  var vm: SnippetsViewModel = .init()
    let code = """
  export enum PatternTypes {
    Numbers = '^[0-9]*$',
    Characters = '^[a-zA-Zא-ת ]*$',
    EnglishCharacters = '^[a-zA-Z ]*$',
    HebrewCharacters = '^[א-ת ]*$',
    CharactersAndNumbers = '^[a-zA-Z0-9 ]*$',
    CharactersAndNumbersHE = '^[a-zA-Zא-ת0-9 ]*$',
    MobilePhone = '^05\\d([-]{0,1})+[1-9]{1}\\d{6}$',
    HomeOrMobilePhoneNumber = '^0(5?[012345678])[^0\\D]{1}\\d{6}$',
    Email = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,10}$',
    OrderContractNumber = '^(36|34)[0-9 ]*$',
    ExpirationDate = '^[0-9/ ]*$',
    SwiftCode = '^[a-zA-Z]{6}[a-zA-Z0-9]{2,5}$',
  }
  export const detailsPattern = `^[a-zA-Zא-ת0-9!@#$%^&*()_+={}/\\':|,.?\\]\\["\\-\\n ]*$`;
"""
    let timestap: Timestamp = .init()
    
    let snippet = Snippet(
        name: "aaa",
        description: "some description",
        timestamp: timestap,
        code: code,
        userEmail: "string1980@gmail.com"
    )
    
    return MySnippetDetailsView(
        vm: vm,
        navigateFrom: NavigateFromView.mySnippetsView,
        snippet: snippet
    )
}

