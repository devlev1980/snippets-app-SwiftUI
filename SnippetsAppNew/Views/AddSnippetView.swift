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
        snippetTitle.isEmpty || snippetDescription.isEmpty || snippetTags.isEmpty || selectedLanguage.isEmpty || snippetCode.isEmpty
    }
    
    private func detectLanguage() {
        // Simple language detection based on code content
        let code = snippetCode.lowercased()
        
        if code.contains("import swift") || code.contains("class") && code.contains("func") && !code.contains("function") 
            || code.contains("@state") || code.contains("@binding") || code.contains("@published") 
            || code.contains("@observedobject") || code.contains("@stateobject") || code.contains("@environment") 
            || code.contains("struct") && code.contains(": view") || code.contains("swiftui") 
            || code.contains("@main") || code.contains("@objc") || code.contains("uikit") {
            selectedLanguage = "swift"
        } else if code.contains("@angular") || code.contains("@component") || code.contains("@injectable") 
            || code.contains("@input") || code.contains("@output") || code.contains("ngonit") 
            || code.contains("ngondestroy") || code.contains("@hostlistener") || code.contains("@pipe") 
            || code.contains("@directive") || code.contains("changedetection") || code.contains("ngmodule") {
            selectedLanguage = "typescript" // Angular TypeScript
        } else if code.contains("react") && (code.contains("import") || code.contains("require")) 
            || code.contains("usestate") || code.contains("useeffect") || code.contains("useref") 
            || code.contains("usememo") || code.contains("usecallback") || code.contains("usecontext") 
            || code.contains("createcontext") || code.contains("reactdom") || code.contains("<jsx") 
            || code.contains("react.component") || code.contains("react.fc") || code.contains("react.fragment") 
            || (code.contains("props") && code.contains("interface")) {
            selectedLanguage = "typescript" // React TypeScript/JavaScript
        } else if code.contains("vue") && (code.contains("definecomponent") || code.contains("createapp")) 
            || code.contains("@vue/composition-api") || code.contains("vue.use") || code.contains("vue.extend") 
            || code.contains("@options") || code.contains("@prop") || code.contains("@watch") 
            || code.contains("@emit") || code.contains("setup()") || code.contains("computed") 
            || code.contains("<template>") || code.contains("v-model") || code.contains("v-if") 
            || code.contains("v-for") || code.contains("vuex") {
            selectedLanguage = "typescript" // Vue TypeScript/JavaScript
        } else if code.contains("qwik") || code.contains("component$") || code.contains("usestore$") {
            selectedLanguage = "typescript" // Qwik TypeScript
        } else if code.contains("svelte") && code.contains("<script") 
            || code.contains("$store") || code.contains("$derived") || code.contains("svelte/store") 
            || code.contains("on:click") || code.contains("bind:") || code.contains("each") 
            || code.contains("#await") || code.contains("#if") || code.contains("@html") 
            || code.contains("sveltekit") || code.contains("svelte:") || code.contains("svelte/motion") {
            selectedLanguage = "typescript" // Svelte TypeScript/JavaScript
        } else if code.contains("next") && code.contains("getstaticprops") {
            selectedLanguage = "typescript" // Next.js TypeScript
        } else if code.contains("nuxt") && code.contains("definenuxtconfig") {
            selectedLanguage = "typescript" // Nuxt TypeScript
        } else if code.contains("interface ") || code.contains("export ") || code.contains("type ") {
            selectedLanguage = "typescript"
        } else if code.contains("function ") || code.contains("const ") || code.contains("let ") {
            selectedLanguage = "javascript"
        } else if code.contains("<html") || code.contains("<!doctype html") 
            || code.contains("<head") || code.contains("<body") || code.contains("<div") 
            || code.contains("<script") || code.contains("<style") || code.contains("<link") 
            || code.contains("<meta") || code.contains("<form") || code.contains("<input") 
            || (code.contains("class=") && code.contains("<")) || (code.contains("id=") && code.contains("<")) 
            || code.contains("data-") || code.contains("aria-") || code.contains("<nav") 
            || code.contains("<section") || code.contains("<article") || code.contains("<footer") 
            || code.contains("<p") || code.contains("<span") || code.contains("<textarea") 
            || code.contains("<h1") || code.contains("<h2") || code.contains("<h3") 
            || code.contains("<h4") || code.contains("<h5") || code.contains("<h6") 
            || code.contains("<table") || code.contains("<tr") || code.contains("<td") 
            || code.contains("<th") || code.contains("<thead") || code.contains("<tbody") 
            || code.contains("<tfoot") || code.contains("<ul") || code.contains("<ol") 
            || code.contains("<li") || code.contains("<label") || code.contains("<select") 
            || code.contains("<option") || code.contains("<button") || code.contains("<a href") {
            selectedLanguage = "html"
        } else if code.contains("@import") || code.contains("{") && code.contains("}") && code.contains(";") 
            || code.contains("@media") || code.contains("@keyframes") || code.contains("@font-face") 
            || code.contains("@supports") || code.contains("!important") || code.contains("rgba(") 
            || code.contains("display:") || code.contains("position:") || code.contains("flex") 
            || code.contains("grid") || code.contains("animation:") || code.contains("transition:") 
            || code.contains("box-shadow:") || code.contains("border-radius:") || code.contains("background:") 
            || (code.contains(".") && code.contains("{") && code.contains(":")) 
            || (code.contains("#") && code.contains("{") && code.contains(":")) {
            selectedLanguage = "css"
        } else if code.contains("<?php") 
            || code.contains("namespace") && code.contains(";") 
            || code.contains("public function") || code.contains("private function") 
            || code.contains("protected function") || code.contains("$this->") 
            || code.contains("extends") && code.contains("class") 
            || code.contains("implements") || code.contains("use ") 
            || code.contains("array()") || code.contains("=>") 
            || code.contains("echo") || code.contains("<?=") {
            selectedLanguage = "php"
        } else if code.contains("package ") && code.contains("import (") 
            || code.contains("func ") || code.contains("type struct") 
            || code.contains("interface{") || code.contains("go ") 
            || code.contains("chan ") || code.contains("defer ") 
            || code.contains("goroutine") || code.contains("select {") 
            || code.contains(":= ") || code.contains("make(") 
            || code.contains("map[") || code.contains("[]") && !code.contains("[]()") {
            selectedLanguage = "go"
        } else if code.contains("#include") 
            || code.contains("std::") || code.contains("cout") 
            || code.contains("cin") || code.contains("vector<") 
            || code.contains("template<") || code.contains("namespace") 
            || code.contains("public:") || code.contains("private:") 
            || code.contains("protected:") || code.contains("->") && !code.contains("$this->") 
            || code.contains("new ") && code.contains("delete ") 
            || code.contains("virtual") || code.contains("friend ") 
            || code.contains("operator") || code.contains("const ") && code.contains("&") {
            selectedLanguage = "cpp"
        } else if code.contains("def ") && code.contains(":") 
            || code.contains("import ") && code.contains("from ") 
            || code.contains("class ") && code.contains("self") 
            || code.contains("__init__") || code.contains("@property") 
            || code.contains("@staticmethod") || code.contains("@classmethod") 
            || code.contains("lambda ") || code.contains("yield ") 
            || code.contains("async def") || code.contains("await ") 
            || code.contains("with ") || code.contains("try:") 
            || code.contains("except ") || code.contains("finally:") 
            || code.contains("raise ") || code.contains("->") && code.contains("def ") {
            selectedLanguage = "python"
        } else if code.contains("using System") || code.contains("namespace") && code.contains("{") 
            || code.contains("public class") || code.contains("private class") 
            || code.contains("protected class") || code.contains("internal class") 
            || code.contains("async Task") || code.contains("await ") 
            || code.contains("var ") && code.contains(";") 
            || code.contains("string[]") || code.contains("List<") 
            || code.contains("IEnumerable<") || code.contains(".NET") 
            || code.contains("[Serializable]") || code.contains("[HttpGet]") 
            || code.contains("[Route") || code.contains("get;") && code.contains("set;") {
            selectedLanguage = "c#"
        } else if code.contains("package ") && code.contains("kotlin") 
            || code.contains("fun ") || code.contains("val ") 
            || code.contains("var ") && !code.contains(";") 
            || code.contains("companion object") || code.contains("data class") 
            || code.contains("sealed class") || code.contains("object ") 
            || code.contains("suspend ") || code.contains("coroutine") 
            || code.contains("@Composable") || code.contains("LiveData<") 
            || code.contains("ViewModel()") || code.contains("AndroidManifest.xml") {
            selectedLanguage = "kotlin"
        } else if code.contains("#!/bin/bash") || code.contains("#!/bin/sh") 
            || code.contains("echo ") || code.contains("if [[ ") 
            || code.contains("elif [[ ") || code.contains("for i in ") 
            || code.contains("while [[ ") || code.contains("case ") && code.contains(" in") 
            || code.contains("function ") && code.contains("()") 
            || code.contains("export ") || code.contains("source ") 
            || code.contains("|") && code.contains("grep") 
            || code.contains("$") && code.contains("{") {
            selectedLanguage = "bash"
        } else if code.contains("SELECT ") || code.contains("INSERT INTO ") 
            || code.contains("UPDATE ") || code.contains("DELETE FROM ") 
            || code.contains("CREATE TABLE") || code.contains("ALTER TABLE") 
            || code.contains("DROP TABLE") || code.contains("JOIN ") 
            || code.contains("WHERE ") || code.contains("GROUP BY") 
            || code.contains("HAVING ") || code.contains("ORDER BY") 
            || code.contains("UNION ") || code.contains("INNER JOIN") 
            || code.contains("LEFT JOIN") || code.contains("RIGHT JOIN") {
            selectedLanguage = "sql"
        } else if code.contains("<?xml") || code.contains("</") && code.contains(">") 
            || code.contains("<![CDATA[") || code.contains("xmlns:") 
            || code.contains("encoding=") && code.contains("?>") 
            || code.contains("<root>") || code.contains("</root>") 
            || (code.contains("<") && code.contains("/>")) 
            || code.contains("<!DOCTYPE") || code.contains("<?xml-stylesheet") {
            selectedLanguage = "xml"
        } else if code.contains("{") && code.contains("}") 
            && (code.contains("\"") || code.contains(":")) 
            || code.contains("[") && code.contains("]") 
            && code.contains("\"") && code.contains(",") 
            || code.contains("null") || code.contains("true") || code.contains("false") 
            || (code.contains("{") && code.contains(":") && !code.contains(";")) {
            selectedLanguage = "json"
        } else if code.contains("---") || code.contains("apiVersion:") 
            || code.contains("kind:") || code.contains("metadata:") 
            || code.contains("spec:") || code.contains("status:") 
            || (code.contains(":") && code.contains("-")) 
            || code.contains("|-") || code.contains(">-") 
            || code.contains("!include") || code.contains("&anchor") 
            || code.contains("*ref") || code.contains("<<:") {
            selectedLanguage = "yaml"
        } else if code.contains("fn ") || code.contains("pub ") 
            || code.contains("impl ") || code.contains("struct ") 
            || code.contains("enum ") || code.contains("trait ") 
            || code.contains("let mut") || code.contains("match ") 
            || code.contains("->") && code.contains("Result<") 
            || code.contains("unsafe") || code.contains("async ") 
            || code.contains("crate::") || code.contains("#[derive") 
            || code.contains("Vec<") || code.contains("Option<") {
            selectedLanguage = "rust"
        } else if code.contains("#import") || code.contains("@interface") 
            || code.contains("@implementation") || code.contains("@property") 
            || code.contains("@synthesize") || code.contains("@protocol") 
            || code.contains("-(void)") || code.contains("+(void)") 
            || code.contains("NSString *") || code.contains("UIViewController") 
            || code.contains("alloc] init") || code.contains("@selector") 
            || code.contains("@end") || code.contains("[super ") {
            selectedLanguage = "objective-c"
        } else if code.contains("object ") || code.contains("trait ") 
            || code.contains("case class") || code.contains("def ") && !code.contains(":") 
            || code.contains("val ") && code.contains("=") 
            || code.contains("var ") && code.contains("=") 
            || code.contains("extends ") || code.contains("with ") 
            || code.contains("implicit ") || code.contains("lazy val") 
            || code.contains("override def") || code.contains("package object") 
            || code.contains("import scala.") || code.contains("Future[") {
            selectedLanguage = "scala"
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
