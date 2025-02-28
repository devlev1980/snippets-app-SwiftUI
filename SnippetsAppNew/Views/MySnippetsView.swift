import SwiftUI
import FirebaseCore

enum NavigateFromView {
    case mySnippetsView
    case favoritesView
}

struct MySnippetsView: View {
    @State var vm: SnippetsViewModel
    @State private var showingAddSnippet = false
    
    let backgroundColors: [Color ] = [.blue, .green, .yellow, .orange, .pink,.indigo,.purple,.mint,.teal,.red,.orange,.black,.brown,.gray]
    
    var backgroundColor: Color {
        backgroundColors.randomElement() ?? .indigo
    }

    var body: some View {
        NavigationStack {
            if vm.isLoading {
                ProgressView("Loading snippets...")
            } else if !vm.errorMessage.isEmpty {
                Text(vm.errorMessage)
                    .foregroundColor(.red)
            } else if vm.snippets.isEmpty {
                Text("No snippets found 😢")
            } else {
                List {
                    // Use ForEach so that we can attach the onDelete modifier.
                    ForEach(vm.snippets, id: \.name) { snippet in
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
                                                        TagView(tag: tag)
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
                    .onDelete(perform: delete)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.fetchSnippets() // Fetch when view appears
        }
    }
    
    func formatDate(date: Timestamp) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // Customize format as needed
        return formatter.string(from: date.dateValue())
    }
    
    // The delete function receives an IndexSet from the List and calls the view model.
    func delete(at offsets: IndexSet) {
        print(offsets)
        vm.onDeleteSnippet(index: offsets)
    }
}

#Preview {
    var vm: SnippetsViewModel = .init()
    MySnippetsView(vm: vm)
}
