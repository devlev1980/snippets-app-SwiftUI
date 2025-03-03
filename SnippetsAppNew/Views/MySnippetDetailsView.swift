//
//  MySnippetDetailsView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 22/02/2025.
//

import SwiftUI
import FirebaseCore

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
    @State private var showSaveSuccess: Bool = false
    @State private var successMessage: String = "Snippet updated successfully!"
    @State private var isDisabledCode: Bool = true
    
    init(vm: SnippetsViewModel, isBookmarked: Bool = false, navigateFrom: NavigateFromView, snippet: Snippet, isEditing: Bool = false) {
        self._vm = State(initialValue: vm)
        self._isBookmarked = State(initialValue: isBookmarked)
        self.navigateFrom = navigateFrom
        self._currentSnippet = State(initialValue: snippet)
        self._isEditing = State(initialValue: isEditing)
    }
    
    var body: some View {
        Section{
            VStack(alignment: .leading) {
                HStack {
                    HStack {
//                        Text(snippet.name)
//                            .font(.headline)
//                            .fontWeight(.bold)
                        if isEditing {
                            TextField(currentSnippet.name, text: $editableName)
                                .font(.headline)
                                .fontWeight(.bold)
                        } else {
                            Text(currentSnippet.name)
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        if !isEditing {
                            Image(systemName: "pencil")
                                .onTapGesture {
                                    // Initialize with current name when starting to edit
                                    editableName = currentSnippet.name
                                    isEditing.toggle()
                                }
                        } else {
                            HStack(spacing: 10) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.red)
                                    .onTapGesture {
                                        // Cancel editing without saving
                                        editableName = currentSnippet.name
                                        isEditing = false
                                    }
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.green)
                                    .onTapGesture {
                                        saveSnippetName()
                                    }
                            }
                        }
                        
                    }
                    
                    Spacer()
                    if navigateFrom == .mySnippetsView {
                        Image(
                            systemName:  isBookmarked ? "bookmark.fill" : "bookmark"
                        )
                        .foregroundStyle(Color.indigo)
                        .onTapGesture {
                            isBookmarked.toggle()
                            onAddToFavoriteSnippets(snippet: currentSnippet)
                        }
                        .onAppear {
                            if currentSnippet.isFavorite {
                                isBookmarked = true
                            }else{
                                isBookmarked = false
                            }
                        }
                    }
                    
                    
                }
//                .overlay(
//                    
//                    .padding(.top, 30), // Position it below the main content
//                    alignment: .top
//                )
                Text(currentSnippet.description)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                
                
                
                HStack {
                    ForEach(currentSnippet.tags, id: \.self) { tag in
                        TagView(
                            tag: tag,
                            hexColor: (currentSnippet.tagBgColors?[tag])!
                            
                        )
                        
                        
                    }
                }
                // Code section with edit controls
                VStack(alignment: .trailing) {
                    HStack {
//                        if !isEditingCode {
//                            Text("View Only")
//                                .font(.caption)
//                                .foregroundStyle(Color.secondary)
//                                
//                        } else {
//                            Text("Editing Mode")
//                                .font(.caption)
//                                .foregroundStyle(Color.green)
//
//                        }
//                        Spacer()
                        if !isEditingCode {
                            Image(systemName: "pencil")
                                .onTapGesture {
                                    // Initialize with current code when starting to edit
                                    editableCode = currentSnippet.code
                                    isEditingCode.toggle()
                                    // Enable editing when pencil is tapped
                                    isDisabledCode = false
                                }
                        } else {
                            HStack(spacing: 10) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.red)
                                    .onTapGesture {
                                        // Cancel editing without saving
                                        editableCode = currentSnippet.code
                                        isEditingCode = false
                                        // Disable editing when canceling
                                        isDisabledCode = true
                                    }
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.green)
                                    .onTapGesture {
                                        saveSnippetCode()
                                        // Disable editing after saving
                                        isDisabledCode = true
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        if isEditingCode {
                            // Use the editable code when in edit mode
                            CodeEditorView(code: $editableCode, language: vm.selectedLanguage, isDisabled: isDisabledCode)
                                .font(.body)
                                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.5))
                                .lineLimit(nil)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.height * 0.5)
                                .background(Color.indigo.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(style: StrokeStyle(lineWidth: 1))
                                        .foregroundColor(Color.gray.opacity(0.3))
                                )
                        } else {
                            // Use the current snippet code when not in edit mode
                            CodeEditorView(code: .constant(currentSnippet.code), language: vm.selectedLanguage, isDisabled: true)
                                .font(.body)
                                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.5))
                                .lineLimit(nil)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.height * 0.5)
                                .background(Color.indigo.opacity(0.1))
                                .cornerRadius(8)
                                .disabled(true) // Always disabled in view mode
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(style: StrokeStyle(lineWidth: 1))
                                        .foregroundColor(Color.gray.opacity(0.3))
                                )
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.top, 20)
                HStack(alignment: .center) {
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
                Spacer()
                
            }
            
        }
        .padding()
        .onAppear {
            // Ensure code editor is disabled by default
            isDisabledCode = true
        }
    }
    func onAddToFavoriteSnippets(snippet: Snippet) {
        let newFavoriteStatus = !snippet.isFavorite
        vm.addFavorite(isFavorite: newFavoriteStatus, snippet: snippet)
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
                    await vm.fetchSnippets()
                    
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
                    await vm.fetchSnippets()
                    
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
        
        // Exit editing mode
        isEditingCode = false
        isDisabledCode = true
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
