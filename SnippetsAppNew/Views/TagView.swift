//
//  TagView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 23/02/2025.
//

import SwiftUI

struct TagView: View {
    let tag: String
    var body: some View {
        Text(tag)
            .font(.caption)
            .padding(.horizontal, 8)
            .foregroundStyle(.indigo)
            .padding(.vertical, 4)
            .background(backgroundColor(for: tag))
            .clipShape(.rect(cornerRadius: 10))
    }
    func backgroundColor(for tag: String) -> Color {
            let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .yellow]
            let index = abs(tag.hashValue) % colors.count
        return colors[index].opacity(0.3)
        }
}

#Preview {
    TagView(tag: "Swift")
}
