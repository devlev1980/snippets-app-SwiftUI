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
            List {
                ForEach(vm.tags, id: \.self) { tag in
                    HStack {
                        Rectangle()
                            .fill(Color(hex: vm.getTagBackgroundColor(tag: tag) ?? "")?.opacity(0.5) ?? .clear)
                            .frame(width: 4)
                            .cornerRadius(2)
                        Text(tag)
                            
                    }
                    .onTapGesture {
                        selectedTag = tag
                        choosenColor = vm.getTagBackgroundColor(tag: tag) ?? "#FFFFFF"
                        showColorPicker = true
                    }
                }
            }
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
                    ColorPicker("Select Color", selection: bindingColor)
                        .padding()
                    
                    Button("Save") {
                        if let tag = selectedTag, let colorHex = choosenColor {
                            vm.updateTagColor(tag: tag, color: colorHex)
                        }
                        showColorPicker = false
                    }
                    .padding()
                }
                .presentationDetents([.height(200)])
            }
        }
    }
}

#Preview {
    TagsView(vm: .init())
}


