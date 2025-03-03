//
//  FavoritesView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI
import FirebaseCore
struct FavoritesView: View {
    @State var vm: SnippetsViewModel
    
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.favoriteSnippets.isEmpty {
                    VStack {
                        Image(.noSnippets)
                        Text("No snippets found")
                            .font(.title2)
                            .foregroundStyle(.black.opacity(0.5))
                        Text("Please add some snippets to your favorites list")
                            .font(.headline)
                            .foregroundStyle(.black.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else if vm.filteredFavoriteSnippets.isEmpty && !vm.searchText.isEmpty {
                    Text("No favorites match your search criteria")
                        .foregroundColor(.gray)
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
                                            
                                            ScrollView{
                                                HStack(alignment: .center) {
                                                    ForEach(snippet.tags, id: \.self) { tag in
                                                        TagView(
                                                            tag: tag,
                                                            hexColor: (snippet.tagBgColors?[tag])!
                                                        )
                                                        .padding(.top, 10)
                                                        
                                                        
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                                
                            }
                        }
                    }
                }
            }
            .searchable(text: $vm.searchText, prompt: "Search by name or tag")
            .navigationBarTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
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
