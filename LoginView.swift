import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isCreatingAccount = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @Binding var isAuthenticated: Bool

    var body: some View {
        VStack {
            Text(isCreatingAccount ? "Create Account" : "Login")
                .font(.largeTitle).bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .font(.body)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .font(.body)

            if isLoading {
                ProgressView()
                    .padding()
            } else {
                Button(action: fetchUserData) {
                    Text(isCreatingAccount ? "Create Account" : "Login")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .font(.headline)
                }
            }

            Button("Switch to \(isCreatingAccount ? "Login" : "Create Account")") {
                isCreatingAccount.toggle()
            }
            .font(.subheadline)
            .padding()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func fetchUserData() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Email and Password cannot be empty."
            showAlert = true
            return
        }
        
        isLoading = true
        
        let networkManager = NetworkManager()
        networkManager.fetchUserData(email: email, password: password) { loginResponse in
            DispatchQueue.main.async {
                isLoading = false
                if let loginResponse = loginResponse {
                    // Compare fetched userPassword with input password
                    if loginResponse.userPassword == password {
                        // Authentication successful
                        isAuthenticated = true
                    } else {
                        // Authentication failed due to incorrect password
                        alertMessage = "Authentication failed. Incorrect password."
                        showAlert = true
                    }
                } else {
                    alertMessage = "Failed to fetch user data. Please try again."
                    showAlert = true
                }
            }
        }
    }
}
