import SwiftUI

// MARK: - 用户头像组件

/// 头像颜色配置
private let avatarColors_blisslink: [Color] = [
    Color(hex: "667eea"), Color(hex: "f093fb"), Color(hex: "63B3ED"),
    Color(hex: "F6AD55"), Color(hex: "FC8181")
]

/// 根据用户ID获取头像颜色
private func avatarColor_blisslink(for userId_blisslink: Int) -> Color {
    avatarColors_blisslink[userId_blisslink % avatarColors_blisslink.count]
}

// MARK: - 用户头像视图

/// 用户头像视图
struct UserAvatarView_blisslink: View {
    
    let userId_blisslink: Int
    let avatarPath_blisslink: String?
    let userName_blisslink: String?
    var size_blisslink: CGFloat = 50
    var showBorder_blisslink: Bool = false
    var borderColor_blisslink: Color = .white
    var borderWidth_blisslink: CGFloat = 2
    var isClickable_blisslink: Bool = false
    var onTapped_blisslink: (() -> Void)?
    
    var body: some View {
        avatarContent_blisslink
            .frame(width: size_blisslink, height: size_blisslink)
            .clipShape(Circle())
            .overlay(
                showBorder_blisslink ?
                Circle().stroke(borderColor_blisslink, lineWidth: borderWidth_blisslink) : nil
            )
            .contentShape(Circle())  // 定义点击区域为圆形
            .onTapGesture {
                if isClickable_blisslink {
                    onTapped_blisslink?()
                }
            }
    }
    
    @ViewBuilder
    private var avatarContent_blisslink: some View {
        if let path = avatarPath_blisslink, !path.isEmpty {
            MediaDisplayView_blisslink(
                mediaPath_blisslink: path,
                isVideo_blisslink: false,
                cornerRadius_blisslink: size_blisslink / 2,
                isClickable_blisslink: false  // ← 关键：禁用 MediaDisplayView 的点击
            )
        } else {
            defaultAvatar_blisslink
        }
    }
    
    private var defaultAvatar_blisslink: some View {
        ZStack {
            Circle().fill(avatarColor_blisslink(for: userId_blisslink))
            
            if let firstLetter = userName_blisslink?.prefix(1).uppercased() {
                Text(firstLetter)
                    .font(.system(size: size_blisslink * 0.4, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size_blisslink * 0.5))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - 当前登录用户头像视图

/// 当前登录用户头像视图
struct CurrentUserAvatarView_blisslink: View {
    
    @ObservedObject var userVM_blisslink = UserViewModel_blisslink.shared_blisslink
    
    var size_blisslink: CGFloat = 50
    var showOnlineIndicator_blisslink: Bool = true
    var showEditButton_blisslink: Bool = false
    var onTapped_blisslink: (() -> Void)?
    
    var body: some View {
        Button(action: handleTap_blisslink) {
            ZStack(alignment: .bottomTrailing) {
                // 主头像
                if let user = userVM_blisslink.loggedUser_blisslink {
                    UserAvatarView_blisslink(
                        userId_blisslink: user.userId_blisslink ?? 0,
                        avatarPath_blisslink: user.userHead_blisslink,
                        userName_blisslink: user.userName_blisslink,
                        size_blisslink: size_blisslink
                    )
                } else {
                    guestAvatar_blisslink
                }
                
                // 状态指示器
                if showOnlineIndicator_blisslink && userVM_blisslink.isLoggedIn_blisslink {
                    statusIndicator_blisslink(color: Color(hex: "48BB78"))
                }
                
                // 编辑按钮
                if showEditButton_blisslink {
                    editButton_blisslink
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var guestAvatar_blisslink: some View {
        ZStack {
            Circle().fill(Color.gray)
            Image(systemName: "person.fill")
                .font(.system(size: size_blisslink * 0.5))
                .foregroundColor(.white)
        }
        .frame(width: size_blisslink, height: size_blisslink)
    }
    
    private func statusIndicator_blisslink(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: size_blisslink * 0.28, height: size_blisslink * 0.28)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .offset(x: 2, y: 2)
    }
    
    private var editButton_blisslink: some View {
        Image(systemName: "pencil.circle.fill")
            .font(.system(size: size_blisslink * 0.32))
            .foregroundColor(.blue)
            .background(Circle().fill(Color.white))
            .offset(x: 2, y: 2)
    }
    
    private func handleTap_blisslink() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onTapped_blisslink?()
    }
}

// MARK: - 头像组（多个头像叠加）

/// 头像组视图
struct AvatarGroup_blisslink: View {
    
    let users_blisslink: [PrewUserModel_blisslink]
    var maxDisplay_blisslink: Int = 3
    var avatarSize_blisslink: CGFloat = 40
    var overlapOffset_blisslink: CGFloat = -10
    
    var body: some View {
        HStack(spacing: overlapOffset_blisslink) {
            ForEach(Array(users_blisslink.prefix(maxDisplay_blisslink).enumerated()), id: \.offset) { index, user in
                UserAvatarView_blisslink(
                    userId_blisslink: user.userId_blisslink ?? 0,
                    avatarPath_blisslink: user.userHead_blisslink,
                    userName_blisslink: user.userName_blisslink,
                    size_blisslink: avatarSize_blisslink,
                    showBorder_blisslink: true
                )
                .zIndex(Double(maxDisplay_blisslink - index))
            }
            
            if users_blisslink.count > maxDisplay_blisslink {
                remainingCountBadge_blisslink
            }
        }
    }
    
    private var remainingCountBadge_blisslink: some View {
        ZStack {
            Circle().fill(Color.gray.opacity(0.8))
            Text("+\(users_blisslink.count - maxDisplay_blisslink)")
                .font(.system(size: avatarSize_blisslink * 0.35, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: avatarSize_blisslink, height: avatarSize_blisslink)
    }
}

// MARK: - 头像网格

/// 头像网格视图
struct AvatarGrid_blisslink: View {
    
    let users_blisslink: [PrewUserModel_blisslink]
    var columns_blisslink: Int = 4
    var avatarSize_blisslink: CGFloat = 60
    var spacing_blisslink: CGFloat = 16
    var onUserTapped_blisslink: ((PrewUserModel_blisslink) -> Void)?
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing_blisslink), count: columns_blisslink),
            spacing: spacing_blisslink
        ) {
            ForEach(users_blisslink, id: \.userId_blisslink) { user in
                VStack(spacing: 8) {
                    UserAvatarView_blisslink(
                        userId_blisslink: user.userId_blisslink ?? 0,
                        avatarPath_blisslink: user.userHead_blisslink,
                        userName_blisslink: user.userName_blisslink,
                        size_blisslink: avatarSize_blisslink,
                        isClickable_blisslink: onUserTapped_blisslink != nil,
                        onTapped_blisslink: { onUserTapped_blisslink?(user) }
                    )
                    
                    Text(user.userName_blisslink ?? "Unknown")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
        }
    }
}
