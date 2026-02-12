import SwiftUI

// MARK: - 消息列表页
// 核心作用：展示所有聊天会话列表和推荐用户
// 设计思路：现代化设计 + 推荐用户 + 聊天记录用户 + 响应式布局
// 关键功能：聊天列表、推荐用户、消息预览、导航到聊天页

/// 消息列表页
struct MessageList_platbell: View {
    
    @ObservedObject var messageVM_platbell = MessageViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    @ObservedObject var localData_platbell = LocalData_platbell.shared_platbell
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    
    /// 获取有聊天记录的用户列表
    private var chatUsers_platbell: [PrewUserModel_platbell] {
        messageVM_platbell.getChatUsers_platbell()
    }
    
    /// 获取推荐用户列表（排除已有聊天记录的用户）
    private var recommendedUsers_platbell: [PrewUserModel_platbell] {
        let chatUserIds_platbell = Set(chatUsers_platbell.compactMap { $0.userId_platbell })
        return localData_platbell.getRecommendedUsers_platbell()
            .filter { user_platbell in
                guard let userId_platbell = user_platbell.userId_platbell else { return false }
                return !chatUserIds_platbell.contains(userId_platbell)
            }
            .prefix(6)
            .map { $0 }
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundView_platbell
            
            ScrollView {
                VStack(spacing: 0) {
                    // 顶部标题
                    headerView_platbell
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    
                    // 推荐用户区域
                    if !recommendedUsers_platbell.isEmpty {
                        recommendedUsersSection_platbell
                            .padding(.top, 20)
                    }
                    
                    // 聊天记录列表
                    chatListSection_platbell
                        .padding(.top, 20)
                }
                .padding(.bottom, 100)
            }
        }
    }
    
    // MARK: - 子视图
    
    /// 渐变背景
    private var backgroundView_platbell: some View {
        LinearGradient(
            colors: [
                ThemeColors_platbell.accentBlueStart_platbell.opacity(0.1),
                ThemeColors_platbell.primaryStart_platbell.opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// 顶部标题
    private var headerView_platbell: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                // 装饰性图标
                ZStack {
                    Circle()
                        .fill(
                            ThemeColors_platbell.gradient_platbell(at: 3)
                                .opacity(0.2)
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            ThemeColors_platbell.gradient_platbell(at: 3)
                        )
                        .breathing_platbell(isEnabled_platbell: true, duration_platbell: 2.5, scaleRange_platbell: 0.1)
                }
                .shadow(
                    color: ThemeColors_platbell.accentBlueStart_platbell.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Messages")
                        .font(.system(size: 32, weight: .bold))
                        .gradientText_platbell(gradientIndex_platbell: 3)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ThemeColors_platbell.accentBlueStart_platbell)
                        
                        Text("Stay connected")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // 统计卡片
            statsCard_platbell
        }
    }
    
    /// 统计卡片
    private var statsCard_platbell: some View {
        HStack(spacing: 12) {
            // 聊天数量
            StatItemCompact_platbell(
                icon_platbell: "bubble.left.and.bubble.right.fill",
                value_platbell: "\(chatUsers_platbell.count)",
                label_platbell: "Chats",
                gradientIndex_platbell: 3
            )
            
            // 推荐用户数量
            StatItemCompact_platbell(
                icon_platbell: "person.2.fill",
                value_platbell: "\(recommendedUsers_platbell.count)",
                label_platbell: "Suggested",
                gradientIndex_platbell: 2
            )
            
            // 在线状态
            StatItemCompact_platbell(
                icon_platbell: "circle.fill",
                value_platbell: "Online",
                label_platbell: "Status",
                gradientIndex_platbell: 4
            )
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            ThemeColors_platbell.accentBlueStart_platbell.opacity(0.3),
                            ThemeColors_platbell.primaryStart_platbell.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    /// 推荐用户区域
    private var recommendedUsersSection_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 2))
                
                Text("Suggested Users")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // 横向滚动的推荐用户列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recommendedUsers_platbell.indices, id: \.self) { index_platbell in
                        let user_platbell = recommendedUsers_platbell[index_platbell]
                        
                        RecommendedUserCard_platbell(
                            user_platbell: user_platbell,
                            gradientIndex_platbell: index_platbell % ThemeColors_platbell.allGradients_platbell.count
                        )
                        .onTapGesture {
                            router_platbell.navigate_platbell(to: .userChat_platbell(user_platbell: user_platbell))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    /// 聊天记录列表区域
    private var chatListSection_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 聊天列表
            if chatUsers_platbell.isEmpty {
                // 空状态居中显示
                emptyStateView_platbell
            } else {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 3))
                    
                    Text("Recent Chats")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 0) {
                    ForEach(chatUsers_platbell.indices, id: \.self) { index_platbell in
                        let user_platbell = chatUsers_platbell[index_platbell]
                        
                        ChatListItem_platbell(
                            user_platbell: user_platbell,
                            lastMessage_platbell: messageVM_platbell.getLastMessageWithUser_platbell(
                                userId_platbell: user_platbell.userId_platbell ?? 0
                            )
                        )
                        .onTapGesture {
                            router_platbell.navigate_platbell(to: .userChat_platbell(user_platbell: user_platbell))
                        }
                        
                        if index_platbell < chatUsers_platbell.count - 1 {
                            Divider()
                                .padding(.leading, 80)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 16)
            }
        }
    }
    
    /// 空状态视图（居中显示）
    private var emptyStateView_platbell: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(ThemeColors_platbell.gradient_platbell(at: 3).opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 3))
                }
                
                Text("No messages yet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Start a conversation with suggested users")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 推荐用户卡片

/// 推荐用户卡片组件
struct RecommendedUserCard_platbell: View {
    let user_platbell: PrewUserModel_platbell
    let gradientIndex_platbell: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // 用户头像
            UserAvatarView_platbell(
                userId_platbell: user_platbell.userId_platbell ?? 0,
                size_platbell: 70,
                isClickable_platbell: false
            )
            .overlay(
                Circle()
                    .stroke(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell),
                        lineWidth: 2.5
                    )
            )
            .shadow(
                color: ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                    .opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            
            // 用户信息
            VStack(spacing: 4) {
                Text(user_platbell.userName_platbell ?? "User")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(user_platbell.userFans_platbell ?? 0) fans")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 100)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell).opacity(0.3),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 聊天列表项

/// 聊天列表项组件
struct ChatListItem_platbell: View {
    let user_platbell: PrewUserModel_platbell
    let lastMessage_platbell: MessageModel_platbell?
    
    var body: some View {
        HStack(spacing: 12) {
            // 用户头像
            UserAvatarView_platbell(
                userId_platbell: user_platbell.userId_platbell ?? 0,
                size_platbell: 56,
                isClickable_platbell: false
            )
            .overlay(
                Circle()
                    .stroke(
                        ThemeColors_platbell.gradient_platbell(at: 3).opacity(0.5),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: ThemeColors_platbell.accentBlueStart_platbell.opacity(0.2),
                radius: 6,
                x: 0,
                y: 3
            )
            
            // 消息信息
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(user_platbell.userName_platbell ?? "User")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let time_platbell = lastMessage_platbell?.time_platbell {
                        Text(time_platbell)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                if let content_platbell = lastMessage_platbell?.content_platbell {
                    Text(content_platbell)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("Start a conversation")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
            
            // 右箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
