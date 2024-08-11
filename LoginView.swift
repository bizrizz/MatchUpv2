import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isCreatingAccount = false
    @State private var isAuthenticated = false
    @State private var isCustomizingAvatar = false
    @Binding var snapshotImage: UIImage?

    var body: some View {
        VStack {
            Text(isCreatingAccount ? "Create Account" : "Login")
                .font(.largeTitle).bold()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .font(.body)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .font(.body)

            Button(action: {
                // Authentication logic goes here
                isAuthenticated = true
            }) {
                Text(isCreatingAccount ? "Create Account" : "Login")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .font(.headline)
            }

            Button("Switch to \(isCreatingAccount ? "Login" : "Create Account")") {
                isCreatingAccount.toggle()
            }
            .font(.subheadline)
            .padding()

            NavigationLink(destination: CustomTabView(), isActive: $isAuthenticated) {
                EmptyView()
            }
            
            NavigationLink(destination: AvatarCustomizationView(), isActive: $isCustomizingAvatar) {
                EmptyView()
            }

            Button("Customize Avatar") {
                isCustomizingAvatar = true
            }
            .font(.headline)
            .padding()
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(snapshotImage: .constant(nil))
    }
}
