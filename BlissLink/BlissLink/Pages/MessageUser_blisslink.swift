import SwiftUI

// MARK: - 聊天页面
// 核心作用：与用户、群组或AI进行聊天
// 设计思路：现代化聊天界面，支持文本消息、举报、视频通话
// 关键功能：消息展示、发送消息、举报、视频通话

/// 聊天页面
struct MessageUser_baseswift: View {
    
    // MARK: - 属性
    
    /// 用户数据（用于用户聊天）
    var user_blisslink: PrewUserModel_blisslink?
    
    /// 群组ID（用于群聊）
    var groupId_blisslink: Int?
    
    // MARK: - ViewModels
    
    @ObservedObject var messageVM_blisslink = MessageViewModel_blisslink.shared_blisslink
    @ObservedObject var router_blisslink = Router_blisslink.shared_blisslink
    @ObservedObject var userVM_blisslink = UserViewModel_blisslink.shared_blisslink
    
    // MARK: - 状态
    
    @State private var messageText_blisslink: String = ""
    @State private var showReportSheet_blisslink: Bool = false
    @State private var scrollProxy_blisslink: ScrollViewProxy?
    
    // MARK: - 聊天标题
    
    private var chatTitle_blisslink: String {
        if let user = user_blisslink {
            return user.userName_blisslink ?? "Chat"
        } else if let groupId = groupId_blisslink {
            return "Group Chat \(groupId)"
        } else {
            return "Chat"
        }
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层（铺满整个屏幕）
            ZStack {
                // 主背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "F0F9FF"),
                        Color(hex: "FFF5F7"),
                        Color(hex: "F7FAFC")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 顶部装饰渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "56CCF2").opacity(0.1),
                        Color(hex: "FA8BFF").opacity(0.06),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .center
                )
                .frame(height: 280.h_blisslink)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // 背景装饰圆圈（聊天气氛）
                Circle()
                    .fill(Color(hex: "56CCF2").opacity(0.08))
                    .frame(width: 300.w_blisslink, height: 300.h_blisslink)
                    .offset(x: -150.w_blisslink, y: -180.h_blisslink)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color(hex: "FA8BFF").opacity(0.06))
                    .frame(width: 320.w_blisslink, height: 320.h_blisslink)
                    .offset(x: 160.w_blisslink, y: 200.h_blisslink)
                    .blur(radius: 55)
                
                Circle()
                    .fill(Color(hex: "667EEA").opacity(0.05))
                    .frame(width: 280.w_blisslink, height: 280.h_blisslink)
                    .offset(x: -100.w_blisslink, y: 500.h_blisslink)
                    .blur(radius: 48)
                
                // 聊天气泡装饰（背景）- 更细腻
                ForEach(0..<6) { index_blisslink in
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: CGFloat(25 + index_blisslink * 12), height: CGFloat(25 + index_blisslink * 12))
                        .offset(
                            x: CGFloat([-110, 130, -70, 160, -130, 90][index_blisslink]),
                            y: CGFloat([180, 380, 580, 120, 480, 300][index_blisslink])
                        )
                        .blur(radius: CGFloat(6 + index_blisslink * 2))
                }
            }
            .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar_blisslink
                
                // 消息列表
                messageListView_blisslink
                
                // 底部输入框
                bottomInputBar_blisslink
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            initializeChat_blisslink()
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar_blisslink: some View {
        HStack {
            // 返回按钮
            Button(action: {
                router_blisslink.pop_blisslink()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36.w_blisslink, height: 36.h_blisslink)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
            }
            
            // 用户信息
            HStack(spacing: 10.w_blisslink) {
                // 头像（使用 UserAvatarView）
                if let user_blisslink = user_blisslink {
                    UserAvatarView_blisslink(
                        userId_blisslink: user_blisslink.userId_blisslink ?? 0,
                        avatarPath_blisslink: user_blisslink.userHead_blisslink,
                        userName_blisslink: user_blisslink.userName_blisslink,
                        size_blisslink: 40.w_blisslink
                    )
                } else {
                    // 群聊默认头像
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40.w_blisslink, height: 40.h_blisslink)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 20.sp_blisslink))
                            .foregroundColor(.white)
                    }
                }
                
                // 名称
                Text(chatTitle_blisslink)
                    .font(.system(size: 17.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // 右侧按钮
            HStack(spacing: 10.w_blisslink) {
                // 视频通话按钮
                Button(action: {
                    // 触觉反馈
                    let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
                    generator_blisslink.impactOccurred()
                    
                    handleVideoCall_blisslink()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 38.w_blisslink, height: 38.h_blisslink)
                        
                        Image(systemName: "video.fill")
                            .font(.system(size: 17.sp_blisslink, weight: .semibold))
                            .foregroundColor(Color(hex: "56CCF2"))
                    }
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "56CCF2").opacity(0.2), lineWidth: 1.5.w_blisslink)
                    )
                }
                
                // 举报按钮
                Button(action: {
                    // 触觉反馈
                    let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
                    generator_blisslink.impactOccurred()
                    
                    showReportSheet_blisslink = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 38.w_blisslink, height: 38.h_blisslink)
                        
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16.sp_blisslink, weight: .bold))
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(90))
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1.5.w_blisslink)
                    )
                }
            }
        }
        .padding(.horizontal, 20.w_blisslink)
        .padding(.top, 10.h_blisslink)
        .padding(.bottom, 12.h_blisslink)
        .background(
            ZStack {
                Color.white.opacity(0.85)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .top)
                
                // 举报ActionSheet（显示完整的举报选项）
                ReportActionSheet_blisslink(
                    isShowing_blisslink: $showReportSheet_blisslink,
                    isBlockUser_blisslink: true,
                    onConfirm_blisslink: {
                        handleReportUser_blisslink()
                    }
                )
            }
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - 消息列表视图
    
    private var messageListView_blisslink: some View {
        ScrollViewReader { proxy_blisslink in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12.h_blisslink) {
                    ForEach(currentMessages_blisslink.indices, id: \.self) { index_blisslink in
                        let message_blisslink = currentMessages_blisslink[index_blisslink]
                        MessageBubble_blisslink(
                            message_blisslink: message_blisslink,
                            otherUser_blisslink: user_blisslink
                        )
                        .id(message_blisslink.messageId_blisslink)
                        .slideIn_blisslink(from: .bottom, delay_blisslink: Double(index_blisslink) * 0.05)
                    }
                }
                .padding(.horizontal, 20.w_blisslink)
                .padding(.top, 20.h_blisslink)
                .padding(.bottom, 20.h_blisslink)
            }
            .onAppear {
                scrollProxy_blisslink = proxy_blisslink
                scrollToBottom_blisslink()
            }
            .onChange(of: currentMessages_blisslink.count) { _, _ in
                scrollToBottom_blisslink()
            }
        }
    }
    
    // MARK: - 底部输入栏
    
    private var bottomInputBar_blisslink: some View {
        VStack(spacing: 0) {
            // 顶部装饰线
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "667EEA").opacity(0.2),
                    Color(hex: "764BA2").opacity(0.2)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1.h_blisslink)
            
            HStack(spacing: 12.w_blisslink) {
                // 输入框
                TextField("Type a message...", text: $messageText_blisslink)
                    .font(.system(size: 15.sp_blisslink, weight: .medium))
                    .padding(.horizontal, 20.w_blisslink)
                    .padding(.vertical, 14.h_blisslink)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 26.w_blisslink)
                                .fill(Color.white)
                            
                            RoundedRectangle(cornerRadius: 26.w_blisslink)
                                .stroke(
                                    !messageText_blisslink.isEmpty ?
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "667EEA").opacity(0.4),
                                            Color(hex: "764BA2").opacity(0.4)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.clear, Color.clear]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2.w_blisslink
                                )
                        }
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                    )
                
                // 视频通话按钮
                Button(action: {
                    handleVideoCall_blisslink()
                }) {
                    ZStack {
                        // 外层光晕
                        Circle()
                            .fill(Color(hex: "56CCF2").opacity(0.2))
                            .frame(width: 52.w_blisslink, height: 52.h_blisslink)
                            .blur(radius: 6)
                        
                        // 主按钮
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "56CCF2"),
                                        Color(hex: "2F80ED")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 46.w_blisslink, height: 46.h_blisslink)
                        
                        Image(systemName: "video.fill")
                            .font(.system(size: 20.sp_blisslink, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color(hex: "56CCF2").opacity(0.4), radius: 10, x: 0, y: 5)
                }
                
                // 发送按钮
                Button(action: {
                    handleSendMessage_blisslink()
                }) {
                    ZStack {
                        // 外层光晕（有文字时显示）
                        if !messageText_blisslink.isEmpty {
                            Circle()
                                .fill(Color(hex: "667EEA").opacity(0.25))
                                .frame(width: 54.w_blisslink, height: 54.h_blisslink)
                                .blur(radius: 8)
                        }
                        
                        // 主按钮
                        Circle()
                            .fill(
                                !messageText_blisslink.isEmpty ?
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.25)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 46.w_blisslink, height: 46.h_blisslink)
                        
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 19.sp_blisslink, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(45))
                            .offset(x: 1.w_blisslink, y: -1.h_blisslink)
                    }
                    .shadow(
                        color: !messageText_blisslink.isEmpty ? Color(hex: "667EEA").opacity(0.4) : Color.clear,
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .disabled(messageText_blisslink.isEmpty)
                .scaleEffect(!messageText_blisslink.isEmpty ? 1.0 : 0.93)
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: messageText_blisslink.isEmpty)
            }
            .padding(.horizontal, 20.w_blisslink)
            .padding(.top, 15.h_blisslink)
            .padding(.bottom, 0.h_blisslink)
        }
        .background(
            ZStack {
                Color.white.opacity(0.90)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
                
                // 顶部渐变光晕
                VStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "667EEA").opacity(0.08),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 30.h_blisslink)
                    
                    Spacer()
                }
            }
        )
        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: -5)
    }
    
    // MARK: - 计算属性
    
    /// 当前消息列表
    private var currentMessages_blisslink: [MessageModel_blisslink] {
        if let userId_blisslink = user_blisslink?.userId_blisslink {
            return messageVM_blisslink.getMessagesWithUser_blisslink(userId_blisslink: userId_blisslink)
        } else if let groupId_blisslink = groupId_blisslink {
            return messageVM_blisslink.getGroupMessages_blisslink(groupId_blisslink: groupId_blisslink)
        }
        return []
    }
    
    // MARK: - 事件处理
    
    /// 初始化聊天
    private func initializeChat_blisslink() {
        // 滚动到底部
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollToBottom_blisslink()
        }
    }
    
    /// 发送消息
    private func handleSendMessage_blisslink() {
        guard !messageText_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // 检查是否登录
        if !userVM_blisslink.isLoggedIn_blisslink {
            // 延迟跳转到登录页面
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
                Router_blisslink.shared_blisslink.toLogin_blisslink()
            }
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        let message_blisslink = messageText_blisslink
        messageText_blisslink = ""
        
        // 发送消息
        if let userId_blisslink = user_blisslink?.userId_blisslink {
            messageVM_blisslink.sendMessage_blisslink(
                message_blisslink: message_blisslink,
                chatType_blisslink: .personal_blisslink,
                id_blisslink: userId_blisslink
            )
        } else if let groupId_blisslink = groupId_blisslink {
            messageVM_blisslink.sendMessage_blisslink(
                message_blisslink: message_blisslink,
                chatType_blisslink: .group_blisslink,
                id_blisslink: groupId_blisslink
            )
        }
        
        // 滚动到底部
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollToBottom_blisslink()
        }
    }
    
    /// 滚动到底部
    private func scrollToBottom_blisslink() {
        guard let lastMessage_blisslink = currentMessages_blisslink.last else { return }
        withAnimation {
            scrollProxy_blisslink?.scrollTo(lastMessage_blisslink.messageId_blisslink, anchor: .bottom)
        }
    }
    
    /// 处理视频通话
    /// 核心作用：发起视频通话，跳转到视频通话界面
    private func handleVideoCall_blisslink() {
        // 检查是否有用户信息
        guard let user_blisslink = user_blisslink else {
            Utils_blisslink.showWarning_blisslink(message_blisslink: "Cannot start video call")
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        // 跳转到视频通话界面
        router_blisslink.toVideoChat_blisslink(user_blisslink: user_blisslink)
        
        print("📹 发起视频通话：\(user_blisslink.userName_blisslink ?? "Unknown")")
    }
    
    /// 处理举报用户
    private func handleReportUser_blisslink() {
        guard let user_blisslink = user_blisslink else { return }
        
        ReportHelper_blisslink.blockUser_blisslink(user_blisslink: user_blisslink) {
            
            // 返回上一页
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router_blisslink.pop_blisslink()
            }
        }
    }
}

