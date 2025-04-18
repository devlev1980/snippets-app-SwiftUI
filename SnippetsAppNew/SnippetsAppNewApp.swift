//
//  SnippetsAppNewApp.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI
import FirebaseCore
import Firebase


//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//        return true
//    }
//    
//    // Handle the URL that your app receives at the end of the authentication process.
//    func application(_ app: UIApplication, open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance.handle(url)
//    }
//}

@main
struct SnippetsAppNewApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isLoading = true
    // Add a StateObject for ThemeManager to keep it alive for the entire app lifecycle
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                LoadingView()
                    .onAppear {
                        // Simulate app initialization time
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
                    // Apply theme to loading screen as well
                    .environmentObject(themeManager)
            } else {
                MainView()
                    .transition(.opacity)
                    // Inject the ThemeManager to make it available to all views
                    .environmentObject(themeManager)
                    .onAppear {
                        // Ensure theme is applied when transitioning to MainView
                        themeManager.applyTheme()
                    }
            }
        }
    }
}
