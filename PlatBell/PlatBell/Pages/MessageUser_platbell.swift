import SwiftUI

// MARK: - 聊天页面
// 核心作用：与用户、群组或AI进行聊天
// 设计思路：现代化聊天界面 + 举报功能 + 视频聊天 + 实时消息
// 关键功能：消息发送、消息展示、举报用户、视频通话

/// 聊天页面
struct MessageUser_platbell: View {
    
    /// 用户数据（用于用户聊天）
    var user_platbell: PrewUserModel_platbell?
    
    /// 群组ID（用于群聊）
    var groupId_platbell: Int?
    
    /// 是否是AI聊天
    var isAIChat_platbell: Bool = false
    
    @ObservedObject var messageVM_platbell = MessageViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    
    /// 消息输入框文本
    @State private var messageText_platbell: String = ""
    
    /// 是否显示举报菜单
    @State private var showReportSheet_platbell = false
    
    /// 聊天类型
    private var chatType_platbell: ChatType_platbell {
        if isAIChat_platbell {
            return .ai_platbell
        } else if groupId_platbell != nil {
            return .group_platbell
        } else {
            return .personal_platbell
        }
    }
    
    /// 聊天ID
    private var chatId_platbell: Int {
        if let userId = user_platbell?.userId_platbell {
            return userId
        } else if let groupId = groupId_platbell {
            return groupId
        } else {
            return 0
        }
    }
    
    /// 聊天标题
    private var chatTitle_platbell: String {
        if isAIChat_platbell {
            return "AI Assistant"
        } else if let user = user_platbell {
            return user.userName_platbell ?? "Chat"
        } else if let groupId = groupId_platbell {
            return "Group Chat \(groupId)"
        } else {
            return "Chat"
        }
    }
    
    /// 获取消息列表
    private var messages_platbell: [MessageModel_platbell] {
        if isAIChat_platbell {
            return messageVM_platbell.getAiChats_platbell()
        } else if let groupId = groupId_platbell {
            return messageVM_platbell.getGroupMessages_platbell(groupId_platbell: groupId)
        } else if let userId = user_platbell?.userId_platbell {
            return messageVM_platbell.getMessagesWithUser_platbell(userId_platbell: userId)
        } else {
            return []
        }
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundView_platbell
            
            VStack(spacing: 0) {
                // 消息列表
                ScrollViewReader { proxy_platbell in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages_platbell.indices, id: \.self) { index_platbell in
                                let message_platbell = messages_platbell[index_platbell]
                                
                                MessageBubble_platbell(message_platbell: message_platbell)
                                    .id(message_platbell.messageId_platbell)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                    .onChange(of: messages_platbell.count) { _ in
                        // 自动滚动到最新消息
                        if let lastMessage_platbell = messages_platbell.last {
                            withAnimation {
                                proxy_platbell.scrollTo(lastMessage_platbell.messageId_platbell, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // 输入框区域
                inputAreaView_platbell
            }
        }
        .customNavigationBar_platbell(
            title_platbell: chatTitle_platbell,
            onBack_platbell: {
                router_platbell.pop_platbell()
            }
        ) {
            HStack(spacing: 12) {
                // 视频聊天按钮
                if let user = user_platbell {
                    NavIconButton_platbell(
                        iconName_platbell: "video.fill",
                        onTapped_platbell: {
                            router_platbell.toVideoChat_platbell(user_platbell: user)
                        }
                    )
                }
                
                // 举报按钮
                NavIconButton_platbell(
                    iconName_platbell: "exclamationmark.triangle",
                    onTapped_platbell: {
                        showReportSheet_platbell = true
                    }
                )
            }
        }
        .background(
            ReportActionSheet_platbell(
                isShowing_platbell: $showReportSheet_platbell,
                isBlockUser_platbell: true,
                onConfirm_platbell: handleReportConfirm_platbell
            )
        )
    }
    
    // MARK: - 子视图
    
    /// 渐变背景
    private var backgroundView_platbell: some View {
        LinearGradient(
            colors: [
                ThemeColors_platbell.accentBlueStart_platbell.opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    /// 输入框区域
    private var inputAreaView_platbell: some View {
        HStack(spacing: 12) {
            // 文本输入框
            HStack(spacing: 8) {
                TextField("Type a message...", text: $messageText_platbell)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                // 视频聊天按钮（输入框旁边）
                if let user = user_platbell {
                    Button(action: {
                        router_platbell.toVideoChat_platbell(user_platbell: user)
                    }) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 2))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(ThemeColors_platbell.gradient_platbell(at: 2).opacity(0.2))
                            )
                    }
                }
            }
            
            // 发送按钮
            Button(action: sendMessage_platbell) {
                Image(systemName: messageText_platbell.isEmpty ? "paperplane" : "paperplane.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                messageText_platbell.isEmpty
                                    ? LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing)
                                    : ThemeColors_platbell.gradient_platbell(at: 3)
                            )
                    )
                    .shadow(
                        color: messageText_platbell.isEmpty ? Color.clear : ThemeColors_platbell.accentBlueStart_platbell.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            }
            .disabled(messageText_platbell.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
        )
    }
    
    // MARK: - 事件处理
    
    /// 发送消息
    private func sendMessage_platbell() {
        let trimmedMessage_platbell = messageText_platbell.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedMessage_platbell.isEmpty else { return }
        
        messageVM_platbell.sendMessage_platbell(
            message_platbell: trimmedMessage_platbell,
            chatType_platbell: chatType_platbell,
            id_platbell: chatId_platbell
        )
        
        // 清空输入框
        messageText_platbell = ""
        
        // 触觉反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
    }
    
    /// 处理举报确认
    /// 功能：拉黑用户并显示成功提示，然后返回上一页
    private func handleReportConfirm_platbell() {
        guard let user = user_platbell else { return }
        
        ReportHelper_platbell.blockUser_platbell(user_platbell: user) {
            Utils_platbell.showSuccess_platbell(
                message_platbell: "User reported and blocked successfully",
                delay_platbell: 2.0
            )
            
            // 返回上一页
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router_platbell.pop_platbell()
            }
        }
    }
}

// MARK: - 消息气泡组件

/// 消息气泡组件
struct MessageBubble_platbell: View {
    let message_platbell: MessageModel_platbell
    
    var body: some View {
        HStack {
            if message_platbell.isMine_platbell == true {
                Spacer()
            }
            
            VStack(alignment: message_platbell.isMine_platbell == true ? .trailing : .leading, spacing: 4) {
                // 消息内容
                Text(message_platbell.content_platbell ?? "")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(message_platbell.isMine_platbell == true ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message_platbell.isMine_platbell == true
                            ? AnyShapeStyle(ThemeColors_platbell.gradient_platbell(at: 3))
                            : AnyShapeStyle(Color(.systemGray5))
                    )
                    .cornerRadius(18)
                
                // 时间戳
                if let time_platbell = message_platbell.time_platbell {
                    Text(time_platbell)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
            }
            
            if message_platbell.isMine_platbell != true {
                Spacer()
            }
        }
    }
}
