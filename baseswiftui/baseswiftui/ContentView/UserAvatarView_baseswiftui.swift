import SwiftUI

// MARK: - 用户头像组件

/// 头像颜色配置
private let avatarColors_baseswiftui: [Color] = [
    Color(hex: "667eea"), Color(hex: "f093fb"), Color(hex: "63B3ED"),
    Color(hex: "F6AD55"), Color(hex: "FC8181")
]

/// 根据用户ID获取头像颜色
private func avatarColor_baseswiftui(for userId_baseswiftui: Int) -> Color {
    avatarColors_baseswiftui[userId_baseswiftui % avatarColors_baseswiftui.count]
}

// MARK: - 用户头像视图

/// 用户头像视图
/// 根据用户ID自动判断是登录用户还是预制用户，显示对应头像
struct UserAvatarView_baseswiftui: View {
    
    /// 观察用户状态变化
    @ObservedObject private var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    
    /// 用户ID
    let userId_baseswiftui: Int
    
    /// 头像大小
    var size_baseswiftui: CGFloat = 50
    
    /// 是否可点击
    var isClickable_baseswiftui: Bool = false
    
    /// 点击回调
    var onTapped_baseswiftui: (() -> Void)?
    
    /// 是否显示在线状态指示器（仅对当前登录用户生效）
    var showOnlineIndicator_baseswiftui: Bool = false
    
    /// 是否显示编辑按钮（仅对当前登录用户生效）
    var showEditButton_baseswiftui: Bool = false
    
    /// 是否是当前登录用户
    private var isCurrentUser_baseswiftui: Bool {
        userVM_baseswiftui.isCurrentUser_baseswiftui(userId_baseswiftui: userId_baseswiftui)
    }
    
    /// 当前用户信息（根据是否是登录用户选择数据源）
    private var currentUserInfo_baseswiftui: (avatarPath: String?, userName: String?) {
        if isCurrentUser_baseswiftui {
            // 登录用户
            return (userVM_baseswiftui.loggedUser_baseswiftui?.userHead_baseswiftui,
                    userVM_baseswiftui.loggedUser_baseswiftui?.userName_baseswiftui)
        } else {
            // 预制用户
            let prewUser_baseswiftui = userVM_baseswiftui.getUserById_baseswiftui(userId_baseswiftui: userId_baseswiftui)
            return (prewUser_baseswiftui.userHead_baseswiftui,
                    prewUser_baseswiftui.userName_baseswiftui)
        }
    }
    
    var body: some View {
        Button(action: handleTap_baseswiftui) {
            ZStack(alignment: .bottomTrailing) {
                // 主头像
                avatarContent_baseswiftui
                    .frame(width: size_baseswiftui, height: size_baseswiftui)
                    .clipShape(Circle())
                
                // 在线状态指示器（仅当前登录用户且已登录时显示）
                if showOnlineIndicator_baseswiftui && isCurrentUser_baseswiftui && userVM_baseswiftui.isLoggedIn_baseswiftui {
                    statusIndicator_baseswiftui(color: Color(hex: "48BB78"))
                }
                
                // 编辑按钮（仅当前登录用户时显示）
                if showEditButton_baseswiftui && isCurrentUser_baseswiftui {
                    editButton_baseswiftui
                }
            }
        }
        .disabled(!isClickable_baseswiftui)
        .buttonStyle(.plain)
    }
    
    /// 头像内容视图
    @ViewBuilder
    private var avatarContent_baseswiftui: some View {
        let info_baseswiftui = currentUserInfo_baseswiftui
        
        if let path_baseswiftui = info_baseswiftui.avatarPath, !path_baseswiftui.isEmpty {
            // 显示真实头像
            MediaDisplayView_baseswiftui(
                mediaPath_baseswiftui: path_baseswiftui,
                isVideo_baseswiftui: false,
                cornerRadius_baseswiftui: size_baseswiftui / 2
            )
        } else {
            // 显示默认头像
            defaultAvatar_baseswiftui(userName: info_baseswiftui.userName)
        }
    }
    
