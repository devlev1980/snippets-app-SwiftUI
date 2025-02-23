//
//  TabView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MySnippetsView()
                .tabItem {
                    Image(systemName: "doc.text") // Customize with your desired icon.
                    Text("My snippets")
                }
            
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "star.fill") // Customize with your desired icon.
                    Text("Favorites")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill") // Customize with your desired icon.
                    Text("Settings")
                }
        }
    }
}

#Preview {
    MainTabView()
}
