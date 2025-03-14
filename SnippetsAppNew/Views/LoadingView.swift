//
//  LoadingView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 03/03/2025.
//

import SwiftUI

struct LoadingView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var isAnimating = false
    @State private var opacity = 0.0
    
    var textColor: Color {
        colorScheme == .light ? .black : .white
    }
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
                
                Text("SnipHub")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.horizontal,5)
                    .opacity(opacity)
                    .foregroundStyle(textColor)
                
                Text("Your code collection in one place")
                    .font(.subheadline)
                    .foregroundColor(textColor.opacity(0.7))
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
