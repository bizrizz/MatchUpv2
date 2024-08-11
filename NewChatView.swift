import SwiftUI

struct NewChatView: View {
    @Binding var chats: [Chat]
    @Environment(\.dismiss) var dismiss
    @State private var chatName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("New Chat")) {
                    TextField("Enter name", text: $chatName)
                }
            }
            .navigationTitle("New Chat")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createChat()
                        dismiss()
                    }
                    .disabled(chatName.isEmpty)
                }
            }
        }
    }

    func createChat() {
        let newChat = Chat(id: UUID(), name: chatName, lastMessage: "", timestamp: "Now")
        chats.append(newChat)
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView(chats: .constant([]))
    }
}
