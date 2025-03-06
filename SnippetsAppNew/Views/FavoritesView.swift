//
//  FavoritesView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI
import FirebaseCore
struct FavoritesView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var vm: SnippetsViewModel
    
    
    var textColor: Color {
        colorScheme == .light ? .black : .white
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Indigo background with opacity 0.2 for the entire screen
                Color.indigo
                    .opacity(0.2)
                    .ignoresSafeArea()
                
                Group {
                    if vm.favoriteSnippets.isEmpty {
                        VStack {
                            Image(.noSnippets)
                            Text("No snippets found")
                                .font(.title2)
                                .foregroundStyle(textColor.opacity(0.5))
                            Text("Please add some snippets to your favorites list")
                                .font(.headline)
                                .foregroundStyle(textColor.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else if vm.filteredFavoriteSnippets.isEmpty && !vm.searchText.isEmpty {
                        Text("No favorites match your search criteria")
                            .foregroundColor(textColor.opacity(0.5))
                    } else {
                        List(vm.filteredFavoriteSnippets, id: \.name) { snippet in
                            NavigationLink {
                                MySnippetDetailsView(vm: vm, navigateFrom: NavigateFromView.favoritesView, snippet: snippet)
                            } label: {
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        Image("Logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                        
                                        
                                        VStack(alignment: .leading) {
                                            Text(snippet.name)
                                                .font(.headline)
                                            Text(snippet.description)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            HStack(alignment: .center) {
                                                Image("Time")
                                                Text(formatDate(date: snippet.timestamp))
                                                    .font(.caption)
                                                    .foregroundStyle(.gray.opacity(0.8))
                                                
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(alignment: .center) {
                                                        ForEach(snippet.tags, id: \.self) { tag in
                                                            TagView(
                                                                tag: tag,
                                                                hexColor: (snippet.tagBgColors?[tag])!
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }
                                        
                                        
                                        
                                        
                                    }
                                    
                                }
                            }
                        }
                        .scrollContentBackground(.hidden) // Make list background transparent
                    }
                }
                .searchable(text: $vm.searchText, prompt: "Search by name or tag")
                .navigationBarTitle("Favorites")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    func formatDate(date: Timestamp) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // Customize format as needed
        return formatter.string(from: date.dateValue()) // ✅ Convert Timestamp to Date first
    }
}

#Preview {
    FavoritesView(vm: .init())
}
