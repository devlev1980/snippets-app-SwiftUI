//
//  TabView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI

struct MainTabView: View {
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Access the ThemeManager from the environment
    @EnvironmentObject private var themeManager: ThemeManager
    let vm: SnippetsViewModel
    @State private var showingAddSnippet = false
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
}

#Preview {
    MainTabView(vm: SnippetsViewModel())
        .environmentObject(ThemeManager())
}
