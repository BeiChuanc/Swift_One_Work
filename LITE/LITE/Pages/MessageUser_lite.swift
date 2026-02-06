import SwiftUI
import Combine

// MARK: - 聊天页面
// 核心作用：与用户或群组进行聊天
// 设计思路：现代化聊天界面，消息气泡设计，流畅的交互体验
// 关键功能：消息发送、消息展示、举报用户、视频聊天

/// 聊天页面
struct MessageUser_lite: View {
    
    /// 用户数据（用于用户聊天）
    var user_lite: PrewUserModel_lite?
    
    /// 群组ID（用于群聊）
    var groupId_lite: Int?
    
    @ObservedObject private var messageVM_lite = MessageViewModel_lite.shared_lite
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var router_lite = Router_lite.shared_lite
    
    @State private var messageText_lite = ""
    @State private var messages_lite: [MessageModel_lite] = []
    @State private var showReportSheet_lite = false
    @FocusState private var isInputFocused_lite: Bool
    
    /// 聊天标题
    private var chatTitle_lite: String {
        if let user = user_lite {
            return user.userName_lite ?? "Chat"
        } else if let groupId = groupId_lite {
            return "Group Chat \(groupId)"
        } else {
            return "Chat"
        }
    }
    
    /// 聊天副标题（在线状态）
    private var chatSubtitle_lite: String {
        return "Online"
    }
    
