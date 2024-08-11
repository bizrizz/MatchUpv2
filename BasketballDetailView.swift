import SwiftUI
import MapKit

struct SchoolDetailView: View {
    var school: School
    var usernames: [String]

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(school.name)
                .font(.title)
                .bold()

            Text("Active Players: \(school.activePlayers)")
                .font(.headline)

            Text("Usernames of Active Players:")
                .font(.subheadline)
                .bold()

            ForEach(usernames, id: \.self) { username in
                Text(username)
                    .padding(.leading, 10)
            }

            Button(action: {
                navigateToChat()
            }) {
                Text("View Chat")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
    }

    func navigateToChat() {
        presentationMode.wrappedValue.dismiss()
        NotificationCenter.default.post(name: .navigateToChat, object: nil)
    }
}

extension Notification.Name {
    static let navigateToChat = Notification.Name("navigateToChat")
}

struct SchoolDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleSchool = School(name: "Dr Norman Bethune Collegiate Institute", coordinate: CLLocationCoordinate2D(latitude: 43.8016, longitude: -79.3181), activePlayers: 5, usernames: ["player1", "player2", "player3"])
        SchoolDetailView(
            school: sampleSchool,
            usernames: ["player1", "player2", "player3"]
        )
    }
}
