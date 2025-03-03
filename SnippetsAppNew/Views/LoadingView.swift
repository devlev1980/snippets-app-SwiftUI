//
//  LoadingView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 03/03/2025.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Color(.indigo.opacity(0.3))
                .ignoresSafeArea()
            
            VStack {
                Image(.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(opacity)
                
                Text("Snippets")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .opacity(opacity)
                
                Text("Your Code Collection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LoadingView()
} 