    var body: some View {
        ZStack {
            // 增强渐变背景
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "667eea").opacity(0.05),
                        Color(hex: "f093fb").opacity(0.03),
                        Color(hex: "F8F9FA")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 装饰性圆圈
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "667eea").opacity(0.08), Color.clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 200.w_lite
                        )
                    )
                    .frame(width: 300.w_lite, height: 300.h_lite)
                    .offset(x: -100.w_lite, y: -100.h_lite)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "f093fb").opacity(0.08), Color.clear],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 200.w_lite
                        )
                    )
                    .frame(width: 300.w_lite, height: 300.h_lite)
                    .offset(x: UIScreen.main.bounds.width - 100.w_lite, y: UIScreen.main.bounds.height - 100.h_lite)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 自定义顶部导航栏
                customHeaderView_lite
                
                // 消息列表区域
                ScrollViewReader { proxy_lite in
                    ScrollView {
                        VStack(spacing: 16.h_lite) {
                            ForEach(messages_lite) { message_lite in
                                MessageBubble_lite(message_lite: message_lite, user_lite: user_lite!,)
                                    .id(message_lite.messageId_lite)
                            }
                        }
                        .padding(.horizontal, 20.w_lite)
                        .padding(.vertical, 16.h_lite)
                    }
                    .onChange(of: messages_lite.count) { _, _ in
                        // 新消息时滚动到底部
                        if let lastMessage_lite = messages_lite.last {
                            withAnimation {
                                proxy_lite.scrollTo(lastMessage_lite.messageId_lite, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // 输入框区域
                inputAreaView_lite
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadMessages_lite()
        }
        .onReceive(messageVM_lite.objectWillChange) { _ in
            // 监听消息变化，自动刷新
            loadMessages_lite()
        }
        .onTapGesture {
            // 点击空白处收起键盘
            isInputFocused_lite = false
        }
    }
    
    // MARK: - 自定义顶部导航栏
    
    /// 自定义顶部导航栏
    private var customHeaderView_lite: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12.w_lite) {
                // 返回按钮（增强版）
                Button {
                    router_lite.pop_lite()
                } label: {
                    ZStack {
                        // 背景渐变
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white, Color(hex: "F8F9FA")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42.w_lite, height: 42.h_lite)
                        
                        // 图标
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20.sp_lite, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "667eea").opacity(0.3), Color(hex: "764ba2").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(hex: "667eea").opacity(0.2), radius: 12, x: 0, y: 6)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle_lite())
                
                // 用户头像和信息（增强版）
                HStack(spacing: 12.w_lite) {
                    // 使用统一的头像组件
                    if let user = user_lite, let userId = user.userId_lite {
                        ZStack {
                            // 外圈光晕
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: MediaConfig_lite.getGradientColors_lite(
                                            for: chatTitle_lite
                                        ).map { $0.opacity(0.3) },
                                        center: .center,
                                        startRadius: 20.w_lite,
                                        endRadius: 28.w_lite
                                    )
                                )
                                .frame(width: 52.w_lite, height: 52.h_lite)
                                .blur(radius: 2)
                            
                            // 主头像
                            UserAvatarView_lite(
                                userId_lite: userId,
                                size_lite: 46
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.8), Color.white.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                        }
                        .shadow(color: MediaConfig_lite.getGradientColors_lite(for: chatTitle_lite)[0].opacity(0.4), radius: 12, x: 0, y: 4)
                    }
                    
                    // 标题和状态
                    VStack(alignment: .leading, spacing: 4.h_lite) {
                        Text(chatTitle_lite)
                            .font(.system(size: 18.sp_lite, weight: .black))
                            .foregroundColor(Color(hex: "212529"))
                        
                        HStack(spacing: 6.w_lite) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "43e97b"))
                                    .frame(width: 10.w_lite, height: 10.h_lite)
                                
                                Circle()
                                    .stroke(Color(hex: "43e97b").opacity(0.3), lineWidth: 3)
                                    .frame(width: 10.w_lite, height: 10.h_lite)
                                    .scaleEffect(1.5)
                            }
                            .shadow(color: Color(hex: "43e97b").opacity(0.6), radius: 4, x: 0, y: 2)
                            
                            Text(chatSubtitle_lite)
                                .font(.system(size: 13.sp_lite, weight: .semibold))
                                .foregroundColor(Color(hex: "43e97b"))
                        }
                    }
                }
                
                Spacer()
                
                // 右侧按钮组（增强版）
                HStack(spacing: 8.w_lite) {
                    // 视频通话按钮（导航栏）
                    if let user = user_lite {
                        Button {
                            router_lite.toVideoChat_lite(user_lite: user)
                        } label: {
                            ZStack {
                                // 背景渐变
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white, Color(hex: "F8F9FA")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 42.w_lite, height: 42.h_lite)
                                
                                // 图标
                                Image(systemName: "video.fill")
                                    .font(.system(size: 19.sp_lite, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "667eea").opacity(0.3), Color(hex: "764ba2").opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 12, x: 0, y: 6)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                        }
                        .buttonStyle(ScaleButtonStyle_lite())
                    }
                    
                    // 举报按钮（增强版）
                    Button {
                        showReportSheet_lite = true
                    } label: {
                        ZStack {
                            // 背景渐变
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white, Color(hex: "FFF5F5")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 42.w_lite, height: 42.h_lite)
                            
                            // 图标
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.system(size: 19.sp_lite, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "f5576c"), Color(hex: "f093fb")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "f5576c").opacity(0.3), Color(hex: "f093fb").opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: Color(hex: "f5576c").opacity(0.3), radius: 12, x: 0, y: 6)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    }
                    .buttonStyle(ScaleButtonStyle_lite())
                }
            }
            .padding(.horizontal, 20.w_lite)
            .padding(.top, 12.h_lite)
            .padding(.bottom, 12.h_lite)
            .background(
                Color.white
                    .ignoresSafeArea(edges: .top)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .background(
            ReportActionSheet_lite(
                isShowing_lite: $showReportSheet_lite,
                isBlockUser_lite: true,
                onConfirm_lite: {
                    if let user = user_lite {
                        ReportHelper_lite.blockUser_lite(user_lite: user) {
                            router_lite.pop_lite()
                        }
                    }
                }
            )
        )
    }
    
    // MARK: - 输入框区域
    
    /// 输入框区域
    private var inputAreaView_lite: some View {
        VStack(spacing: 0) {
            // 分隔线
            Rectangle()
                .fill(Color(hex: "E9ECEF"))
                .frame(height: 1)
            
            HStack(spacing: 12.w_lite) {
                // 输入框
                HStack(spacing: 12.w_lite) {
                    TextField("Type a message...", text: $messageText_lite, axis: .vertical)
                        .font(.system(size: 16.sp_lite, weight: .medium))
                        .lineLimit(1...5)
                        .focused($isInputFocused_lite)
                }
                .padding(.horizontal, 16.w_lite)
                .padding(.vertical, 12.h_lite)
                .background(
                    RoundedRectangle(cornerRadius: 24.w_lite)
                        .fill(Color(hex: "F8F9FA"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24.w_lite)
                        .stroke(
                            isInputFocused_lite ?
                                Color(hex: "667eea").opacity(0.5) :
                                Color(hex: "E9ECEF"),
                            lineWidth: 1.5
                        )
                )
                
                // 视频聊天按钮（输入框旁 - 增强版）
                if let user = user_lite {
                    Button {
                        router_lite.toVideoChat_lite(user_lite: user)
                    } label: {
                        ZStack {
                            // 背景渐变
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50.w_lite, height: 50.h_lite)
                            
                            // 高光效果
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 50.w_lite, height: 50.h_lite)
                            
                            // 图标
                            Image(systemName: "video.fill")
                                .font(.system(size: 22.sp_lite, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                        .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 15, x: 0, y: 8)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle_lite())
                }
                
                // 发送按钮（增强版）
                Button {
                    sendMessage_lite()
                } label: {
                    ZStack {
                        // 背景渐变
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: messageText_lite.isEmpty ?
                                        [Color(hex: "E9ECEF"), Color(hex: "ADB5BD")] :
                                        [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50.w_lite, height: 50.h_lite)
                        
                        // 高光效果
                        if !messageText_lite.isEmpty {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 50.w_lite, height: 50.h_lite)
                        }
                        
                        // 图标
                        Image(systemName: messageText_lite.isEmpty ? "arrow.up.circle.fill" : "paperplane.fill")
                            .font(.system(size: 22.sp_lite, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                            .rotationEffect(.degrees(messageText_lite.isEmpty ? 0 : 0))
                    }
                    .overlay(
                        Circle()
                            .stroke(
                                messageText_lite.isEmpty ?
                                    Color.white.opacity(0.3) :
                                    Color.white.opacity(0.5),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: messageText_lite.isEmpty ? Color.clear : Color(hex: "f093fb").opacity(0.5),
                        radius: messageText_lite.isEmpty ? 0 : 15,
                        x: 0,
                        y: messageText_lite.isEmpty ? 0 : 8
                    )
                    .shadow(
                        color: Color.black.opacity(messageText_lite.isEmpty ? 0.05 : 0.1),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .buttonStyle(ScaleButtonStyle_lite())
                .disabled(messageText_lite.isEmpty)
            }
            .padding(.horizontal, 20.w_lite)
            .padding(.vertical, 12.h_lite)
            .background(Color.white)
        }
    }
    
    // MARK: - 辅助方法
    
    /// 加载消息
    private func loadMessages_lite() {
        DispatchQueue.main.async {
            if let user = user_lite, let userId = user.userId_lite {
                messages_lite = messageVM_lite.getMessagesWithUser_lite(userId_lite: userId)
            } else if let groupId = groupId_lite {
                messages_lite = messageVM_lite.getGroupMessages_lite(groupId_lite: groupId)
            }
        }
    }
    
    /// 发送消息
    private func sendMessage_lite() {
        guard !messageText_lite.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedMessage_lite = messageText_lite.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 发送消息
        if let user = user_lite, let userId = user.userId_lite {
            messageVM_lite.sendMessage_lite(
                message_lite: trimmedMessage_lite,
                chatType_lite: .personal_lite,
                id_lite: userId
            )
        } else if let groupId = groupId_lite {
            messageVM_lite.sendMessage_lite(
                message_lite: trimmedMessage_lite,
                chatType_lite: .group_lite,
                id_lite: groupId
            )
        }
        
        // 清空输入框
        messageText_lite = ""
        
        // 延迟刷新消息列表，确保ViewModel已更新
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            loadMessages_lite()
        }
    }
}

// MARK: - 消息气泡组件

/// 消息气泡（增强版）
struct MessageBubble_lite: View {
    
    let message_lite: MessageModel_lite
    
    let user_lite: PrewUserModel_lite
    
    @State private var appeared_lite = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10.w_lite) {
            if message_lite.isMine_lite == true {
                Spacer()
                
                // 我的消息（右侧 - 增强版）
                VStack(alignment: .trailing, spacing: 6.h_lite) {
                    ZStack {
                        // 主气泡
                        Text(message_lite.content_lite ?? "")
                            .font(.system(size: 16.sp_lite, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18.w_lite)
                            .padding(.vertical, 14.h_lite)
                            .background(
                                ZStack {
                                    // 主渐变背景
                                    LinearGradient(
                                        colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    
                                    // 高光效果
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                }
                            )
                            .cornerRadius(20.w_lite, corners_lite: [.topLeft, .topRight, .bottomLeft])
                            .overlay(
                                RoundedCorner_lite(radius_lite: 20.w_lite, corners_lite: [.topLeft, .topRight, .bottomLeft])
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color(hex: "f093fb").opacity(0.4), radius: 12, x: 0, y: 6)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(appeared_lite ? 1.0 : 0.7)
                    .opacity(appeared_lite ? 1.0 : 0)
                    
                    if let time = message_lite.time_lite {
                        HStack(spacing: 4.w_lite) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10.sp_lite))
                                .foregroundColor(Color(hex: "43e97b"))
                            
                            Text(time)
                                .font(.system(size: 11.sp_lite, weight: .semibold))
                                .foregroundColor(Color(hex: "ADB5BD"))
                        }
                        .opacity(appeared_lite ? 1.0 : 0)
                    }
                }
            } else {
                // 对方的消息（左侧 - 增强版）
                // 显示对方头像
                if let senderId = message_lite.isMine_lite, !senderId {
                    UserAvatarView_lite(
                        userId_lite: user_lite.userId_lite!,
                        size_lite: 36
                    )
                    .offset(y: 8.h_lite)
                }
                
                VStack(alignment: .leading, spacing: 6.h_lite) {
                    ZStack {
                        // 主气泡
                        Text(message_lite.content_lite ?? "")
                            .font(.system(size: 16.sp_lite, weight: .medium))
                            .foregroundColor(Color(hex: "212529"))
                            .padding(.horizontal, 18.w_lite)
                            .padding(.vertical, 14.h_lite)
                            .background(
                                ZStack {
                                    // 主背景
                                    LinearGradient(
                                        colors: [Color.white, Color(hex: "F8F9FA")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    
                                    // 高光效果
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.8), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                }
                            )
                            .cornerRadius(20.w_lite, corners_lite: [.topLeft, .topRight, .bottomRight])
                            .overlay(
                                RoundedCorner_lite(radius_lite: 20.w_lite, corners_lite: [.topLeft, .topRight, .bottomRight])
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "667eea").opacity(0.2), Color(hex: "764ba2").opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: Color(hex: "667eea").opacity(0.15), radius: 12, x: 0, y: 6)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(appeared_lite ? 1.0 : 0.7)
                    .opacity(appeared_lite ? 1.0 : 0)
                    
                    if let time = message_lite.time_lite {
                        HStack(spacing: 4.w_lite) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10.sp_lite))
                                .foregroundColor(Color(hex: "667eea"))
                            
                            Text(time)
                                .font(.system(size: 11.sp_lite, weight: .semibold))
                                .foregroundColor(Color(hex: "ADB5BD"))
                        }
                        .opacity(appeared_lite ? 1.0 : 0)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared_lite = true
            }
        }
    }
}

// MARK: - 圆角扩展

extension View {
    /// 自定义圆角
    func cornerRadius(_ radius_lite: CGFloat, corners_lite: UIRectCorner) -> some View {
        clipShape(RoundedCorner_lite(radius_lite: radius_lite, corners_lite: corners_lite))
    }
}

/// 自定义圆角形状
struct RoundedCorner_lite: Shape {
    var radius_lite: CGFloat = .infinity
    var corners_lite: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path_lite = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners_lite,
            cornerRadii: CGSize(width: radius_lite, height: radius_lite)
        )
        return Path(path_lite.cgPath)
    }
}
