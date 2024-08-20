import SwiftUI
import CoreLocation

struct CustomTabView: View {
    @Binding var isAuthenticated: Bool  // Binding to control authentication state
    @State private var selectedTab = 0
    @State private var selectedCoordinate: IdentifiableCoordinate? = nil
    @State private var isTabBarVisible = true
    @State private var hideTimer: Timer? = nil
    @State private var lastInteractionTime = Date()
    private let hideDelay: TimeInterval = 3 // Time in seconds to hide the tab bar after inactivity

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(selectedCoordinate: $selectedCoordinate)
                    .tag(0)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                ContentView(selectedCoordinate: selectedCoordinate?.coordinate ?? CLLocationCoordinate2D(latitude: 43.7800, longitude: -79.3350))
                    .tag(1)
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Map")
                    }

                ChatView()
                    .tag(2)
                    .tabItem {
                        Image(systemName: "message.fill")
                        Text("Messages")
                    }

                ProfileView(isAuthenticated: $isAuthenticated) // Pass isAuthenticated binding
                    .tag(3)
                    .tabItem {
                        Image(systemName: "person.crop.circle.fill")
                        Text("Profile")
                    }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .background(Color.white.opacity(0.0)) // Makes the background transparent
            .accentColor(.blue) // Change this to customize the accent color of the tab items

            if isTabBarVisible {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            selectedTab = 0
                            showTabBar()
                        }) {
                            Image(systemName: "house.fill")
                                .foregroundColor(selectedTab == 0 ? .blue : .gray)
                                .padding()
                        }
                        Spacer()
                        Button(action: {
                            selectedTab = 1
                            showTabBar()
                        }) {
                            Image(systemName: "map.fill")
                                .foregroundColor(selectedTab == 1 ? .blue : .gray)
                                .padding()
                        }
                        Spacer()
                        Button(action: {
                            selectedTab = 2
                            showTabBar()
                        }) {
                            Image(systemName: "message.fill")
                                .foregroundColor(selectedTab == 2 ? .blue : .gray)
                                .padding()
                        }
                        Spacer()
                        Button(action: {
                            selectedTab = 3
                            showTabBar()
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(selectedTab == 3 ? .blue : .gray)
                                .padding()
                        }
                        Spacer()
                    }
                    .background(Color.white.opacity(0.7)) // Semi-transparent background
                    .clipShape(Capsule())
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity)) // Combined transition
                    .animation(.easeInOut(duration: 0.3), value: isTabBarVisible) // Smooth animation with duration
                }
            }
        }
        .gesture(
            TapGesture()
                .onEnded { _ in
                    showTabBar()
                }
        )
        .onAppear {
            startHideTimer()
        }
        .onChange(of: selectedTab) { _ in
            showTabBar()
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToChat)) { _ in
            selectedTab = 2
            showTabBar()
        }
    }

    private func showTabBar() {
        withAnimation {
            isTabBarVisible = true
        }
        lastInteractionTime = Date()
        startHideTimer() // Restart the timer when user interacts
    }

    private func hideTabBar() {
        withAnimation {
            isTabBarVisible = false
        }
    }

    private func startHideTimer() {
        // Cancel previous timer if any
        hideTimer?.invalidate()
        
        // Schedule a new timer
        hideTimer = Timer.scheduledTimer(withTimeInterval: hideDelay, repeats: false) { _ in
            if Date().timeIntervalSince(lastInteractionTime) >= hideDelay {
                hideTabBar()
            }
        }
    }
}

struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabView(isAuthenticated: .constant(true))  // Provide a binding for preview
    }
}
