//
//  TagView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 23/02/2025.
//

import SwiftUI

struct TagView: View {
    let tag: String
    let hexColor: String
    
    var body: some View {
        Text(tag)
            .font(.caption)
            .padding(.horizontal, 8)
            .foregroundStyle(.indigo)
            .padding(.vertical, 4)
            .background(hexColor.isEmpty ? .clear : Color(hex: hexColor)?.opacity(0.3))
            .clipShape(.rect(cornerRadius: 10))
    }
}

// Add Color extension for hex support
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        self.init(
            .sRGB,
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0,
            opacity: 1.0
        )
    }
}

#Preview {
    TagView(tag: "Swift", hexColor: "000000")
}
