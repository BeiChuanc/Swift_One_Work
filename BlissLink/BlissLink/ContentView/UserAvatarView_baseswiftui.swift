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
struct UserAvatarView_baseswiftui: View {
    
    let userId_baseswiftui: Int
    let avatarPath_baseswiftui: String?
    let userName_baseswiftui: String?
    var size_baseswiftui: CGFloat = 50
    var showBorder_baseswiftui: Bool = false
    var borderColor_baseswiftui: Color = .white
    var borderWidth_baseswiftui: CGFloat = 2
    var isClickable_baseswiftui: Bool = false
    var onTapped_baseswiftui: (() -> Void)?
    
    var body: some View {
        avatarContent_baseswiftui
            .frame(width: size_baseswiftui, height: size_baseswiftui)
            .clipShape(Circle())
            .overlay(
                showBorder_baseswiftui ?
                Circle().stroke(borderColor_baseswiftui, lineWidth: borderWidth_baseswiftui) : nil
            )
            .contentShape(Circle())  // 定义点击区域为圆形
            .onTapGesture {
                if isClickable_baseswiftui {
                    onTapped_baseswiftui?()
                }
            }
    }
    
    @ViewBuilder
    private var avatarContent_baseswiftui: some View {
        if let path = avatarPath_baseswiftui, !path.isEmpty {
            MediaDisplayView_baseswiftui(
                mediaPath_baseswiftui: path,
                isVideo_baseswiftui: false,
                cornerRadius_baseswiftui: size_baseswiftui / 2,
                isClickable_baseswiftui: false  // ← 关键：禁用 MediaDisplayView 的点击
            )
        } else {
            defaultAvatar_baseswiftui
        }
    }
    
    private var defaultAvatar_baseswiftui: some View {
        ZStack {
            Circle().fill(avatarColor_baseswiftui(for: userId_baseswiftui))
            
            if let firstLetter = userName_baseswiftui?.prefix(1).uppercased() {
                Text(firstLetter)
                    .font(.system(size: size_baseswiftui * 0.4, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size_baseswiftui * 0.5))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - 当前登录用户头像视图

/// 当前登录用户头像视图
struct CurrentUserAvatarView_baseswiftui: View {
    
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    
    var size_baseswiftui: CGFloat = 50
    var showOnlineIndicator_baseswiftui: Bool = true
    var showEditButton_baseswiftui: Bool = false
    var onTapped_baseswiftui: (() -> Void)?
    
    var body: some View {
        Button(action: handleTap_baseswiftui) {
            ZStack(alignment: .bottomTrailing) {
                // 主头像
                if let user = userVM_baseswiftui.loggedUser_baseswiftui {
                    UserAvatarView_baseswiftui(
                        userId_baseswiftui: user.userId_baseswiftui ?? 0,
                        avatarPath_baseswiftui: user.userHead_baseswiftui,
                        userName_baseswiftui: user.userName_baseswiftui,
                        size_baseswiftui: size_baseswiftui
                    )
                } else {
                    guestAvatar_baseswiftui
                }
                
                // 状态指示器
                if showOnlineIndicator_baseswiftui && userVM_baseswiftui.isLoggedIn_baseswiftui {
                    statusIndicator_baseswiftui(color: Color(hex: "48BB78"))
                }
                
                // 编辑按钮
                if showEditButton_baseswiftui {
                    editButton_baseswiftui
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var guestAvatar_baseswiftui: some View {
        ZStack {
            Circle().fill(Color.gray)
            Image(systemName: "person.fill")
                .font(.system(size: size_baseswiftui * 0.5))
                .foregroundColor(.white)
        }
        .frame(width: size_baseswiftui, height: size_baseswiftui)
    }
    
    private func statusIndicator_baseswiftui(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: size_baseswiftui * 0.28, height: size_baseswiftui * 0.28)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .offset(x: 2, y: 2)
    }
    
    private var editButton_baseswiftui: some View {
        Image(systemName: "pencil.circle.fill")
            .font(.system(size: size_baseswiftui * 0.32))
            .foregroundColor(.blue)
            .background(Circle().fill(Color.white))
            .offset(x: 2, y: 2)
    }
    
    private func handleTap_baseswiftui() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onTapped_baseswiftui?()
    }
}

// MARK: - 头像组（多个头像叠加）

/// 头像组视图
struct AvatarGroup_baseswiftui: View {
    
    let users_baseswiftui: [PrewUserModel_baseswiftui]
    var maxDisplay_baseswiftui: Int = 3
    var avatarSize_baseswiftui: CGFloat = 40
    var overlapOffset_baseswiftui: CGFloat = -10
    
    var body: some View {
        HStack(spacing: overlapOffset_baseswiftui) {
            ForEach(Array(users_baseswiftui.prefix(maxDisplay_baseswiftui).enumerated()), id: \.offset) { index, user in
                UserAvatarView_baseswiftui(
                    userId_baseswiftui: user.userId_baseswiftui ?? 0,
                    avatarPath_baseswiftui: user.userHead_baseswiftui,
                    userName_baseswiftui: user.userName_baseswiftui,
                    size_baseswiftui: avatarSize_baseswiftui,
                    showBorder_baseswiftui: true
                )
                .zIndex(Double(maxDisplay_baseswiftui - index))
            }
            
            if users_baseswiftui.count > maxDisplay_baseswiftui {
                remainingCountBadge_baseswiftui
            }
        }
    }
    
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
struct AvatarGrid_baseswiftui: View {
    
    let users_baseswiftui: [PrewUserModel_baseswiftui]
    var columns_baseswiftui: Int = 4
    var avatarSize_baseswiftui: CGFloat = 60
    var spacing_baseswiftui: CGFloat = 16
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
                        avatarPath_baseswiftui: user.userHead_baseswiftui,
                        userName_baseswiftui: user.userName_baseswiftui,
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
