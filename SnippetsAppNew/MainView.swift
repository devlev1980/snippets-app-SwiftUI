//
//  ContentView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        let vm: SnippetsViewModel = .init()
        
        
        VStack {
            SignInView(viewModel: vm)
        }
     
    
    }
}

#Preview {
    MainView()
}