    /// 默认头像视图
    private func defaultAvatar_baseswiftui(userName: String?) -> some View {
        ZStack {
            Circle().fill(avatarColor_baseswiftui(for: userId_baseswiftui))
            
            if let firstLetter_baseswiftui = userName?.prefix(1).uppercased() {
                Text(firstLetter_baseswiftui)
                    .font(.system(size: size_baseswiftui * 0.4, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size_baseswiftui * 0.5))
                    .foregroundColor(.white)
            }
        }
    }
    
    /// 在线状态指示器
    private func statusIndicator_baseswiftui(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: size_baseswiftui * 0.28, height: size_baseswiftui * 0.28)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .offset(x: 2, y: 2)
    }
    
    /// 编辑按钮
    private var editButton_baseswiftui: some View {
        Image(systemName: "pencil.circle.fill")
            .font(.system(size: size_baseswiftui * 0.32))
            .foregroundColor(.blue)
            .background(Circle().fill(Color.white))
            .offset(x: 2, y: 2)
    }
    
    /// 处理点击事件
    private func handleTap_baseswiftui() {
        if isClickable_baseswiftui {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTapped_baseswiftui?()
        }
    }
}

// MARK: - 头像组（多个头像叠加）

/// 头像组视图
/// 用于显示多个用户头像的叠加效果
struct AvatarGroup_baseswiftui: View {
    
    /// 用户列表
    let users_baseswiftui: [PrewUserModel_baseswiftui]
    
    /// 最多显示的头像数量
    var maxDisplay_baseswiftui: Int = 3
    
    /// 头像大小
    var avatarSize_baseswiftui: CGFloat = 40
    
    /// 头像重叠偏移量
    var overlapOffset_baseswiftui: CGFloat = -10
    
    var body: some View {
        HStack(spacing: overlapOffset_baseswiftui) {
            ForEach(Array(users_baseswiftui.prefix(maxDisplay_baseswiftui).enumerated()), id: \.offset) { index, user in
                UserAvatarView_baseswiftui(
                    userId_baseswiftui: user.userId_baseswiftui ?? 0,
                    size_baseswiftui: avatarSize_baseswiftui
                )
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
                .zIndex(Double(maxDisplay_baseswiftui - index))
            }
            
            // 显示剩余用户数量徽章
            if users_baseswiftui.count > maxDisplay_baseswiftui {
                remainingCountBadge_baseswiftui
            }
        }
    }
    
    /// 剩余数量徽章
    private var remainingCountBadge_baseswiftui: some View {
        ZStack {
            Circle().fill(Color.gray.opacity(0.8))
            Text("+\(users_baseswiftui.count - maxDisplay_baseswiftui)")
                .font(.system(size: avatarSize_baseswiftui * 0.35, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: avatarSize_baseswiftui, height: avatarSize_baseswiftui)
    }
}

// MARK: - 头像网格

/// 头像网格视图
/// 用于以网格形式展示多个用户头像
struct AvatarGrid_baseswiftui: View {
    
    /// 用户列表
    let users_baseswiftui: [PrewUserModel_baseswiftui]
    
    /// 网格列数
    var columns_baseswiftui: Int = 4
    
    /// 头像大小
    var avatarSize_baseswiftui: CGFloat = 60
    
    /// 间距
    var spacing_baseswiftui: CGFloat = 16
    
    /// 用户点击回调
    var onUserTapped_baseswiftui: ((PrewUserModel_baseswiftui) -> Void)?
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing_baseswiftui), count: columns_baseswiftui),
            spacing: spacing_baseswiftui
        ) {
            ForEach(users_baseswiftui, id: \.userId_baseswiftui) { user in
                VStack(spacing: 8) {
                    UserAvatarView_baseswiftui(
                        userId_baseswiftui: user.userId_baseswiftui ?? 0,
                        size_baseswiftui: avatarSize_baseswiftui,
                        isClickable_baseswiftui: onUserTapped_baseswiftui != nil,
                        onTapped_baseswiftui: { onUserTapped_baseswiftui?(user) }
                    )
                    
                    Text(user.userName_baseswiftui ?? "Unknown")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
        }
    }
}
