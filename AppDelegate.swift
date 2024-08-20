import SwiftUI
import UIKit

// Define the AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Perform any final initialization of your application.
        return true
    }
}

// Define the SwiftUI App
@main
struct MatchUpv2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var showLoadingScreen = true
    @State private var isAuthenticated = false

    var body: some Scene {
        WindowGroup {
            if showLoadingScreen {
                LoadingScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showLoadingScreen = false
                        }
                    }
            } else if !isAuthenticated {
                LoginView(isAuthenticated: $isAuthenticated)
            } else {
                CustomTabView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}

// Ensure your other views (LoadingScreenView, LoginView, CustomTabView) are correctly defined.
