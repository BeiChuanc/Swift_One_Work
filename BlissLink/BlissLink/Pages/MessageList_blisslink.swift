import SwiftUI

// MARK: - 消息列表页
// 核心作用：展示所有聊天会话列表和推荐用户
// 设计思路：现代化卡片设计，推荐用户横向滚动，聊天列表纵向展示
// 关键功能：推荐用户、聊天会话、最后消息预览

/// 消息列表页
struct MessageList_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var messageVM_blisslink = MessageViewModel_blisslink.shared_blisslink
    @ObservedObject var router_blisslink = Router_blisslink.shared_blisslink
    @ObservedObject var localData_blisslink = LocalData_blisslink.shared_blisslink
    @ObservedObject var userVM_blisslink = UserViewModel_blisslink.shared_blisslink
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层（铺满整个屏幕）
            ZStack {
                // 主背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "F0F9FF"),
                        Color(hex: "F7FAFC"),
                        Color(hex: "FFF1F3")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 顶部装饰渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "56CCF2").opacity(0.08),
                        Color(hex: "667EEA").opacity(0.05),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 320.h_blisslink)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // 背景装饰圆圈
                Circle()
                    .fill(Color(hex: "56CCF2").opacity(0.07))
                    .frame(width: 320.w_blisslink, height: 320.h_blisslink)
                    .offset(x: -160.w_blisslink, y: -200.h_blisslink)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color(hex: "667EEA").opacity(0.06))
                    .frame(width: 350.w_blisslink, height: 350.h_blisslink)
                    .offset(x: 170.w_blisslink, y: 250.h_blisslink)
                    .blur(radius: 55)
                
                Circle()
                    .fill(Color(hex: "FA8BFF").opacity(0.05))
                    .frame(width: 290.w_blisslink, height: 290.h_blisslink)
                    .offset(x: -90.w_blisslink, y: 550.h_blisslink)
                    .blur(radius: 48)
                
                // 波浪装饰
                WaveShape_blisslink()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "56CCF2").opacity(0.04),
                                Color(hex: "667EEA").opacity(0.05)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 200.h_blisslink)
                    .offset(y: 350.h_blisslink)
            }
            .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 0) {
                // 顶部标题栏
                topNavigationBar_blisslink
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28.h_blisslink) {
                        // 推荐用户区域
                        recommendedUsersSection_blisslink
                        
                        // 聊天列表区域
                        chatListSection_blisslink
                    }
                    .padding(.top, 24.h_blisslink)
                    .padding(.bottom, 100.h_blisslink)
                }
            }
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar_blisslink: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4.h_blisslink) {
                Text("Messages")
                    .font(.system(size: 28.sp_blisslink, weight: .bold))
                    .foregroundColor(.primary)
                
                if !chatUsers_blisslink.isEmpty {
                    Text("\(chatUsers_blisslink.count) conversations")
                        .font(.system(size: 14.sp_blisslink, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20.w_blisslink)
        .padding(.top, 16.h_blisslink)
        .padding(.bottom, 12.h_blisslink)
    }
    
    // MARK: - 推荐用户区域
    
    private var recommendedUsersSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_blisslink) {
            // 标题
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 16.sp_blisslink))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Recommended")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20.w_blisslink)
            
            // 推荐用户列表（横向滚动）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16.w_blisslink) {
                    ForEach(recommendedUsers_blisslink.indices, id: \.self) { index_blisslink in
                        let user_blisslink = recommendedUsers_blisslink[index_blisslink]
                        RecommendedUserCard_blisslink(
                            user_blisslink: user_blisslink,
                            onTap_blisslink: {
                                handleUserTap_blisslink(user_blisslink)
                            }
                        )
                        .bounceIn_blisslink(delay_blisslink: Double(index_blisslink) * 0.08)
                    }
                }
                .padding(.horizontal, 20.w_blisslink)
            }
        }
    }
    
    // MARK: - 聊天列表区域
    
    private var chatListSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_blisslink) {
            // 标题
            if !chatUsers_blisslink.isEmpty {
                HStack {
                    Image(systemName: "message.fill")
                        .font(.system(size: 16.sp_blisslink))
                        .foregroundColor(Color(hex: "667EEA"))
                    
                    Text("Recent Chats")
                        .font(.system(size: 16.sp_blisslink, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20.w_blisslink)
            }
            
            // 聊天列表
            if chatUsers_blisslink.isEmpty {
                emptyStateView_blisslink
            } else {
                VStack(spacing: 12.h_blisslink) {
                    ForEach(chatUsers_blisslink.indices, id: \.self) { index_blisslink in
                        let user_blisslink = chatUsers_blisslink[index_blisslink]
                        ChatUserCard_blisslink(
                            user_blisslink: user_blisslink,
                            lastMessage_blisslink: messageVM_blisslink.getLastMessageWithUser_blisslink(userId_blisslink: user_blisslink.userId_blisslink ?? 0),
                            onTap_blisslink: {
                                handleUserTap_blisslink(user_blisslink)
                            }
                        )
                        .slideIn_blisslink(from: .bottom, delay_blisslink: Double(index_blisslink) * 0.08)
                    }
                }
                .padding(.horizontal, 20.w_blisslink)
            }
        }
    }
    
    // MARK: - 空状态视图
    
    private var emptyStateView_blisslink: some View {
        VStack(spacing: 20.h_blisslink) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "667EEA").opacity(0.1),
                                Color(hex: "764BA2").opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100.w_blisslink, height: 100.h_blisslink)
                
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 50.sp_blisslink))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8.h_blisslink) {
                Text("No conversations yet")
                    .font(.system(size: 18.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Start chatting with recommended users")
                    .font(.system(size: 14.sp_blisslink))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60.h_blisslink)
    }
    
    // MARK: - 计算属性
    
    /// 有聊天记录的用户
    private var chatUsers_blisslink: [PrewUserModel_blisslink] {
        return messageVM_blisslink.getChatUsers_blisslink()
    }
    
    /// 推荐用户（排除已聊天的）
    private var recommendedUsers_blisslink: [PrewUserModel_blisslink] {
        let chatUserIds_blisslink = chatUsers_blisslink.compactMap { $0.userId_blisslink }
        return localData_blisslink.userList_blisslink.filter { user_blisslink in
            guard let userId_blisslink = user_blisslink.userId_blisslink else { return false }
            return !chatUserIds_blisslink.contains(userId_blisslink)
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理用户点击
    private func handleUserTap_blisslink(_ user_blisslink: PrewUserModel_blisslink) {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 跳转到聊天页面
        router_blisslink.toUserChat_blisslink(user_blisslink: user_blisslink)
    }
}

// MARK: - 波浪形状

/// 波浪形状（装饰用）
struct WaveShape_blisslink: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: 0, y: height * 0.5))
        
        path.addQuadCurve(
            to: CGPoint(x: width * 0.25, y: height * 0.3),
            control: CGPoint(x: width * 0.125, y: height * 0.2)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.5),
            control: CGPoint(x: width * 0.375, y: height * 0.4)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 0.75, y: height * 0.3),
            control: CGPoint(x: width * 0.625, y: height * 0.2)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width, y: height * 0.5),
            control: CGPoint(x: width * 0.875, y: height * 0.4)
        )
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - 推荐用户卡片

