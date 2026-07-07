import SwiftUI

struct AICoachChatView: View {
    @State private var viewModel = AIHubViewModel()
    @State private var plantContext: String = "General houseplant care"

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.chatMessages.indices, id: \.self) { i in
                            let msg = viewModel.chatMessages[i]
                            ChatBubble(message: msg.content, isUser: msg.role == "user")
                                .id(i)
                        }

                        if viewModel.isStreaming {
                            HStack {
                                ProgressView()
                                Text("Coach is typing...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewModel.chatMessages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.chatMessages.count - 1, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack(spacing: 8) {
                TextField("Ask about plant care...", text: $viewModel.chatInput)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task { await viewModel.sendChat(plantContext: plantContext) }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(AppTheme.quenchBlue)
                }
                .disabled(viewModel.chatInput.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isStreaming)
            }
            .padding()
        }
        .navigationTitle("AI Coach")
    }
}

struct ChatBubble: View {
    let message: String
    let isUser: Bool

    var body: some View {
        HStack {
            if isUser { Spacer() }
            Text(message)
                .padding(12)
                .background(isUser ? AppTheme.quenchBlue : Color(.secondarySystemBackground))
                .foregroundStyle(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            if !isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}
