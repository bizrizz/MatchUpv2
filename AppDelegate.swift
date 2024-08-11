import SwiftUI
import UserNotifications

@main
struct MatchUpv2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var showLoadingScreen = true

    var body: some Scene {
        WindowGroup {
            if showLoadingScreen {
                LoadingScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showLoadingScreen = false
                        }
                    }
            } else {
                CustomTabView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationManager = NotificationManager()
}
