import SwiftUI

struct ProfileView: View {
    @State private var showingCustomization = false
    
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
                    Text("Adam Bizios")
                        .font(.headline)
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
                    Text("Username: adam.bizios@example.com")
                    Text("Password: ••••••••")
                }
            }
        }
        .sheet(isPresented: $showingCustomization) {
            AvatarCustomizationView()
        }
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
