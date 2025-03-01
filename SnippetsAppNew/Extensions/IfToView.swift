//
//  IfToView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 01/03/2025.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
