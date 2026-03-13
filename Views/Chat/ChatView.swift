import SwiftUI

struct ChatView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool

    init(conversationId: String) {
        _viewModel = State(initialValue: ChatViewModel(conversationId: conversationId))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        if viewModel.isStreaming, let last = viewModel.messages.last,
                           last.role == .assistant, last.content.isEmpty {
                            TypingIndicator()
                                .padding(.leading, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onTapGesture {
                    isInputFocused = false
                }
                .onChange(of: viewModel.scrollToBottom) {
                    if viewModel.scrollToBottom, let lastId = viewModel.messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                        viewModel.scrollToBottom = false
                    }
                }
            }

            // Input bar
            HStack(spacing: 12) {
                TextField(String(localized: "输入消息..."), text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .focused($isInputFocused)
                    .onSubmit {
                        viewModel.send()
                    }

                Button {
                    viewModel.send()
                } label: {
                    Image(systemName: viewModel.isStreaming ? "stop.fill" : "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isStreaming
                            ? Color.gray
                            : Color.purple
                        )
                        .clipShape(Circle())
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isStreaming)
                .sensoryFeedback(.impact, trigger: viewModel.messages.count)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .navigationTitle(appViewModel.agentName ?? String(localized: "聊天"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsHubView()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 16))
                }
            }
        }
        .gradientBackground()
        .task {
            await viewModel.loadHistory()
        }
        .onDisappear {
            viewModel.cancel()
        }
    }
}

/// Hub page for Memory / Emotion / Settings
struct SettingsHubView: View {
    @Environment(AppViewModel.self) private var appViewModel

    var body: some View {
        List {
            NavigationLink {
                MemoryTimelineView()
            } label: {
                Label(String(localized: "记忆"), systemImage: "brain.head.profile")
            }

            NavigationLink {
                EmotionTimelineView()
            } label: {
                Label(String(localized: "情绪"), systemImage: "heart.text.square")
            }

            NavigationLink {
                SettingsView()
            } label: {
                Label(String(localized: "设置"), systemImage: "gearshape")
            }
        }
        .navigationTitle(appViewModel.agentName ?? String(localized: "更多"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
