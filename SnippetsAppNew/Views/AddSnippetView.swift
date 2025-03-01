//
//  AddSnippetView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 22/02/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

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

    @Environment(\.dismiss) var dismiss
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading) {
                
                Text("Title")
                TextFieldView(placeholder: "Title", text: $snippetTitle)
                
                Text("Description")
                TextFieldView(placeholder: "Description", text: $snippetDescription)
                
                
                Text("Tags")
                TagInputView(currentTag: $currentTag, onAddTag: addTag)
                
                Toggle("Favorite snippet", isOn: $isChecked)
                    .toggleStyle(SwitchToggleStyle())
                    .padding(.vertical, 10)
                
                if !snippetTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(snippetTags.enumerated()), id: \.element) { index, tag in
                                
                                HStack {
                                    TagView(
                                        tag: tag,
                                        hexColor: tagBgColors[tag] ?? ""
                                        
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
                
                Text("Code")
                TextEditor(text: $snippetCode)
                    .frame(minHeight: 200)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.indigo, lineWidth: 1)
                    )
                    .cornerRadius(10)
                
                
                Button {
                    print("Add snippet")
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
                
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .padding(.top,isIpad ? 10 :  30)
            }
            .padding()
            .onChange(of: viewModel.didAddSnippet) {
                if viewModel.didAddSnippet {
                    dismiss()
                }
              
                viewModel.didAddSnippet = false
            }
            
            .navigationTitle("Add Snippet")
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
            
    }
    
    func addTag() {
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
    }
    func removeTag(at index: Int) {
        snippetTags.remove(at: index)
        viewModel.onDeleteTag(at: index)
    }
    func onSaveSnippet() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            return
        }
        let timestamp: Timestamp = .init()
        
        let newSnippet: Snippet = .init(
            name: snippetTitle,
            description: snippetDescription,
            timestamp: timestamp,
            isFavorite: isChecked,
            tags: snippetTags,
            code: snippetCode,
            userEmail: currentUserEmail,
            tagBgColors: tagBgColors
        )
        
        print("Snippet to add: \(newSnippet)")
        viewModel.addSnippet(snippet: newSnippet)
        if isChecked {
            viewModel.addFavorite(isFavorite: isChecked, snippet: newSnippet)
        }
        

        
        
       
        
       
        
        
        
    }
    
    
    
}

#Preview {
    AddSnippetView(viewModel: .init())
}
