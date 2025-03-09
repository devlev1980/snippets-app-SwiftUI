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
        // Simple language detection based on code content
        let code = currentSnippet.code.lowercased()
        
        if code.contains("import swift") || code.contains("class") && code.contains("func") && !code.contains("function") 
            || code.contains("@state") || code.contains("@binding") || code.contains("@published") 
            || code.contains("@observedobject") || code.contains("@stateobject") || code.contains("@environment") 
            || code.contains("struct") && code.contains(": view") || code.contains("swiftui") 
            || code.contains("@main") || code.contains("@objc") || code.contains("uikit") {
            detectedLanguage = "swift"
        } else if code.contains("@angular") || code.contains("@component") || code.contains("@injectable") 
            || code.contains("@input") || code.contains("@output") || code.contains("ngonit") 
            || code.contains("ngondestroy") || code.contains("@hostlistener") || code.contains("@pipe") 
            || code.contains("@directive") || code.contains("changedetection") || code.contains("ngmodule") {
            detectedLanguage = "typescript" // Angular TypeScript
        } else if code.contains("react") && (code.contains("import") || code.contains("require")) 
            || code.contains("usestate") || code.contains("useeffect") || code.contains("useref") 
            || code.contains("usememo") || code.contains("usecallback") || code.contains("usecontext") 
            || code.contains("createcontext") || code.contains("reactdom") || code.contains("<jsx") 
            || code.contains("react.component") || code.contains("react.fc") || code.contains("react.fragment") 
            || (code.contains("props") && code.contains("interface")) {
            detectedLanguage = "typescript" // React TypeScript/JavaScript
        } else if code.contains("vue") && (code.contains("definecomponent") || code.contains("createapp")) 
            || code.contains("@vue/composition-api") || code.contains("vue.use") || code.contains("vue.extend") 
            || code.contains("@options") || code.contains("@prop") || code.contains("@watch") 
            || code.contains("@emit") || code.contains("setup()") || code.contains("computed") 
            || code.contains("<template>") || code.contains("v-model") || code.contains("v-if") 
            || code.contains("v-for") || code.contains("vuex") {
            detectedLanguage = "typescript" // Vue TypeScript/JavaScript
        } else if code.contains("qwik") || code.contains("component$") || code.contains("usestore$") {
            detectedLanguage = "typescript" // Qwik TypeScript
        } else if code.contains("svelte") && code.contains("<script") 
            || code.contains("$store") || code.contains("$derived") || code.contains("svelte/store") 
            || code.contains("on:click") || code.contains("bind:") || code.contains("each") 
            || code.contains("#await") || code.contains("#if") || code.contains("@html") 
            || code.contains("sveltekit") || code.contains("svelte:") || code.contains("svelte/motion") {
            detectedLanguage = "typescript" // Svelte TypeScript/JavaScript
        } else if code.contains("next") && code.contains("getstaticprops") {
            detectedLanguage = "typescript" // Next.js TypeScript
        } else if code.contains("nuxt") && code.contains("definenuxtconfig") {
            detectedLanguage = "typescript" // Nuxt TypeScript
        } else if code.contains("interface ") || code.contains("export ") || code.contains("type ") {
            detectedLanguage = "typescript"
        } else if code.contains("function ") || code.contains("const ") || code.contains("let ") {
            detectedLanguage = "javascript"
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
            detectedLanguage = "html"
        } else if code.contains("@import") || code.contains("{") && code.contains("}") && code.contains(";") 
            || code.contains("@media") || code.contains("@keyframes") || code.contains("@font-face") 
            || code.contains("@supports") || code.contains("!important") || code.contains("rgba(") 
            || code.contains("display:") || code.contains("position:") || code.contains("flex") 
            || code.contains("grid") || code.contains("animation:") || code.contains("transition:") 
            || code.contains("box-shadow:") || code.contains("border-radius:") || code.contains("background:") 
            || (code.contains(".") && code.contains("{") && code.contains(":")) 
            || (code.contains("#") && code.contains("{") && code.contains(":")) {
            detectedLanguage = "css"
        } else if code.contains("<?php") 
            || code.contains("namespace") && code.contains(";") 
            || code.contains("public function") || code.contains("private function") 
            || code.contains("protected function") || code.contains("$this->") 
            || code.contains("extends") && code.contains("class") 
            || code.contains("implements") || code.contains("use ") 
            || code.contains("array()") || code.contains("=>") 
            || code.contains("echo") || code.contains("<?=") {
            detectedLanguage = "php"
        } else if code.contains("package ") && code.contains("import (") 
            || code.contains("func ") || code.contains("type struct") 
            || code.contains("interface{") || code.contains("go ") 
            || code.contains("chan ") || code.contains("defer ") 
            || code.contains("goroutine") || code.contains("select {") 
            || code.contains(":= ") || code.contains("make(") 
            || code.contains("map[") || code.contains("[]") && !code.contains("[]()") {
            detectedLanguage = "go"
        } else if code.contains("#include") 
            || code.contains("std::") || code.contains("cout") 
            || code.contains("cin") || code.contains("vector<") 
            || code.contains("template<") || code.contains("namespace") 
            || code.contains("public:") || code.contains("private:") 
            || code.contains("protected:") || code.contains("->") && !code.contains("$this->") 
            || code.contains("new ") && code.contains("delete ") 
            || code.contains("virtual") || code.contains("friend ") 
            || code.contains("operator") || code.contains("const ") && code.contains("&") {
            detectedLanguage = "cpp"
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
            detectedLanguage = "python"
        } else if code.contains("using System") || code.contains("namespace") && code.contains("{") 
            || code.contains("public class") || code.contains("private class") 
            || code.contains("protected class") || code.contains("internal class") 
            || code.contains("async Task") || code.contains("await ") 
            || code.contains("var ") && code.contains(";") 
            || code.contains("string[]") || code.contains("List<") 
            || code.contains("IEnumerable<") || code.contains(".NET") 
            || code.contains("[Serializable]") || code.contains("[HttpGet]") 
            || code.contains("[Route") || code.contains("get;") && code.contains("set;") {
            detectedLanguage = "c#"
        } else if code.contains("package ") && code.contains("kotlin") 
            || code.contains("fun ") || code.contains("val ") 
            || code.contains("var ") && !code.contains(";") 
            || code.contains("companion object") || code.contains("data class") 
            || code.contains("sealed class") || code.contains("object ") 
            || code.contains("suspend ") || code.contains("coroutine") 
            || code.contains("@Composable") || code.contains("LiveData<") 
            || code.contains("ViewModel()") || code.contains("AndroidManifest.xml") {
            detectedLanguage = "kotlin"
        } else if code.contains("#!/bin/bash") || code.contains("#!/bin/sh") 
            || code.contains("echo ") || code.contains("if [[ ") 
            || code.contains("elif [[ ") || code.contains("for i in ") 
            || code.contains("while [[ ") || code.contains("case ") && code.contains(" in") 
            || code.contains("function ") && code.contains("()") 
            || code.contains("export ") || code.contains("source ") 
            || code.contains("|") && code.contains("grep") 
            || code.contains("$") && code.contains("{") {
            detectedLanguage = "bash"
        } else if code.contains("SELECT ") || code.contains("INSERT INTO ") 
            || code.contains("UPDATE ") || code.contains("DELETE FROM ") 
            || code.contains("CREATE TABLE") || code.contains("ALTER TABLE") 
            || code.contains("DROP TABLE") || code.contains("JOIN ") 
            || code.contains("WHERE ") || code.contains("GROUP BY") 
            || code.contains("HAVING ") || code.contains("ORDER BY") 
            || code.contains("UNION ") || code.contains("INNER JOIN") 
            || code.contains("LEFT JOIN") || code.contains("RIGHT JOIN") {
            detectedLanguage = "sql"
        } else if code.contains("<?xml") || code.contains("</") && code.contains(">") 
            || code.contains("<![CDATA[") || code.contains("xmlns:") 
            || code.contains("encoding=") && code.contains("?>") 
            || code.contains("<root>") || code.contains("</root>") 
            || (code.contains("<") && code.contains("/>")) 
            || code.contains("<!DOCTYPE") || code.contains("<?xml-stylesheet") {
            detectedLanguage = "xml"
        } else if code.contains("{") && code.contains("}") 
            && (code.contains("\"") || code.contains(":")) 
            || code.contains("[") && code.contains("]") 
            && code.contains("\"") && code.contains(",") 
            || code.contains("null") || code.contains("true") || code.contains("false") 
            || (code.contains("{") && code.contains(":") && !code.contains(";")) {
            detectedLanguage = "json"
        } else if code.contains("---") || code.contains("apiVersion:") 
            || code.contains("kind:") || code.contains("metadata:") 
            || code.contains("spec:") || code.contains("status:") 
            || (code.contains(":") && code.contains("-")) 
            || code.contains("|-") || code.contains(">-") 
            || code.contains("!include") || code.contains("&anchor") 
            || code.contains("*ref") || code.contains("<<:") {
            detectedLanguage = "yaml"
        } else if code.contains("fn ") || code.contains("pub ") 
            || code.contains("impl ") || code.contains("struct ") 
            || code.contains("enum ") || code.contains("trait ") 
            || code.contains("let mut") || code.contains("match ") 
            || code.contains("->") && code.contains("Result<") 
            || code.contains("unsafe") || code.contains("async ") 
            || code.contains("crate::") || code.contains("#[derive") 
            || code.contains("Vec<") || code.contains("Option<") {
            detectedLanguage = "rust"
        } else if code.contains("#import") || code.contains("@interface") 
            || code.contains("@implementation") || code.contains("@property") 
            || code.contains("@synthesize") || code.contains("@protocol") 
            || code.contains("-(void)") || code.contains("+(void)") 
            || code.contains("NSString *") || code.contains("UIViewController") 
            || code.contains("alloc] init") || code.contains("@selector") 
            || code.contains("@end") || code.contains("[super ") {
            detectedLanguage = "objective-c"
        } else if code.contains("object ") || code.contains("trait ") 
            || code.contains("case class") || code.contains("def ") && !code.contains(":") 
            || code.contains("val ") && code.contains("=") 
            || code.contains("var ") && code.contains("=") 
            || code.contains("extends ") || code.contains("with ") 
            || code.contains("implicit ") || code.contains("lazy val") 
            || code.contains("override def") || code.contains("package object") 
            || code.contains("import scala.") || code.contains("Future[") {
            detectedLanguage = "scala"
        } else {
            detectedLanguage = "typescript" // Default to typescript
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
                                
                                Image(systemName: "pencil")
                                    .onTapGesture {
                                        editableName = currentSnippet.name
                                        isEditing.toggle()
                                    }
                                
                                Spacer()
                                
                                if navigateFrom == .mySnippetsView {
                                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
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
                        Text(currentSnippet.description)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                            .padding(.bottom)
                            .padding(.top,5)
                        
                        // Tags section
                        Text("Tags")
                            .font(.headline)
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
                        
                       
                        
                        // Code section
                        Text("Code")
                            .font(.headline)
                        VStack(alignment: .trailing) {
                            HStack {
                                Spacer()
                                
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
        // Simple language detection based on code content
        let code = code.lowercased()
        
        if code.contains("import swift") || code.contains("class") && code.contains("func") && !code.contains("function") 
            || code.contains("@state") || code.contains("@binding") || code.contains("@published") 
            || code.contains("@observedobject") || code.contains("@stateobject") || code.contains("@environment") 
            || code.contains("struct") && code.contains(": view") || code.contains("swiftui") 
            || code.contains("@main") || code.contains("@objc") || code.contains("uikit") {
            detectedLanguage = "swift"
        } else if code.contains("@angular") || code.contains("@component") || code.contains("@injectable") 
            || code.contains("@input") || code.contains("@output") || code.contains("ngonit") 
            || code.contains("ngondestroy") || code.contains("@hostlistener") || code.contains("@pipe") 
            || code.contains("@directive") || code.contains("changedetection") || code.contains("ngmodule") {
            detectedLanguage = "typescript" // Angular TypeScript
        } else if code.contains("react") && (code.contains("import") || code.contains("require")) 
            || code.contains("usestate") || code.contains("useeffect") || code.contains("useref") 
            || code.contains("usememo") || code.contains("usecallback") || code.contains("usecontext") 
            || code.contains("createcontext") || code.contains("reactdom") || code.contains("<jsx") 
            || code.contains("react.component") || code.contains("react.fc") || code.contains("react.fragment") 
            || (code.contains("props") && code.contains("interface")) {
            detectedLanguage = "typescript" // React TypeScript/JavaScript
        } else if code.contains("vue") && (code.contains("definecomponent") || code.contains("createapp")) 
            || code.contains("@vue/composition-api") || code.contains("vue.use") || code.contains("vue.extend") 
            || code.contains("@options") || code.contains("@prop") || code.contains("@watch") 
            || code.contains("@emit") || code.contains("setup()") || code.contains("computed") 
            || code.contains("<template>") || code.contains("v-model") || code.contains("v-if") 
            || code.contains("v-for") || code.contains("vuex") {
            detectedLanguage = "typescript" // Vue TypeScript/JavaScript
        } else if code.contains("qwik") || code.contains("component$") || code.contains("usestore$") {
            detectedLanguage = "typescript" // Qwik TypeScript
        } else if code.contains("svelte") && code.contains("<script") 
            || code.contains("$store") || code.contains("$derived") || code.contains("svelte/store") 
            || code.contains("on:click") || code.contains("bind:") || code.contains("each") 
            || code.contains("#await") || code.contains("#if") || code.contains("@html") 
            || code.contains("sveltekit") || code.contains("svelte:") || code.contains("svelte/motion") {
            detectedLanguage = "typescript" // Svelte TypeScript/JavaScript
        } else if code.contains("next") && code.contains("getstaticprops") {
            detectedLanguage = "typescript" // Next.js TypeScript
        } else if code.contains("nuxt") && code.contains("definenuxtconfig") {
            detectedLanguage = "typescript" // Nuxt TypeScript
        } else if code.contains("interface ") || code.contains("export ") || code.contains("type ") {
            detectedLanguage = "typescript"
        } else if code.contains("function ") || code.contains("const ") || code.contains("let ") {
            detectedLanguage = "javascript"
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
            detectedLanguage = "html"
        } else if code.contains("@import") || code.contains("{") && code.contains("}") && code.contains(";") 
            || code.contains("@media") || code.contains("@keyframes") || code.contains("@font-face") 
            || code.contains("@supports") || code.contains("!important") || code.contains("rgba(") 
            || code.contains("display:") || code.contains("position:") || code.contains("flex") 
            || code.contains("grid") || code.contains("animation:") || code.contains("transition:") 
            || code.contains("box-shadow:") || code.contains("border-radius:") || code.contains("background:") 
            || (code.contains(".") && code.contains("{") && code.contains(":")) 
            || (code.contains("#") && code.contains("{") && code.contains(":")) {
            detectedLanguage = "css"
        } else if code.contains("<?php") 
            || code.contains("namespace") && code.contains(";") 
            || code.contains("public function") || code.contains("private function") 
            || code.contains("protected function") || code.contains("$this->") 
            || code.contains("extends") && code.contains("class") 
            || code.contains("implements") || code.contains("use ") 
            || code.contains("array()") || code.contains("=>") 
            || code.contains("echo") || code.contains("<?=") {
            detectedLanguage = "php"
        } else if code.contains("package ") && code.contains("import (") 
            || code.contains("func ") || code.contains("type struct") 
            || code.contains("interface{") || code.contains("go ") 
            || code.contains("chan ") || code.contains("defer ") 
            || code.contains("goroutine") || code.contains("select {") 
            || code.contains(":= ") || code.contains("make(") 
            || code.contains("map[") || code.contains("[]") && !code.contains("[]()") {
            detectedLanguage = "go"
        } else if code.contains("#include") 
            || code.contains("std::") || code.contains("cout") 
            || code.contains("cin") || code.contains("vector<") 
            || code.contains("template<") || code.contains("namespace") 
            || code.contains("public:") || code.contains("private:") 
            || code.contains("protected:") || code.contains("->") && !code.contains("$this->") 
            || code.contains("new ") && code.contains("delete ") 
            || code.contains("virtual") || code.contains("friend ") 
            || code.contains("operator") || code.contains("const ") && code.contains("&") {
            detectedLanguage = "cpp"
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
            detectedLanguage = "python"
        } else if code.contains("using System") || code.contains("namespace") && code.contains("{") 
            || code.contains("public class") || code.contains("private class") 
            || code.contains("protected class") || code.contains("internal class") 
            || code.contains("async Task") || code.contains("await ") 
            || code.contains("var ") && code.contains(";") 
            || code.contains("string[]") || code.contains("List<") 
            || code.contains("IEnumerable<") || code.contains(".NET") 
            || code.contains("[Serializable]") || code.contains("[HttpGet]") 
            || code.contains("[Route") || code.contains("get;") && code.contains("set;") {
            detectedLanguage = "c#"
        } else if code.contains("package ") && code.contains("kotlin") 
            || code.contains("fun ") || code.contains("val ") 
            || code.contains("var ") && !code.contains(";") 
            || code.contains("companion object") || code.contains("data class") 
            || code.contains("sealed class") || code.contains("object ") 
            || code.contains("suspend ") || code.contains("coroutine") 
            || code.contains("@Composable") || code.contains("LiveData<") 
            || code.contains("ViewModel()") || code.contains("AndroidManifest.xml") {
            detectedLanguage = "kotlin"
        } else if code.contains("#!/bin/bash") || code.contains("#!/bin/sh") 
            || code.contains("echo ") || code.contains("if [[ ") 
            || code.contains("elif [[ ") || code.contains("for i in ") 
            || code.contains("while [[ ") || code.contains("case ") && code.contains(" in") 
            || code.contains("function ") && code.contains("()") 
            || code.contains("export ") || code.contains("source ") 
            || code.contains("|") && code.contains("grep") 
            || code.contains("$") && code.contains("{") {
            detectedLanguage = "bash"
        } else if code.contains("SELECT ") || code.contains("INSERT INTO ") 
            || code.contains("UPDATE ") || code.contains("DELETE FROM ") 
            || code.contains("CREATE TABLE") || code.contains("ALTER TABLE") 
            || code.contains("DROP TABLE") || code.contains("JOIN ") 
            || code.contains("WHERE ") || code.contains("GROUP BY") 
            || code.contains("HAVING ") || code.contains("ORDER BY") 
            || code.contains("UNION ") || code.contains("INNER JOIN") 
            || code.contains("LEFT JOIN") || code.contains("RIGHT JOIN") {
            detectedLanguage = "sql"
        } else if code.contains("<?xml") || code.contains("</") && code.contains(">") 
            || code.contains("<![CDATA[") || code.contains("xmlns:") 
            || code.contains("encoding=") && code.contains("?>") 
            || code.contains("<root>") || code.contains("</root>") 
            || (code.contains("<") && code.contains("/>")) 
            || code.contains("<!DOCTYPE") || code.contains("<?xml-stylesheet") {
            detectedLanguage = "xml"
        } else if code.contains("{") && code.contains("}") 
            && (code.contains("\"") || code.contains(":")) 
            || code.contains("[") && code.contains("]") 
            && code.contains("\"") && code.contains(",") 
            || code.contains("null") || code.contains("true") || code.contains("false") 
            || (code.contains("{") && code.contains(":") && !code.contains(";")) {
            detectedLanguage = "json"
        } else if code.contains("---") || code.contains("apiVersion:") 
            || code.contains("kind:") || code.contains("metadata:") 
            || code.contains("spec:") || code.contains("status:") 
            || (code.contains(":") && code.contains("-")) 
            || code.contains("|-") || code.contains(">-") 
            || code.contains("!include") || code.contains("&anchor") 
            || code.contains("*ref") || code.contains("<<:") {
            detectedLanguage = "yaml"
        } else if code.contains("fn ") || code.contains("pub ") 
            || code.contains("impl ") || code.contains("struct ") 
            || code.contains("enum ") || code.contains("trait ") 
            || code.contains("let mut") || code.contains("match ") 
            || code.contains("->") && code.contains("Result<") 
            || code.contains("unsafe") || code.contains("async ") 
            || code.contains("crate::") || code.contains("#[derive") 
            || code.contains("Vec<") || code.contains("Option<") {
            detectedLanguage = "rust"
        } else if code.contains("#import") || code.contains("@interface") 
            || code.contains("@implementation") || code.contains("@property") 
            || code.contains("@synthesize") || code.contains("@protocol") 
            || code.contains("-(void)") || code.contains("+(void)") 
            || code.contains("NSString *") || code.contains("UIViewController") 
            || code.contains("alloc] init") || code.contains("@selector") 
            || code.contains("@end") || code.contains("[super ") {
            detectedLanguage = "objective-c"
        } else if code.contains("object ") || code.contains("trait ") 
            || code.contains("case class") || code.contains("def ") && !code.contains(":") 
            || code.contains("val ") && code.contains("=") 
            || code.contains("var ") && code.contains("=") 
            || code.contains("extends ") || code.contains("with ") 
            || code.contains("implicit ") || code.contains("lazy val") 
            || code.contains("override def") || code.contains("package object") 
            || code.contains("import scala.") || code.contains("Future[") {
            detectedLanguage = "scala"
        } else {
            detectedLanguage = "typescript" // Default to typescript
        }
        
        // Update the ViewModel's selected language
        vm.setSelectedLanguage(language: detectedLanguage)
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

