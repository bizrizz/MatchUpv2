import SwiftUI

struct CreateAccountView: View {
    @State private var userName = ""
    @State private var userNickName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @Binding var isAuthenticated: Bool

    var body: some View {
        VStack {
            Text("Create Account")
                .font(.largeTitle)
                .padding()
            
            TextField("Username", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Nickname", text: $userNickName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                Button(action: createAccount) {
                    Text("Create Account")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func createAccount() {
        guard !userName.isEmpty, !userNickName.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "All fields are required."
            showAlert = true
            return
        }

        isLoading = true

        let networkManager = NetworkManager()
        networkManager.createAccount(userName: userName, userNickName: userNickName, email: email, password: password) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    isAuthenticated = true
                } else {
                    alertMessage = error?.localizedDescription ?? "Account creation failed for an unknown reason."
                    showAlert = true
                }
            }
        }
    }
}
