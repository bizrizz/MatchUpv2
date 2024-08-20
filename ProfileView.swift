import SwiftUI

struct ProfileView: View {
    @State private var showingCustomization = false
    @State private var userName = ""
    @State private var userNickName = ""
    @Binding var isAuthenticated: Bool  // Binding to control authentication state
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(.trailing, 10)
                
                VStack(alignment: .leading) {
                    Text(userNickName)
                        .font(.headline)
                    Text(userName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button("Customize") {
                    showingCustomization = true
                }
                .foregroundColor(.blue)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
            .padding()

            Form {
                Section(header: Text("Account")) {
                    Text("Username: \(userName)")
                }
            }
            
            Button(action: logout) {
                Text("Logout")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            fetchUserProfile()
        }
        .sheet(isPresented: $showingCustomization) {
            AvatarCustomizationView()
        }
        .navigationTitle("Profile")
    }
    
    private func fetchUserProfile() {
        let networkManager = NetworkManager()
        networkManager.getUserProfile { userName, userNickName in
            DispatchQueue.main.async {
                self.userName = userName ?? "Unknown"
                self.userNickName = userNickName ?? "Unknown"
            }
        }
    }
    
    private func logout() {
        // Clear the user token and email from UserDefaults
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.removeObject(forKey: "loggedInUserEmail")
        
        // Set isAuthenticated to false to navigate back to LoginView
        isAuthenticated = false
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(isAuthenticated: .constant(true))  // Provide a binding for preview
    }
}