/// 推荐用户卡片
struct RecommendedUserCard_blisslink: View {
    
    let user_blisslink: PrewUserModel_blisslink
    var onTap_blisslink: (() -> Void)?
    
    @State private var isPressed_blisslink: Bool = false
    
    var body: some View {
        Button(action: {
            onTap_blisslink?()
        }) {
            VStack(spacing: 12.h_blisslink) {
                // 头像（使用 UserAvatarView 组件）
                ZStack {
                    // 外层光晕
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "667EEA").opacity(0.3),
                                    Color(hex: "764BA2").opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 82.w_blisslink, height: 82.h_blisslink)
                        .blur(radius: 8)
                    
                    // 使用 UserAvatarView 组件
                    UserAvatarView_blisslink(
                        userId_blisslink: user_blisslink.userId_blisslink ?? 0,
                        avatarPath_blisslink: user_blisslink.userHead_blisslink,
                        userName_blisslink: user_blisslink.userName_blisslink,
                        size_blisslink: 74.w_blisslink,
                        isClickable_blisslink: true,
                        onTapped_blisslink: {
                            onTap_blisslink?()
                        }
                    )
                    
                    // 在线状态指示器
                    Circle()
                        .fill(Color.green)
                        .frame(width: 16.w_blisslink, height: 16.h_blisslink)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3.w_blisslink)
                        )
                        .offset(x: 26.w_blisslink, y: 26.h_blisslink)
                }
                
                // 用户名
                VStack(spacing: 4.h_blisslink) {
                    Text(user_blisslink.userName_blisslink ?? "User")
                        .font(.system(size: 13.sp_blisslink, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // 关注者数量
                    if let followers_blisslink = user_blisslink.userFans_blisslink {
                        Text("\(followers_blisslink) followers")
                            .font(.system(size: 11.sp_blisslink))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 85.w_blisslink)
            }
            .padding(.vertical, 12.h_blisslink)
            .padding(.horizontal, 8.w_blisslink)
            .background(
                RoundedRectangle(cornerRadius: 16.w_blisslink)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16.w_blisslink)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "667EEA").opacity(0.2),
                                Color(hex: "764BA2").opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5.w_blisslink
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed_blisslink ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed_blisslink)
    }
}

