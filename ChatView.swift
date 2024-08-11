import SwiftUI

struct ChatView: View {
    @State private var searchText = ""
    @State private var chats: [Chat] = [
        Chat(id: UUID(), name: "Alice", lastMessage: "How are you?", timestamp: "10:45 AM"),
        Chat(id: UUID(), name: "Bob", lastMessage: "See you soon.", timestamp: "Yesterday"),
        Chat(id: UUID(), name: "Charlie", lastMessage: "Got it, thanks!", timestamp: "Monday")
    ]
    @State private var showingNewChatView = false

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                
                List {
                    ForEach(chats.filter { searchText.isEmpty ? true : $0.name.contains(searchText) }) { chat in
                        NavigationLink(destination: ChatDetailView(chat: chat)) {
                            ChatRow(chat: chat)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewChatView = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 24))
                            .imageScale(.small)
                    }
                }
            }
            .sheet(isPresented: $showingNewChatView) {
                NewChatView(chats: $chats)
            }
        }
    }
}

struct Chat: Identifiable {
    var id: UUID
    var name: String
    var lastMessage: String
    var timestamp: String
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
        }
        .padding(.top)
    }
}

struct ChatRow: View {
    var chat: Chat

    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(chat.name.prefix(1))
                        .foregroundColor(.white)
                        .font(.title2)
                )
            VStack(alignment: .leading) {
                Text(chat.name)
                    .font(.headline)
                Text(chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(chat.timestamp)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

struct ChatDetailView: View {
    var chat: Chat
    @State private var messageText = ""
    @State private var messages: [String] = []

    var body: some View {
        VStack {
            List {
                ForEach(messages, id: \.self) { message in
                    HStack {
                        Text(message)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        Spacer()
                    }
                }
            }
            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                
                Button(action: {
                    sendMessage()
                }) {
                    Text("Send")
                }
            }
            .padding()
        }
        .navigationTitle(chat.name)
    }

    func sendMessage() {
        if !messageText.isEmpty {
            messages.append(messageText)
            messageText = ""
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
