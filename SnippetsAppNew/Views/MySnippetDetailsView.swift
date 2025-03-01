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
    let navigateFrom: NavigateFromView
    let snippet: Snippet
    
    
    var body: some View {
        Section{
            VStack(alignment: .leading) {
                HStack {
                    Text(snippet.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    if navigateFrom == .mySnippetsView {
                        Image(
                            systemName:  isBookmarked ? "bookmark.fill" : "bookmark"
                        )
                        .foregroundStyle(Color.indigo)
                        .onTapGesture {
                            isBookmarked.toggle()
                            onAddToFavoriteSnippets(snippet: snippet)
                        }
                        .onAppear {
                            if snippet.isFavorite {
                                isBookmarked = true
                            }else{
                                isBookmarked = false
                            }
                        }
                    }
                    
                    
                }
                Text(snippet.description)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                
                
                
                HStack {
                    ForEach(snippet.tags, id: \.self) { tag in
                        TagView(
                            tag: tag,
                            hexColor: (snippet.tagBgColors?[tag])!
                            
                        )
                        
                        
                    }
                }
                ScrollView {
                    CodeEditorView(code: .constant(snippet.code), language: vm.selectedLanguage)
//                    Text(snippet.code)
                        .font(.body)
                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.5) :    Color.black.opacity(0.5))
                        .lineLimit(nil)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.95,height: 300)
                        .background(Color.indigo.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style: StrokeStyle(lineWidth: 1))
                                .foregroundColor(Color.gray.opacity(0.3))
                        )
                }
                .padding(.top,20)
                Spacer()
                
            }
            
        }
        .padding()
    }
    func onAddToFavoriteSnippets(snippet: Snippet) {
        let newFavoriteStatus = !snippet.isFavorite
        vm.addFavorite(isFavorite: newFavoriteStatus, snippet: snippet)
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
    
    
    MySnippetDetailsView(
        vm: vm,
        navigateFrom: NavigateFromView.mySnippetsView,
        snippet: .init(
            name: "aaa",
            description: "some description",
            timestamp:  timestap,
            code: code,
            userEmail: "string1980@gmail.com"
        )
    )
}
