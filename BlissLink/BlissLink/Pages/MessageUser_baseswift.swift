import SwiftUI

// MARK: - 聊天页面
// 核心作用：与用户、群组或AI进行聊天
// 设计思路：现代化聊天界面，支持文本消息、举报、视频通话
// 关键功能：消息展示、发送消息、举报、视频通话

/// 聊天页面
struct MessageUser_baseswift: View {
    
    // MARK: - 属性
    
    /// 用户数据（用于用户聊天）
    var user_baseswiftui: PrewUserModel_baseswiftui?
    
    /// 群组ID（用于群聊）
    var groupId_baseswiftui: Int?
    
    // MARK: - ViewModels
    
    @ObservedObject var messageVM_baseswiftui = MessageViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    
    // MARK: - 状态
    
    @State private var messageText_blisslink: String = ""
    @State private var showReportSheet_blisslink: Bool = false
    @State private var scrollProxy_blisslink: ScrollViewProxy?
    
    // MARK: - 聊天标题
    
    private var chatTitle_baseswiftui: String {
        if let user = user_baseswiftui {
            return user.userName_baseswiftui ?? "Chat"
        } else if let groupId = groupId_baseswiftui {
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
                .frame(height: 280.h_baseswiftui)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // 背景装饰圆圈（聊天气氛）
                Circle()
                    .fill(Color(hex: "56CCF2").opacity(0.08))
                    .frame(width: 300.w_baseswiftui, height: 300.h_baseswiftui)
                    .offset(x: -150.w_baseswiftui, y: -180.h_baseswiftui)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color(hex: "FA8BFF").opacity(0.06))
                    .frame(width: 320.w_baseswiftui, height: 320.h_baseswiftui)
                    .offset(x: 160.w_baseswiftui, y: 200.h_baseswiftui)
                    .blur(radius: 55)
                
                Circle()
                    .fill(Color(hex: "667EEA").opacity(0.05))
                    .frame(width: 280.w_baseswiftui, height: 280.h_baseswiftui)
                    .offset(x: -100.w_baseswiftui, y: 500.h_baseswiftui)
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
                router_baseswiftui.pop_baseswiftui()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36.w_baseswiftui, height: 36.h_baseswiftui)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
            }
            
            // 用户信息
            HStack(spacing: 10.w_baseswiftui) {
                // 头像（使用 UserAvatarView）
                if let user_blisslink = user_baseswiftui {
                    UserAvatarView_baseswiftui(
                        userId_baseswiftui: user_blisslink.userId_baseswiftui ?? 0,
                        avatarPath_baseswiftui: user_blisslink.userHead_baseswiftui,
                        userName_baseswiftui: user_blisslink.userName_baseswiftui,
                        size_baseswiftui: 40.w_baseswiftui
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
                            .frame(width: 40.w_baseswiftui, height: 40.h_baseswiftui)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 20.sp_baseswiftui))
                            .foregroundColor(.white)
                    }
                }
                
                // 名称
                Text(chatTitle_baseswiftui)
                    .font(.system(size: 17.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // 右侧按钮
            HStack(spacing: 10.w_baseswiftui) {
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
                            .frame(width: 38.w_baseswiftui, height: 38.h_baseswiftui)
                        
                        Image(systemName: "video.fill")
                            .font(.system(size: 17.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(Color(hex: "56CCF2"))
                    }
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "56CCF2").opacity(0.2), lineWidth: 1.5.w_baseswiftui)
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
                            .frame(width: 38.w_baseswiftui, height: 38.h_baseswiftui)
                        
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16.sp_baseswiftui, weight: .bold))
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(90))
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1.5.w_baseswiftui)
                    )
                }
            }
        }
        .padding(.horizontal, 20.w_baseswiftui)
        .padding(.top, 10.h_baseswiftui)
        .padding(.bottom, 12.h_baseswiftui)
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
                LazyVStack(spacing: 12.h_baseswiftui) {
                    ForEach(currentMessages_blisslink.indices, id: \.self) { index_blisslink in
                        let message_blisslink = currentMessages_blisslink[index_blisslink]
                        MessageBubble_blisslink(
                            message_blisslink: message_blisslink,
                            otherUser_blisslink: user_baseswiftui
                        )
                        .id(message_blisslink.messageId_baseswiftui)
                        .slideIn_blisslink(from: .bottom, delay_blisslink: Double(index_blisslink) * 0.05)
                    }
                }
                .padding(.horizontal, 20.w_baseswiftui)
                .padding(.top, 20.h_baseswiftui)
                .padding(.bottom, 20.h_baseswiftui)
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
            .frame(height: 1.h_baseswiftui)
            
            HStack(spacing: 12.w_baseswiftui) {
                // 输入框
                TextField("Type a message...", text: $messageText_blisslink)
                    .font(.system(size: 15.sp_baseswiftui, weight: .medium))
                    .padding(.horizontal, 20.w_baseswiftui)
                    .padding(.vertical, 14.h_baseswiftui)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 26.w_baseswiftui)
                                .fill(Color.white)
                            
                            RoundedRectangle(cornerRadius: 26.w_baseswiftui)
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
                                    lineWidth: 2.w_baseswiftui
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
                            .frame(width: 52.w_baseswiftui, height: 52.h_baseswiftui)
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
                            .frame(width: 46.w_baseswiftui, height: 46.h_baseswiftui)
                        
                        Image(systemName: "video.fill")
                            .font(.system(size: 20.sp_baseswiftui, weight: .semibold))
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
                                .frame(width: 54.w_baseswiftui, height: 54.h_baseswiftui)
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
                            .frame(width: 46.w_baseswiftui, height: 46.h_baseswiftui)
                        
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 19.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(45))
                            .offset(x: 1.w_baseswiftui, y: -1.h_baseswiftui)
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
            .padding(.horizontal, 20.w_baseswiftui)
            .padding(.top, 15.h_baseswiftui)
            .padding(.bottom, 0.h_baseswiftui)
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
                    .frame(height: 30.h_baseswiftui)
                    
                    Spacer()
                }
            }
        )
        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: -5)
    }
    
    // MARK: - 计算属性
    
    /// 当前消息列表
    private var currentMessages_blisslink: [MessageModel_baseswiftui] {
        if let userId_blisslink = user_baseswiftui?.userId_baseswiftui {
            return messageVM_baseswiftui.getMessagesWithUser_baseswiftui(userId_baseswiftui: userId_blisslink)
        } else if let groupId_blisslink = groupId_baseswiftui {
            return messageVM_baseswiftui.getGroupMessages_baseswiftui(groupId_baseswiftui: groupId_blisslink)
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
        if !userVM_baseswiftui.isLoggedIn_baseswiftui {
            // 延迟跳转到登录页面
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
                Router_baseswiftui.shared_baseswiftui.toLogin_baseswiftui()
            }
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        let message_blisslink = messageText_blisslink
        messageText_blisslink = ""
        
        // 发送消息
        if let userId_blisslink = user_baseswiftui?.userId_baseswiftui {
            messageVM_baseswiftui.sendMessage_baseswiftui(
                message_baseswiftui: message_blisslink,
                chatType_baseswiftui: .personal_baseswiftui,
                id_baseswiftui: userId_blisslink
            )
        } else if let groupId_blisslink = groupId_baseswiftui {
            messageVM_baseswiftui.sendMessage_baseswiftui(
                message_baseswiftui: message_blisslink,
                chatType_baseswiftui: .group_baseswiftui,
                id_baseswiftui: groupId_blisslink
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
            scrollProxy_blisslink?.scrollTo(lastMessage_blisslink.messageId_baseswiftui, anchor: .bottom)
        }
    }
    
    /// 处理视频通话
    /// 核心作用：发起视频通话，跳转到视频通话界面
    private func handleVideoCall_blisslink() {
        // 检查是否有用户信息
        guard let user_blisslink = user_baseswiftui else {
            Utils_baseswiftui.showWarning_baseswiftui(message_baseswiftui: "Cannot start video call")
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        // 跳转到视频通话界面
        router_baseswiftui.toVideoChat_blisslink(user_blisslink: user_blisslink)
        
        print("📹 发起视频通话：\(user_blisslink.userName_baseswiftui ?? "Unknown")")
    }
    
    /// 处理举报用户
    private func handleReportUser_blisslink() {
        guard let user_blisslink = user_baseswiftui else { return }
        
        ReportHelper_blisslink.blockUser_blisslink(user_blisslink: user_blisslink) {
            
            // 返回上一页
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router_baseswiftui.pop_baseswiftui()
            }
        }
    }
}

// MARK: - 消息气泡组件

/// 消息气泡
/// 核心作用：展示单条消息，区分自己和对方的消息样式
struct MessageBubble_blisslink: View {
    
    let message_blisslink: MessageModel_baseswiftui
    
    /// 对方用户信息（用于显示头像）
    let otherUser_blisslink: PrewUserModel_baseswiftui?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8.w_baseswiftui) {
            // 对方消息显示头像
            if message_blisslink.isMine_baseswiftui != true {
                UserAvatarView_baseswiftui(
                    userId_baseswiftui: otherUser_blisslink?.userId_baseswiftui ?? 0,
                    avatarPath_baseswiftui: otherUser_blisslink?.userHead_baseswiftui,
                    userName_baseswiftui: otherUser_blisslink?.userName_baseswiftui,
                    size_baseswiftui: 36.w_baseswiftui,
                    isClickable_baseswiftui: false
                )
            }
            
            if message_blisslink.isMine_baseswiftui == true {
                Spacer()
            }
            
            VStack(alignment: message_blisslink.isMine_baseswiftui == true ? .trailing : .leading, spacing: 6.h_baseswiftui) {
                // 消息内容气泡
                ZStack {
                    // 消息气泡
                    Text(message_blisslink.content_baseswiftui ?? "")
                        .font(.system(size: 15.sp_baseswiftui, weight: .medium))
                        .foregroundColor(message_blisslink.isMine_baseswiftui == true ? .white : .primary)
                        .padding(.horizontal, 18.w_baseswiftui)
                        .padding(.vertical, 14.h_baseswiftui)
                        .background(
                            ZStack {
                                // 主背景
                                if message_blisslink.isMine_baseswiftui == true {
                                    // 自己的消息 - 渐变背景
                                    RoundedRectangle(cornerRadius: 20.w_baseswiftui, style: .continuous)
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
                                        .frame(height: 18.h_baseswiftui)
                                        
                                        Spacer()
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 20.w_baseswiftui, style: .continuous))
                                } else {
                                    // 对方的消息 - 白色背景
                                    RoundedRectangle(cornerRadius: 20.w_baseswiftui, style: .continuous)
                                        .fill(Color.white)
                                    
                                    // 左侧装饰条
                                    HStack {
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .frame(width: 3.w_baseswiftui)
                                        .cornerRadius(1.5.w_baseswiftui)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 2.w_baseswiftui)
                                }
                            }
                            .shadow(
                                color: message_blisslink.isMine_baseswiftui == true ?
                                Color(hex: "667EEA").opacity(0.35) : Color.black.opacity(0.08),
                                radius: message_blisslink.isMine_baseswiftui == true ? 12 : 8,
                                x: 0,
                                y: message_blisslink.isMine_baseswiftui == true ? 6 : 4
                            )
                        )
                }
                
                // 时间和状态
                HStack(spacing: 6.w_baseswiftui) {
                    if message_blisslink.isMine_baseswiftui == true {
                        // 消息状态
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10.sp_baseswiftui))
                            .foregroundColor(Color(hex: "56CCF2"))
                    }
                    
                    if let time_blisslink = message_blisslink.time_baseswiftui {
                        Text(time_blisslink)
                            .font(.system(size: 11.sp_baseswiftui, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
                .padding(.horizontal, 6.w_baseswiftui)
            }
            .frame(maxWidth: 290.w_baseswiftui, alignment: message_blisslink.isMine_baseswiftui == true ? .trailing : .leading)
            
            if message_blisslink.isMine_baseswiftui != true {
                Spacer()
            }
        }
    }
}
