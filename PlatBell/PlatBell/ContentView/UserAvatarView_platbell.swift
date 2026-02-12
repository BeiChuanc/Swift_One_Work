import SwiftUI

// MARK: - 用户头像组件

/// 头像颜色配置
private let avatarColors_platbell: [Color] = [
    Color(hex: "667eea"), Color(hex: "f093fb"), Color(hex: "63B3ED"),
    Color(hex: "F6AD55"), Color(hex: "FC8181")
]

/// 根据用户ID获取头像颜色
private func avatarColor_platbell(for userId_platbell: Int) -> Color {
    avatarColors_platbell[userId_platbell % avatarColors_platbell.count]
}

// MARK: - 用户头像视图

/// 用户头像视图
/// 根据用户ID自动判断是登录用户还是预制用户，显示对应头像
struct UserAvatarView_platbell: View {
    
    /// 观察用户状态变化
    @ObservedObject private var userVM_platbell = UserViewModel_platbell.shared_platbell
    
    /// 用户ID
    let userId_platbell: Int
    
    /// 头像大小
    var size_platbell: CGFloat = 50
    
    /// 是否可点击
    var isClickable_platbell: Bool = false
    
    /// 点击回调
    var onTapped_platbell: (() -> Void)?
    
    /// 是否显示在线状态指示器（仅对当前登录用户生效）
    var showOnlineIndicator_platbell: Bool = false
    
    /// 是否显示编辑按钮（仅对当前登录用户生效）
    var showEditButton_platbell: Bool = false
    
    /// 是否是当前登录用户
    private var isCurrentUser_platbell: Bool {
        userVM_platbell.isCurrentUser_platbell(userId_platbell: userId_platbell)
    }
    
    /// 当前用户信息（根据是否是登录用户选择数据源）
    private var currentUserInfo_platbell: (avatarPath: String?, userName: String?) {
        if isCurrentUser_platbell {
            // 登录用户
            return (userVM_platbell.loggedUser_platbell?.userHead_platbell,
                    userVM_platbell.loggedUser_platbell?.userName_platbell)
        } else {
            // 预制用户
            let prewUser_platbell = userVM_platbell.getUserById_platbell(userId_platbell: userId_platbell)
            return (prewUser_platbell.userHead_platbell,
                    prewUser_platbell.userName_platbell)
        }
    }
    
    var body: some View {
        Button(action: handleTap_platbell) {
            ZStack(alignment: .bottomTrailing) {
                // 主头像
                avatarContent_platbell
                    .frame(width: size_platbell, height: size_platbell)
                    .clipShape(Circle())
                
                // 在线状态指示器（仅当前登录用户且已登录时显示）
                if showOnlineIndicator_platbell && isCurrentUser_platbell && userVM_platbell.isLoggedIn_platbell {
                    statusIndicator_platbell(color: Color(hex: "48BB78"))
                }
                
                // 编辑按钮（仅当前登录用户时显示）
                if showEditButton_platbell && isCurrentUser_platbell {
                    editButton_platbell
                }
            }
        }
        .disabled(!isClickable_platbell)
        .buttonStyle(.plain)
    }
    
    /// 头像内容视图
    @ViewBuilder
    private var avatarContent_platbell: some View {
        let info_platbell = currentUserInfo_platbell
        
        if let path_platbell = info_platbell.avatarPath, !path_platbell.isEmpty {
            // 显示真实头像
            MediaDisplayView_platbell(
                mediaPath_platbell: path_platbell,
                isVideo_platbell: false,
                cornerRadius_platbell: size_platbell / 2
            )
        } else {
            // 显示默认头像
            defaultAvatar_platbell(userName: info_platbell.userName)
        }
    }
    
    /// 默认头像视图
    private func defaultAvatar_platbell(userName: String?) -> some View {
        ZStack {
            Circle().fill(avatarColor_platbell(for: userId_platbell))
            
            if let firstLetter_platbell = userName?.prefix(1).uppercased() {
                Text(firstLetter_platbell)
                    .font(.system(size: size_platbell * 0.4, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size_platbell * 0.5))
                    .foregroundColor(.white)
            }
        }
    }
    
    /// 在线状态指示器
    private func statusIndicator_platbell(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: size_platbell * 0.28, height: size_platbell * 0.28)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .offset(x: 2, y: 2)
    }
    
    /// 编辑按钮
    private var editButton_platbell: some View {
        Image(systemName: "pencil.circle.fill")
            .font(.system(size: size_platbell * 0.32))
            .foregroundColor(.blue)
            .background(Circle().fill(Color.white))
            .offset(x: 2, y: 2)
    }
    
    /// 处理点击事件
    private func handleTap_platbell() {
        if isClickable_platbell {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTapped_platbell?()
        }
    }
}

// MARK: - 头像组（多个头像叠加）

/// 头像组视图
/// 用于显示多个用户头像的叠加效果
struct AvatarGroup_platbell: View {
    
    /// 用户列表
    let users_platbell: [PrewUserModel_platbell]
    
    /// 最多显示的头像数量
    var maxDisplay_platbell: Int = 3
    
    /// 头像大小
    var avatarSize_platbell: CGFloat = 40
    
    /// 头像重叠偏移量
    var overlapOffset_platbell: CGFloat = -10
    
    var body: some View {
        let displayUsers_platbell = Array(users_platbell.prefix(maxDisplay_platbell))
        
        HStack(spacing: overlapOffset_platbell) {
            ForEach(displayUsers_platbell.indices, id: \.self) { index_platbell in
                let user_platbell = displayUsers_platbell[index_platbell]
                
                UserAvatarView_platbell(
                    userId_platbell: user_platbell.userId_platbell ?? 0,
                    size_platbell: avatarSize_platbell
                )
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
                .zIndex(Double(maxDisplay_platbell - index_platbell))
            }
            
            // 显示剩余用户数量徽章
            if users_platbell.count > maxDisplay_platbell {
                remainingCountBadge_platbell
            }
        }
    }
    
    /// 剩余数量徽章
    private var remainingCountBadge_platbell: some View {
        ZStack {
            Circle().fill(Color.gray.opacity(0.8))
            Text("+\(users_platbell.count - maxDisplay_platbell)")
                .font(.system(size: avatarSize_platbell * 0.35, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: avatarSize_platbell, height: avatarSize_platbell)
    }
}

// MARK: - 头像网格

/// 头像网格视图
/// 用于以网格形式展示多个用户头像
struct AvatarGrid_platbell: View {
    
    /// 用户列表
    let users_platbell: [PrewUserModel_platbell]
    
    /// 网格列数
    var columns_platbell: Int = 4
    
    /// 头像大小
    var avatarSize_platbell: CGFloat = 60
    
    /// 间距
    var spacing_platbell: CGFloat = 16
    
    /// 用户点击回调
    var onUserTapped_platbell: ((PrewUserModel_platbell) -> Void)?
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing_platbell), count: columns_platbell),
            spacing: spacing_platbell
        ) {
            ForEach(users_platbell, id: \.userId_platbell) { user in
                VStack(spacing: 8) {
                    UserAvatarView_platbell(
                        userId_platbell: user.userId_platbell ?? 0,
                        size_platbell: avatarSize_platbell,
                        isClickable_platbell: onUserTapped_platbell != nil,
                        onTapped_platbell: { onUserTapped_platbell?(user) }
                    )
                    
                    Text(user.userName_platbell ?? "Unknown")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
        }
    }
}
