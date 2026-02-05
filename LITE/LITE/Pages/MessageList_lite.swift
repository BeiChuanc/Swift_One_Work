import SwiftUI

// MARK: - 消息列表页
// 核心作用：展示所有聊天会话列表，包含推荐用户和聊天记录
// 设计思路：现代化卡片设计，分为推荐用户横向滚动区和聊天列表垂直滚动区
// 关键功能：推荐用户、显示最后一条消息、未读标记、快速进入聊天

/// 消息列表页
struct MessageList_lite: View {
    
    @ObservedObject private var messageVM_lite = MessageViewModel_lite.shared_lite
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var localData_lite = LocalData_lite.shared_lite
    @ObservedObject private var router_lite = Router_lite.shared_lite
    
    @State private var recommendedUsers_lite: [PrewUserModel_lite] = []
    @State private var chatUsers_lite: [PrewUserModel_lite] = []
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            AnimatedGradientBackground_lite()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                headerView_lite
                    .padding(.horizontal, 20.w_lite)
                    .padding(.top, 10.h_lite)
                    .padding(.bottom, 16.h_lite)
                
                // 主内容区域
                ScrollView {
                    VStack(spacing: 24.h_lite) {
                        // 推荐用户区域
                        if !recommendedUsers_lite.isEmpty {
                            recommendedUsersSection_lite
                        }
                        
                        // 聊天记录区域
                        chatListSection_lite
                            .padding(.horizontal, 20.w_lite)
                    }
                    .padding(.bottom, 100.h_lite)
                }
            }
        }
        .onAppear {
            loadData_lite()
        }
        .onChange(of: localData_lite.userList_lite.map { $0.userId_lite }) { _, _ in
            // 当用户列表变化时（如被拉黑删除），重新加载数据
            loadData_lite()
        }
        .onChange(of: messageVM_lite.userMesMap_lite.keys.count) { _, _ in
            // 当聊天用户变化时，重新加载数据
            loadData_lite()
        }
    }
    
    // MARK: - 顶部导航栏
    
    /// 顶部导航栏
    private var headerView_lite: some View {
        VStack(alignment: .leading, spacing: 6.h_lite) {
            HStack(spacing: 8.w_lite) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 24.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                    .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 4)
                
                Text("Messages")
                    .font(.system(size: 32.sp_lite, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
            }
            
            Text("Connect with friends")
                .font(.system(size: 14.sp_lite, weight: .medium))
                .foregroundColor(Color(hex: "495057"))
        }
    }
    // MARK: - 推荐用户区域
    
    /// 推荐用户区域
    private var recommendedUsersSection_lite: some View {
        VStack(alignment: .leading, spacing: 12.h_lite) {
            // 标题
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "f093fb"))
                
                Text("Recommended")
                    .font(.system(size: 20.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
            }
            .padding(.horizontal, 20.w_lite)
            
            // 用户卡片横向滚动
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12.w_lite) {
                    ForEach(recommendedUsers_lite) { user_lite in
                        RecommendedUserCard_lite(
                            user_lite: user_lite,
                            onTap_lite: {
                                router_lite.toUserChat_lite(user_lite: user_lite)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20.w_lite)
            }
        }
    }
    
    // MARK: - 聊天记录区域
    
    /// 聊天记录区域
    private var chatListSection_lite: some View {
        VStack(alignment: .leading, spacing: 12.h_lite) {
            // 标题
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text(chatUsers_lite.isEmpty ? "No Messages Yet" : "Recent Chats")
                    .font(.system(size: 20.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
            }
            
            // 聊天列表
            if chatUsers_lite.isEmpty {
                emptyChatView_lite
            } else {
                VStack(spacing: 12.h_lite) {
                    ForEach(chatUsers_lite) { user_lite in
                        ChatListItemCard_lite(
                            user_lite: user_lite,
                            lastMessage_lite: messageVM_lite.getLastMessageWithUser_lite(
                                userId_lite: user_lite.userId_lite ?? 0
                            ),
                            onTap_lite: {
                                router_lite.toUserChat_lite(user_lite: user_lite)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - 空状态视图
    
    /// 空聊天列表视图
    private var emptyChatView_lite: some View {
        VStack(spacing: 16.h_lite) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60.sp_lite))
                .foregroundColor(Color(hex: "ADB5BD"))
                .padding(.top, 40.h_lite)
            
            Text("No conversations yet")
                .font(.system(size: 18.sp_lite, weight: .semibold))
                .foregroundColor(Color(hex: "495057"))
            
            Text("Start chatting with someone from the recommended list above")
                .font(.system(size: 14.sp_lite, weight: .regular))
                .foregroundColor(Color(hex: "6C757D"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40.w_lite)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40.h_lite)
    }
    
    // MARK: - 数据加载方法
    
    /// 加载数据
    private func loadData_lite() {
        // 获取有聊天记录的用户
        chatUsers_lite = messageVM_lite.getChatUsers_lite()
        
        // 获取推荐用户（排除已有聊天记录的用户）
        let chatUserIds_lite = Set(chatUsers_lite.compactMap { $0.userId_lite })
        recommendedUsers_lite = localData_lite.userList_lite.filter { user_lite in
            guard let userId_lite = user_lite.userId_lite else { return false }
            return !chatUserIds_lite.contains(userId_lite)
        }
        
        // 限制推荐用户数量为5个
        if recommendedUsers_lite.count > 5 {
            recommendedUsers_lite = Array(recommendedUsers_lite.prefix(5))
        }
    }
}

// MARK: - 推荐用户卡片组件

/// 推荐用户卡片（增强版）
struct RecommendedUserCard_lite: View {
    
    let user_lite: PrewUserModel_lite
    let onTap_lite: () -> Void
    
    @State private var isPressed_lite = false
    @State private var shimmerOffset_lite: CGFloat = -200
    
    var body: some View {
        Button(action: onTap_lite) {
            VStack(spacing: 12.h_lite) {
                // 用户头像 - 使用UserAvatarView_lite组件
                UserAvatarView_lite(
                    userId_lite: user_lite.userId_lite ?? 0,
                    size_lite: 72,
                    showOnlineIndicator_lite: true
                )
                
                // 用户信息
                VStack(spacing: 6.h_lite) {
                    Text(user_lite.userName_lite ?? "Unknown")
                        .font(.system(size: 15.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "212529"))
                        .lineLimit(1)
                    
                    HStack(spacing: 6.w_lite) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea").opacity(0.2), Color(hex: "764ba2").opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 24.w_lite, height: 24.h_lite)
                            
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 11.sp_lite, weight: .bold))
                                .foregroundColor(Color(hex: "667eea"))
                        }
                        
                        Text("\(user_lite.userFollow_lite ?? 0)")
                            .font(.system(size: 12.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "667eea"))
                    }
                }
            }
            .frame(width: 110.w_lite)
            .padding(.vertical, 20.h_lite)
            .padding(.horizontal, 12.w_lite)
            .background(
                ZStack {
                    // 主背景
                    RoundedRectangle(cornerRadius: 24.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "F8F9FA").opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // 闪光效果
                    RoundedRectangle(cornerRadius: 24.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, Color.white.opacity(0.5), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset_lite)
                        .mask(RoundedRectangle(cornerRadius: 24.w_lite))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24.w_lite)
                    .stroke(
                        LinearGradient(
                            colors: MediaConfig_lite.getGradientColors_lite(for: user_lite.userName_lite ?? "").map { $0.opacity(0.4) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            .shadow(color: MediaConfig_lite.getGradientColors_lite(for: user_lite.userName_lite ?? "")[0].opacity(0.2), radius: 15, x: 0, y: 5)
            .scaleEffect(isPressed_lite ? 0.92 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed_lite = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed_lite = false
                    }
                }
        )
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset_lite = 200
            }
        }
    }
}

// MARK: - 聊天列表项卡片组件

/// 聊天列表项卡片（增强版）
struct ChatListItemCard_lite: View {
    
    let user_lite: PrewUserModel_lite
    let lastMessage_lite: MessageModel_lite?
    let onTap_lite: () -> Void
    
    @State private var isPressed_lite = false
    
    var body: some View {
        Button(action: onTap_lite) {
            HStack(spacing: 16.w_lite) {
                // 用户头像 - 使用UserAvatarView_lite组件
                UserAvatarView_lite(
                    userId_lite: user_lite.userId_lite ?? 0,
                    size_lite: 64,
                    showOnlineIndicator_lite: true
                )
                
                // 消息信息
                VStack(alignment: .leading, spacing: 8.h_lite) {
                    HStack {
                        Text(user_lite.userName_lite ?? "Unknown")
                            .font(.system(size: 18.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "212529"))
                        
                        Spacer()
                        
                        if let time_lite = lastMessage_lite?.time_lite {
                            HStack(spacing: 4.w_lite) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10.sp_lite))
                                    .foregroundColor(Color(hex: "ADB5BD"))
                                
                                Text(time_lite)
                                    .font(.system(size: 12.sp_lite, weight: .semibold))
                                    .foregroundColor(Color(hex: "6C757D"))
                            }
                            .padding(.horizontal, 10.w_lite)
                            .padding(.vertical, 4.h_lite)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "F8F9FA"))
                            )
                        }
                    }
                    
                    HStack(spacing: 8.w_lite) {
                        // 最后一条消息
                        if let content_lite = lastMessage_lite?.content_lite {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 11.sp_lite))
                                    .foregroundColor(Color(hex: "667eea"))
                                
                                Text(content_lite)
                                    .font(.system(size: 14.sp_lite, weight: .medium))
                                    .foregroundColor(Color(hex: "6C757D"))
                                    .lineLimit(1)
                            }
                        } else {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 11.sp_lite))
                                    .foregroundColor(Color(hex: "f093fb"))
                                
                                Text("Start a conversation")
                                    .font(.system(size: 14.sp_lite, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                // 箭头图标（增强版）
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "667eea").opacity(0.15), Color(hex: "764ba2").opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32.w_lite, height: 32.h_lite)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "667eea"))
                }
            }
            .padding(18.w_lite)
            .background(
                ZStack {
                    // 主背景
                    RoundedRectangle(cornerRadius: 24.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "FAFBFC")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // 高光效果
                    RoundedRectangle(cornerRadius: 24.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.8), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24.w_lite)
                    .stroke(
                        LinearGradient(
                            colors: MediaConfig_lite.getGradientColors_lite(for: user_lite.userName_lite ?? "").map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
            .shadow(color: MediaConfig_lite.getGradientColors_lite(for: user_lite.userName_lite ?? "")[0].opacity(0.15), radius: 15, x: 0, y: 5)
            .scaleEffect(isPressed_lite ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed_lite = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed_lite = false
                    }
                }
        )
    }
}
