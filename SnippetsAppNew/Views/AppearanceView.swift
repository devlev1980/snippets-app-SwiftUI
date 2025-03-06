//
//  AppereanceView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 02/03/2025.
//

import SwiftUI

// Global theme manager that can be accessed throughout the app
class ThemeManager: ObservableObject {
    @Published var currentTheme: ColorSchemeType = .system {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appColorScheme")
            applyTheme()
        }
    }
    
    init() {
        // Load saved theme on init
        if let savedTheme = UserDefaults.standard.string(forKey: "appColorScheme"),
           let theme = ColorSchemeType(rawValue: savedTheme) {
            self.currentTheme = theme
        }
        
        // Apply the theme immediately
        applyTheme()
    }
    
    func applyTheme() {
        // Get the UIApplication instance
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        // Apply to all windows to ensure tab bar and all UI elements get updated
        for window in windowScene.windows {
            // Set the user interface style based on the selected option
            switch currentTheme {
            case .light:
                window.overrideUserInterfaceStyle = .light
            case .dark:
                window.overrideUserInterfaceStyle = .dark
            case .system:
                window.overrideUserInterfaceStyle = .unspecified
            }
            
            // Add animation to the appearance change
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {})
        }
    }
}

enum ColorSchemeType: String {
    case light = "light"
    case dark = "dark"
    case system = "system"
}

struct AppearanceView: View {
    // Use the ThemeManager from the environment instead of creating a new instance
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var currentColorScheme
    
    var body: some View {
        ZStack {
            // Indigo background with opacity 0.2 for the entire screen
            Color.indigo
                .opacity(0.2)
                .ignoresSafeArea()
            
            List {
                Section(header: Text("Theme")) {
                    ThemeOptionRow(
                        title: "Light",
                        systemImage: "sun.max.fill",
                        isSelected: themeManager.currentTheme == .light,
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.currentTheme = .light
                            }
                        }
                    )
                    
                    ThemeOptionRow(
                        title: "Dark",
                        systemImage: "moon.fill",
                        isSelected: themeManager.currentTheme == .dark,
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.currentTheme = .dark
                            }
                        }
                    )
                    
                    ThemeOptionRow(
                        title: "System",
                        systemImage: "gear",
                        isSelected: themeManager.currentTheme == .system,
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.currentTheme = .system
                            }
                        }
                    )
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Force refresh the theme when view appears to ensure everything is properly styled
            themeManager.applyTheme()
        }
    }
}

struct ThemeOptionRow: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(isSelected ? .indigo : .primary)
                    .font(.headline)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.indigo)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        AppearanceView()
            .environmentObject(ThemeManager())
    }
}