// MARK: - 聊天用户卡片

/// 聊天用户卡片
struct ChatUserCard_blisslink: View {
    
    let user_blisslink: PrewUserModel_blisslink
    let lastMessage_blisslink: MessageModel_blisslink?
    var onTap_blisslink: (() -> Void)?
    
    @State private var isPressed_blisslink: Bool = false
    
    var body: some View {
        Button(action: {
            onTap_blisslink?()
        }) {
            HStack(spacing: 16.w_blisslink) {
                // 用户头像（使用 UserAvatarView 组件）
                ZStack {
                    // 外层光晕
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "667EEA").opacity(0.3),
                                    Color(hex: "764BA2").opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64.w_blisslink, height: 64.h_blisslink)
                        .blur(radius: 6)
                    
                    // 使用 UserAvatarView 组件
                    UserAvatarView_blisslink(
                        userId_blisslink: user_blisslink.userId_blisslink ?? 0,
                        avatarPath_blisslink: user_blisslink.userHead_blisslink,
                        userName_blisslink: user_blisslink.userName_blisslink,
                        size_blisslink: 58.w_blisslink
                    )
                    
                    // 在线状态
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14.w_blisslink, height: 14.h_blisslink)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2.5.w_blisslink)
                        )
                        .offset(x: 20.w_blisslink, y: 20.h_blisslink)
                }
                
                // 聊天内容
                VStack(alignment: .leading, spacing: 6.h_blisslink) {
                    // 用户名
                    HStack(spacing: 6.w_blisslink) {
                        Text(user_blisslink.userName_blisslink ?? "User")
                            .font(.system(size: 16.sp_blisslink, weight: .bold))
                            .foregroundColor(.primary)
                        
                        // 验证标识
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14.sp_blisslink))
                            .foregroundColor(Color(hex: "56CCF2"))
                    }
                    
                    // 最后消息
                    HStack(spacing: 6.w_blisslink) {
                        if let lastMessage_blisslink = lastMessage_blisslink {
                            if lastMessage_blisslink.isMine_blisslink == true {
                                Text("You:")
                                    .font(.system(size: 13.sp_blisslink, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(lastMessage_blisslink.content_blisslink ?? "")
                                .font(.system(size: 14.sp_blisslink))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        } else {
                            HStack(spacing: 4.w_blisslink) {
                                Image(systemName: "hand.wave.fill")
                                    .font(.system(size: 12.sp_blisslink))
                                    .foregroundColor(Color(hex: "F2C94C"))
                                
                                Text("Start a conversation")
                                    .font(.system(size: 14.sp_blisslink))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // 右侧信息
                VStack(alignment: .trailing, spacing: 10.h_blisslink) {
                    // 时间
                    if let lastMessage_blisslink = lastMessage_blisslink,
                       let time_blisslink = lastMessage_blisslink.time_blisslink {
                        Text(time_blisslink)
                            .font(.system(size: 12.sp_blisslink, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // 未读徽章
                    if lastMessage_blisslink != nil {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 20.w_blisslink, height: 20.h_blisslink)
                            
                            Text("2")
                                .font(.system(size: 11.sp_blisslink, weight: .bold))
                                .foregroundColor(.white)
                        }
                    } else {
                        // 箭头图标
                        ZStack {
                            Circle()
                                .fill(Color(hex: "667EEA").opacity(0.1))
                                .frame(width: 28.w_blisslink, height: 28.h_blisslink)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13.sp_blisslink, weight: .semibold))
                                .foregroundColor(Color(hex: "667EEA"))
                        }
                    }
                }
            }
            .padding(18.w_blisslink)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18.w_blisslink)
                        .fill(Color.white)
                    
                    // 左侧渐变装饰条
                    HStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: 4.w_blisslink)
                        .cornerRadius(2.w_blisslink)
                        
                        Spacer()
                    }
                    .padding(.leading, 4.w_blisslink)
                }
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed_blisslink ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed_blisslink)
    }
}
