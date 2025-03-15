import SwiftUI
import FirebaseCore

enum NavigateFromView {
    case mySnippetsView
    case favoritesView
}

struct MySnippetsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var vm: SnippetsViewModel
    @State private var showingAddSnippet = false
    
    let backgroundColors: [Color ] = [.blue, .green, .yellow, .orange, .pink,.indigo,.purple,.mint,.teal,.red,.orange,.black,.brown,.gray]
    
    var backgroundColor: Color {
        backgroundColors.randomElement() ?? .indigo
    }
    
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
                    if vm.isLoading && vm.snippets.isEmpty {
                        ProgressView("Loading snippets...")
                            .foregroundColor(textColor)
                    } else if !vm.errorMessage.isEmpty {
                        Text(vm.errorMessage)
                            .foregroundColor(.red)
                    } else if vm.snippets.isEmpty {
                        VStack {
                            Image(.noSnippets)
                            Text("No snippets found")
                                .font(.title2)
                                .foregroundStyle(textColor.opacity(0.5))
                            Text("Start creating your first code snippet by tapping the plus button above")
                                .font(.headline)
                                .foregroundStyle(textColor.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                       
                    } else if vm.filteredSnippets.isEmpty && !vm.searchText.isEmpty {
                        Text("No snippets match your search criteria")
                            .foregroundColor(.gray)
                    } else {
                        List {
                            // Use ForEach so that we can attach the onDelete modifier.
                            ForEach(vm.filteredSnippets, id: \.name) { snippet in
                                NavigationLink {
                                    MySnippetDetailsView(vm: vm, navigateFrom: .mySnippetsView, snippet: snippet)
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
                                                    .foregroundColor(textColor)
                                                Text(snippet.description)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .multilineTextAlignment(.leading)
                                                
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
                                                    .scrollDisabled(shouldDisableScroll(for: snippet.tags))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: delete)
                        }
                        .scrollContentBackground(.hidden) // Make list background transparent
                    }
                }
             
                .searchable(text: $vm.searchText, prompt: "Search by name or tag")
            

            }
        }
        .onAppear {
            vm.fetchSnippets()
        }
    }
    
    func formatDate(date: Timestamp) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // Customize format as needed
        return formatter.string(from: date.dateValue())
    }
    
    // The delete function receives an IndexSet from the List and calls the view model.
    func delete(at offsets: IndexSet) {
        vm.onDeleteSnippet(index: offsets)
    }
    
    private func shouldDisableScroll(for tags: [String]) -> Bool {
        // Disable scroll if there are few tags (you can adjust this number)
        return tags.count <= 3
    }
}

#Preview {
    var vm: SnippetsViewModel = .init()
    MySnippetsView(vm: vm)
}
