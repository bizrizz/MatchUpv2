import SwiftUI
import CoreLocation

struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

enum FilterOption: String, CaseIterable, Identifiable {
    case closest = "Closest"
    case mostActivePlayers = "Most Active Players"
    
    var id: String { self.rawValue }
}

struct HomeView: View {
    @State private var userLocation = CLLocationCoordinate2D(latitude: 43.7800, longitude: -79.3350) // Example user location
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
    @Binding var selectedCoordinate: IdentifiableCoordinate?
    @State private var filterOption: FilterOption = .closest

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(filteredSchools) { school in
                        let distance = calculateDistance(to: school.coordinate)
                        SchoolBoxView(
                            title: school.name,
                            subtitle: "\(String(format: "%.1f", distance)) km away - \(school.activePlayers) active players",
                            coordinate: school.coordinate,
                            navigateToLocation: { location in
                                selectedCoordinate = IdentifiableCoordinate(coordinate: location)
                            }
                        )
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Filter", selection: $filterOption) {
                            ForEach(FilterOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }
            }
            .sheet(item: $selectedCoordinate) { identifiableCoordinate in
                ContentView(selectedCoordinate: identifiableCoordinate.coordinate)
            }
        }
    }
    
    var filteredSchools: [School] {
        switch filterOption {
        case .closest:
            return schools.sorted {
                calculateDistance(to: $0.coordinate) < calculateDistance(to: $1.coordinate)
            }
        case .mostActivePlayers:
            return schools.sorted {
                $0.activePlayers > $1.activePlayers
            }
        }
    }

    func calculateDistance(to coordinate: CLLocationCoordinate2D) -> Double {
        let schoolLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let currentUserLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        return round((currentUserLocation.distance(from: schoolLocation) / 1000) * 10) / 10 // Convert to kilometers and round to 1 decimal place
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedCoordinate: .constant(nil))
    }
}
