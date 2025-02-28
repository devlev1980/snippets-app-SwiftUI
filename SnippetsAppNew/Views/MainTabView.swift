//
//  TabView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI

struct MainTabView: View {
    @State var vm : SnippetsViewModel = SnippetsViewModel()
    @State private var showingAddSnippet = false
    var body: some View {
        TabView {
            NavigationView {
                MySnippetsView(vm: vm)
                    .navigationTitle("My snippets")
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
                    .navigationTitle("Favorites")
                  
            }
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }
            
            
            NavigationView {
                TagsView(vm: vm)
                    .navigationTitle("Tags")
                  
            }
            .tabItem {
                Label("Tags", systemImage: "tag")
            }
            
            
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
                   
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(.indigo)
        
        .sheet(isPresented: $showingAddSnippet) {
            AddSnippetView(viewModel: vm)
        }
    }
}

#Preview {
    MainTabView()
}
