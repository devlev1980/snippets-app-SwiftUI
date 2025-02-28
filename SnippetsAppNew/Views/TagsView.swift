//
//  TagsView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 24/02/2025.
//

import SwiftUI

struct TagsView: View {
    let vm: SnippetsViewModel
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.tags, id: \.self) { tag in
                    Text(tag)
                }
            }
            .navigationBarTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TagsView(vm: .init())
}
