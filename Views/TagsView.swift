//
//  TagsView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 24/02/2025.
//

import SwiftUI

struct TagsView: View {
    @State var vm: SnippetsViewModel // Ensure this is properly initialized
    @State private var selectedTag: String? // Track the selected tag
    @State private var showColorPicker: Bool = false // Control the color picker sheet
    @State private var choosenColor: String? = "#FFFFFF" // Default color as a hex string
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.filteredTags.isEmpty && !vm.searchText.isEmpty {
                    Text("No tags match your search")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.filteredTags, id: \.self) { tag in
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .fill(Color(hex: vm.getTagBackgroundColor(tag: tag) ?? "")?.opacity(0.5) ?? .clear)
                                        .frame(width: 6)
                                        .frame(maxHeight: .infinity)
                                    
                                    Text(tag)
                                        .padding(.leading, 12)
                                        .padding(.vertical, 12)
                                    
                                    Spacer()
                                }
                                .background(Color(UIColor.systemBackground))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTag = tag
                                    choosenColor = vm.getTagBackgroundColor(tag: tag) ?? "#FFFFFF"
                                    showColorPicker = true
                                }
                                
                                Divider()
                            }
                        }
                    }
                }
            }
            .searchable(text: $vm.searchText, prompt: "Search tags")
            .navigationBarTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showColorPicker) {
                let bindingColor = Binding<Color>(
                    get: {
                        if let hex = choosenColor, let color = Color(hex: hex) {
                            return color
                        }
                        return Color.clear
                    },
                    set: { newColor in
                        choosenColor = newColor.toHex() ?? "#FFFFFF"
                    }
                )
                
                VStack {
                    ColorPicker("Choose tag color", selection: bindingColor)
                        .padding()
                    
                    Button("Save") {
                        if let tag = selectedTag, let colorHex = choosenColor {
                            vm.updateTagColor(tag: tag, color: colorHex)
                        }
                        showColorPicker = false
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                }
                .presentationDetents([.height(200)])
            }
        }
    }
}

#Preview {
    TagsView(vm: .init())
} 