// MARK: - 消息气泡组件

/// 消息气泡
/// 核心作用：展示单条消息，区分自己和对方的消息样式
struct MessageBubble_blisslink: View {
    
    let message_blisslink: MessageModel_blisslink
    
    /// 对方用户信息（用于显示头像）
    let otherUser_blisslink: PrewUserModel_blisslink?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8.w_blisslink) {
            // 对方消息显示头像
            if message_blisslink.isMine_blisslink != true {
                UserAvatarView_blisslink(
                    userId_blisslink: otherUser_blisslink?.userId_blisslink ?? 0,
                    avatarPath_blisslink: otherUser_blisslink?.userHead_blisslink,
                    userName_blisslink: otherUser_blisslink?.userName_blisslink,
                    size_blisslink: 36.w_blisslink,
                    isClickable_blisslink: false
                )
            }
            
            if message_blisslink.isMine_blisslink == true {
                Spacer()
            }
            
            VStack(alignment: message_blisslink.isMine_blisslink == true ? .trailing : .leading, spacing: 6.h_blisslink) {
                // 消息内容气泡
                ZStack {
                    // 消息气泡
                    Text(message_blisslink.content_blisslink ?? "")
                        .font(.system(size: 15.sp_blisslink, weight: .medium))
                        .foregroundColor(message_blisslink.isMine_blisslink == true ? .white : .primary)
                        .padding(.horizontal, 18.w_blisslink)
                        .padding(.vertical, 14.h_blisslink)
                        .background(
                            ZStack {
                                // 主背景
                                if message_blisslink.isMine_blisslink == true {
                                    // 自己的消息 - 渐变背景
                                    RoundedRectangle(cornerRadius: 20.w_blisslink, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // 顶部光晕
                                    VStack {
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.25), Color.clear]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .frame(height: 18.h_blisslink)
                                        
                                        Spacer()
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 20.w_blisslink, style: .continuous))
                                } else {
                                    // 对方的消息 - 白色背景
                                    RoundedRectangle(cornerRadius: 20.w_blisslink, style: .continuous)
                                        .fill(Color.white)
                                    
                                    // 左侧装饰条
                                    HStack {
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .frame(width: 3.w_blisslink)
                                        .cornerRadius(1.5.w_blisslink)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 2.w_blisslink)
                                }
                            }
                            .shadow(
                                color: message_blisslink.isMine_blisslink == true ?
                                Color(hex: "667EEA").opacity(0.35) : Color.black.opacity(0.08),
                                radius: message_blisslink.isMine_blisslink == true ? 12 : 8,
                                x: 0,
                                y: message_blisslink.isMine_blisslink == true ? 6 : 4
                            )
                        )
                }
                
                // 时间和状态
                HStack(spacing: 6.w_blisslink) {
                    if message_blisslink.isMine_blisslink == true {
                        // 消息状态
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10.sp_blisslink))
                            .foregroundColor(Color(hex: "56CCF2"))
                    }
                    
                    if let time_blisslink = message_blisslink.time_blisslink {
                        Text(time_blisslink)
                            .font(.system(size: 11.sp_blisslink, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
                .padding(.horizontal, 6.w_blisslink)
            }
            .frame(maxWidth: 290.w_blisslink, alignment: message_blisslink.isMine_blisslink == true ? .trailing : .leading)
            
            if message_blisslink.isMine_blisslink != true {
                Spacer()
            }
        }
    }
}
