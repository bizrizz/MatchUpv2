import SwiftUI
import MapKit
import UserNotifications
import CoreLocation

struct School: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let activePlayers: Int
    let usernames: [String] // Add this property
}

struct UserProfile {
    var username: String
    var isOnline: Bool
    var memoji: String // Replace with actual Memoji representation
}

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.7800, longitude: -79.3350),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @State private var userLocation = CLLocationCoordinate2D(latitude: 43.7800, longitude: -79.3350)
    @State private var userProfile = UserProfile(username: "User1", isOnline: true, memoji: "🧑‍🦱")
    @State private var showingProfile = false
    @State private var selectedSchool: School? = nil
    @State private var showingSchoolDetail = false
    
    @State private var schools = [
        School(name: "Dr Norman Bethune Collegiate Institute", coordinate: CLLocationCoordinate2D(latitude: 43.8016, longitude: -79.3181), activePlayers: 5, usernames: ["player1", "player2", "player3"]),
        School(name: "Lester B. Pearson Collegiate Institute", coordinate: CLLocationCoordinate2D(latitude: 43.8035, longitude: -79.2256), activePlayers: 3, usernames: ["playerA", "playerB"]),
        School(name: "Maplewood High School", coordinate: CLLocationCoordinate2D(latitude: 43.7694, longitude: -79.1927), activePlayers: 2, usernames: ["playerX", "playerY"]),
        School(name: "George B Little Public School", coordinate: CLLocationCoordinate2D(latitude: 43.7654, longitude: -79.2154), activePlayers: 4, usernames: ["playerC", "playerD"]),
        School(name: "David and Mary Thomson Collegiate Institute", coordinate: CLLocationCoordinate2D(latitude: 43.7506, longitude: -79.2707), activePlayers: 1, usernames: ["playerE"]),
        School(name: "Newtonbrook Secondary School", coordinate: CLLocationCoordinate2D(latitude: 43.7981, longitude: -79.4198), activePlayers: 6, usernames: ["playerF", "playerG"]),
        School(name: "Georges Vanier Secondary School", coordinate: CLLocationCoordinate2D(latitude: 43.7772, longitude: -79.3464), activePlayers: 3, usernames: ["playerH", "playerI"]),
        School(name: "Northview Heights Secondary School", coordinate: CLLocationCoordinate2D(latitude: 43.7808, longitude: -79.4391), activePlayers: 2, usernames: ["playerJ", "playerK"]),
        School(name: "Earl Haig Secondary School", coordinate: CLLocationCoordinate2D(latitude: 43.7663, longitude: -79.4018), activePlayers: 7, usernames: ["playerL", "playerM"]),
        School(name: "Don Mills Collegiate Institute", coordinate: CLLocationCoordinate2D(latitude: 43.7380, longitude: -79.3343), activePlayers: 5, usernames: ["playerN", "playerO"])
    ]
    
    private var activePlayers: [UUID: Int] = [
            UUID(): 5,
            UUID(): 3
        ]
    
    private var usernames: [UUID: [String]] = [
            UUID(): ["player1", "player2", "player3"],
            UUID(): ["playerA", "playerB"]
        ]

    // Add this property to receive the selected coordinate
    var selectedCoordinate: CLLocationCoordinate2D?

    init(selectedCoordinate: CLLocationCoordinate2D? = nil) {
        self.selectedCoordinate = selectedCoordinate
        if let coordinate = selectedCoordinate {
            self._region = State(initialValue: MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: false,
                annotationItems: schools) { school in
                    MapAnnotation(coordinate: school.coordinate) {
                        Button(action: {
                            selectedSchool = school
                            showingSchoolDetail = true
                        }) {
                            Image(systemName: "basketball.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
            }
            .onAppear {
                if let coordinate = selectedCoordinate {
                    region.center = coordinate
                    region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                }
            }
            .overlay(
                Button(action: {
                    showingProfile.toggle()
                }) {
                    Circle()
                        .fill(userProfile.isOnline ? Color.green : Color.gray)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text("")
                                .font(.caption) // Apply font style
                                .offset(x: 0, y: -30)
                        )
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                .popover(isPresented: $showingProfile) {
                    VStack {
                        Text(userProfile.memoji)
                            .font(.largeTitle) // Large title for memoji
                        Text(userProfile.username)
                            .font(.title3) // Smaller title for username
                        Text(userProfile.isOnline ? "Online" : "Away")
                            .font(.footnote) // Footnote for status
                            .foregroundColor(userProfile.isOnline ? .green : .gray)
                    }
                    .padding()
                }
            )
        }
        .sheet(isPresented: $showingSchoolDetail) {
                    if let school = selectedSchool {
                        SchoolDetailView(
                            school: school,
                            usernames: school.usernames
                )
            }
        }
        .onAppear {
            requestNotificationPermission()
            startProximityCheck()
        }
        .navigationTitle("Map")
    }
    
    func startProximityCheck() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            checkProximity()
        }
    }
    
    func checkProximity() {
        for school in schools {
            let distance = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                .distance(from: CLLocation(latitude: school.coordinate.latitude, longitude: school.coordinate.longitude))
            if distance < 100.0 { // Assuming 100 meters as proximity
                sendProximityNotification(for: school.name)
                break
            }
        }
    }
    
    func sendProximityNotification(for schoolName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Let's Play!"
        content.body = "You are near \(schoolName). Let's play! 🏀"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
    }
}

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Foreground notification received")
        completionHandler([.alert, .sound]) // Adjust to .alert for standard use
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selectedCoordinate: CLLocationCoordinate2D(latitude: 43.8016, longitude: -79.3181))
    }
}
