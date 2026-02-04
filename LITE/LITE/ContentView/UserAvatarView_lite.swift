import SwiftUI

// MARK: - 用户头像组件

/// 头像颜色配置
private let avatarColors_lite: [Color] = [
    Color(hex: "667eea"), Color(hex: "f093fb"), Color(hex: "63B3ED"),
    Color(hex: "F6AD55"), Color(hex: "FC8181")
]

/// 根据用户ID获取头像颜色
private func avatarColor_lite(for userId_lite: Int) -> Color {
    avatarColors_lite[userId_lite % avatarColors_lite.count]
}

// MARK: - 用户头像视图

/// 用户头像视图
/// 根据用户ID自动判断是登录用户还是预制用户，显示对应头像
struct UserAvatarView_lite: View {
    
    /// 观察用户状态变化
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    
    /// 用户ID
    let userId_lite: Int
    
    /// 头像大小
    var size_lite: CGFloat = 50
    
    /// 是否可点击
    var isClickable_lite: Bool = false
    
    /// 点击回调
    var onTapped_lite: (() -> Void)?
    
    /// 是否显示在线状态指示器（仅对当前登录用户生效）
    var showOnlineIndicator_lite: Bool = false
    
    /// 是否显示编辑按钮（仅对当前登录用户生效）
    var showEditButton_lite: Bool = false
    
    /// 是否是当前登录用户
    private var isCurrentUser_lite: Bool {
        userVM_lite.isCurrentUser_lite(userId_lite: userId_lite)
    }
    
    /// 当前用户信息（根据是否是登录用户选择数据源）
    private var currentUserInfo_lite: (avatarPath: String?, userName: String?) {
        if isCurrentUser_lite {
            // 登录用户
            return (userVM_lite.loggedUser_lite?.userHead_lite,
                    userVM_lite.loggedUser_lite?.userName_lite)
        } else {
            // 预制用户
            let prewUser_lite = userVM_lite.getUserById_lite(userId_lite: userId_lite)
            return (prewUser_lite.userHead_lite,
                    prewUser_lite.userName_lite)
        }
    }
    
    var body: some View {
        Button(action: handleTap_lite) {
            ZStack(alignment: .bottomTrailing) {
                // 主头像
                avatarContent_lite
                    .frame(width: size_lite, height: size_lite)
                    .clipShape(Circle())
                
                // 在线状态指示器（仅当前登录用户且已登录时显示）
                if showOnlineIndicator_lite && isCurrentUser_lite && userVM_lite.isLoggedIn_lite {
                    statusIndicator_lite(color: Color(hex: "48BB78"))
                }
                
                // 编辑按钮（仅当前登录用户时显示）
                if showEditButton_lite && isCurrentUser_lite {
                    editButton_lite
                }
            }
        }
        .disabled(!isClickable_lite)
        .buttonStyle(.plain)
    }
    
    /// 头像内容视图
    @ViewBuilder
    private var avatarContent_lite: some View {
        let info_lite = currentUserInfo_lite
        
        if let path_lite = info_lite.avatarPath, !path_lite.isEmpty {
            // 显示真实头像
            MediaDisplayView_lite(
                mediaPath_lite: path_lite,
                isVideo_lite: false,
                cornerRadius_lite: size_lite / 2
            )
        } else {
            // 显示默认头像
            defaultAvatar_lite(userName: info_lite.userName)
        }
    }
    
    /// 默认头像视图
    private func defaultAvatar_lite(userName: String?) -> some View {
        ZStack {
            Circle().fill(avatarColor_lite(for: userId_lite))
            
            if let firstLetter_lite = userName?.prefix(1).uppercased() {
                Text(firstLetter_lite)
                    .font(.system(size: size_lite * 0.4, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size_lite * 0.5))
                    .foregroundColor(.white)
            }
        }
    }
    
    /// 在线状态指示器
    private func statusIndicator_lite(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: size_lite * 0.28, height: size_lite * 0.28)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .offset(x: 2, y: 2)
    }
    
    /// 编辑按钮
    private var editButton_lite: some View {
        Image(systemName: "pencil.circle.fill")
            .font(.system(size: size_lite * 0.32))
            .foregroundColor(.blue)
            .background(Circle().fill(Color.white))
            .offset(x: 2, y: 2)
    }
    
    /// 处理点击事件
    private func handleTap_lite() {
        if isClickable_lite {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTapped_lite?()
        }
    }
}

// MARK: - 头像组（多个头像叠加）

/// 头像组视图
/// 用于显示多个用户头像的叠加效果
struct AvatarGroup_lite: View {
    
    /// 用户列表
    let users_lite: [PrewUserModel_lite]
    
    /// 最多显示的头像数量
    var maxDisplay_lite: Int = 3
    
    /// 头像大小
    var avatarSize_lite: CGFloat = 40
    
    /// 头像重叠偏移量
    var overlapOffset_lite: CGFloat = -10
    
    var body: some View {
        HStack(spacing: overlapOffset_lite) {
            ForEach(Array(users_lite.prefix(maxDisplay_lite).enumerated()), id: \.offset) { index, user in
                UserAvatarView_lite(
                    userId_lite: user.userId_lite ?? 0,
                    size_lite: avatarSize_lite
                )
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
                .zIndex(Double(maxDisplay_lite - index))
            }
            
            // 显示剩余用户数量徽章
            if users_lite.count > maxDisplay_lite {
                remainingCountBadge_lite
            }
        }
    }
    
    /// 剩余数量徽章
    private var remainingCountBadge_lite: some View {
        ZStack {
            Circle().fill(Color.gray.opacity(0.8))
            Text("+\(users_lite.count - maxDisplay_lite)")
                .font(.system(size: avatarSize_lite * 0.35, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: avatarSize_lite, height: avatarSize_lite)
    }
}

// MARK: - 头像网格

/// 头像网格视图
/// 用于以网格形式展示多个用户头像
struct AvatarGrid_lite: View {
    
    /// 用户列表
    let users_lite: [PrewUserModel_lite]
    
    /// 网格列数
    var columns_lite: Int = 4
    
    /// 头像大小
    var avatarSize_lite: CGFloat = 60
    
    /// 间距
    var spacing_lite: CGFloat = 16
    
    /// 用户点击回调
    var onUserTapped_lite: ((PrewUserModel_lite) -> Void)?
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing_lite), count: columns_lite),
            spacing: spacing_lite
        ) {
            ForEach(users_lite, id: \.userId_lite) { user in
                VStack(spacing: 8) {
                    UserAvatarView_lite(
                        userId_lite: user.userId_lite ?? 0,
                        size_lite: avatarSize_lite,
                        isClickable_lite: onUserTapped_lite != nil,
                        onTapped_lite: { onUserTapped_lite?(user) }
                    )
                    
                    Text(user.userName_lite ?? "Unknown")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
        }
    }
}
