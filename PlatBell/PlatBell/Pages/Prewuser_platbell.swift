import SwiftUI

// MARK: - 用户信息页
// 核心作用：展示其他用户的个人信息、统计数据和帖子列表
// 设计思路：现代化设计 + 动态背景 + 精美卡片 + 用户互动
// 关键功能：用户信息展示、关注/拉黑、帖子列表、举报

/// 用户信息页
struct Prewuser_platbell: View {
    
    /// 用户数据
    let user_platbell: PrewUserModel_platbell
    
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 卡片动画状态
    @State private var cardsVisible_platbell: Bool = false
    
    /// 是否显示举报菜单
    @State private var showReportMenu_platbell: Bool = false
    
    /// 头像呼吸动画
    @State private var avatarBreathing_platbell: Bool = false
    
    /// 是否是当前登录用户
    private var isCurrentUser_platbell: Bool {
        userVM_platbell.isCurrentUser_platbell(userId_platbell: user_platbell.userId_platbell ?? 0)
    }
    
    /// 是否已关注
    private var isFollowing_platbell: Bool {
        userVM_platbell.isFollowing_platbell(user_platbell: user_platbell)
    }
    
    /// 用户帖子列表（性能优化 - 限制初始显示数量）
    private var userPosts_platbell: [TitleModel_platbell] {
        let allUserPosts_platbell = titleVM_platbell.getPosts_platbell().filter { $0.titleUserId_platbell == (user_platbell.userId_platbell ?? 0) }
        // 初始仅显示前15个帖子，减少渲染压力
        return Array(allUserPosts_platbell.prefix(15))
    }
    
    var body: some View {
        ZStack {
            // 多层次渐变背景
            backgroundView_platbell
            
            // 装饰性粒子
            decorativeParticles_platbell
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 顶部安全区
                    Color.clear.frame(height: 100)
                    
                    // 用户信息头部
                    profileHeaderView_platbell
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .opacity(cardsVisible_platbell ? 1 : 0)
                        .offset(y: cardsVisible_platbell ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1), value: cardsVisible_platbell)
                    
                    // 统计信息卡片
                    statsCardsView_platbell
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .opacity(cardsVisible_platbell ? 1 : 0)
                        .offset(y: cardsVisible_platbell ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.2), value: cardsVisible_platbell)
                    
                    // 快捷操作按钮
                    if !isCurrentUser_platbell {
                        quickActionsView_platbell
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .opacity(cardsVisible_platbell ? 1 : 0)
                            .offset(y: cardsVisible_platbell ? 0 : 20)
                            .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.3), value: cardsVisible_platbell)
                    }
                    
                    // 用户帖子区域
                    userPostsSection_platbell
                        .padding(.top, 10)
                        .opacity(cardsVisible_platbell ? 1 : 0)
                        .offset(y: cardsVisible_platbell ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.4), value: cardsVisible_platbell)
                    
                    // 底部占位
                    Spacer(minLength: 100)
                }
            }
            
            // 顶部导航栏
            VStack {
                customNavigationBar_platbell
                    .padding(.top, 50)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(edges: .top)
        .onAppear {
            startAnimations_platbell()
        }
        .background(
            ReportActionSheet_platbell(
                isShowing_platbell: $showReportMenu_platbell,
                isBlockUser_platbell: true,
                onConfirm_platbell: {
                    ReportHelper_platbell.blockUser_platbell(user_platbell: user_platbell) {
                        // 拉黑完成后返回
                        router_platbell.pop_platbell()
                    }
                }
            )
        )
    }
    
    // MARK: - 子视图
    
    /// 多层次渐变背景（性能优化版）
    private var backgroundView_platbell: some View {
        ZStack {
            Color(.systemBackground)
            
            // 简化渐变
            LinearGradient(
                colors: [
                    ThemeColors_platbell.secondaryStart_platbell.opacity(0.15),
                    ThemeColors_platbell.accentGreenStart_platbell.opacity(0.08),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
    
    /// 装饰性粒子（性能优化版）
    private var decorativeParticles_platbell: some View {
        ZStack {
            // 减少到4个粒子
            ForEach(0..<4, id: \.self) { index_platbell in
                Circle()
                    .fill(
                        ThemeColors_platbell.allStartColors_platbell[index_platbell].opacity(0.08)
                    )
                    .frame(
                        width: CGFloat(70 + index_platbell * 20),
                        height: CGFloat(70 + index_platbell * 20)
                    )
                    .offset(
                        x: CGFloat([-100, 120, -90, 110][index_platbell]),
                        y: CGFloat([200, 350, 550, 400][index_platbell])
                    )
                    .blur(radius: 10)
                    .breathing_platbell(
                        isEnabled_platbell: cardsVisible_platbell,
                        duration_platbell: 5.0 + Double(index_platbell) * 0.8,
                        scaleRange_platbell: 0.2
                    )
            }
        }
        .allowsHitTesting(false)
    }
    
    /// 自定义导航栏
    private var customNavigationBar_platbell: some View {
        HStack(spacing: 12) {
            // 返回按钮
            Button(action: {
                router_platbell.pop_platbell()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 42, height: 42)
                        .blur(radius: 10)
                    
                    Circle()
                        .fill(Color(.systemBackground).opacity(0.95))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            
            Spacer()
            
            // 更多按钮
            if !isCurrentUser_platbell {
                Button(action: {
                    showReportMenu_platbell = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 42, height: 42)
                            .blur(radius: 10)
                        
                        Circle()
                            .fill(Color(.systemBackground).opacity(0.95))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                }
            }
        }
    }
    
    /// 用户信息头部
    private var profileHeaderView_platbell: some View {
        VStack(spacing: 0) {
            // 顶部装饰区域（显示用户相册或渐变背景）
            ZStack {
                // 用户相册背景（如果有相册图片则显示）
                if let firstMedia_platbell = user_platbell.userMedia_platbell?.first {
                    Image(firstMedia_platbell)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 85)
                        .clipped()
                    
                    // 半透明黑色渐变遮罩（确保文字可读性）
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.4),
                                    Color.black.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottom
                            )
                        )
                } else {
                    // Fallback: 简化渐变（如果没有相册图片）
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ThemeColors_platbell.secondaryStart_platbell.opacity(0.22),
                                    ThemeColors_platbell.accentGreenStart_platbell.opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottom
                            )
                        )
                    
                    // 高光效果
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            }
            .frame(height: 85)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 28,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 28
                )
            )
            
            // 用户信息区域
            VStack(spacing: 16) {
                // 头像（简化版）
                UserAvatarView_platbell(
                    userId_platbell: user_platbell.userId_platbell ?? 0,
                    size_platbell: 100,
                    isClickable_platbell: false
                )
                .overlay(
                    Circle()
                        .stroke(
                            ThemeColors_platbell.gradient_platbell(at: 2),
                            lineWidth: 3.5
                        )
                )
                .shadow(
                    color: ThemeColors_platbell.secondaryStart_platbell.opacity(0.3),
                    radius: 15,
                    x: 0,
                    y: 8
                )
                .breathing_platbell(
                    isEnabled_platbell: avatarBreathing_platbell,
                    duration_platbell: 4.0,
                    scaleRange_platbell: 0.04
                )
                .padding(.top, -40)
                
                // 用户名（增强版）
                VStack(spacing: 8) {
                    Text(user_platbell.userName_platbell ?? "User")
                        .font(.system(size: 30, weight: .bold))
                        .gradientText_platbell(gradientIndex_platbell: 2)
                }
                
                // 简介（增强版）
                if let introduce_platbell = user_platbell.userIntroduce_platbell, !introduce_platbell.isEmpty {
                    Text(introduce_platbell)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .lineSpacing(2)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6).opacity(0.5))
                        )
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text("No bio yet")
                            .font(.system(size: 15, weight: .medium))
                        
                        Image(systemName: "quote.closing")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.secondary.opacity(0.7))
                    .italic()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
                
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [
                            ThemeColors_platbell.secondaryStart_platbell.opacity(0.4),
                            ThemeColors_platbell.accentGreenStart_platbell.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(
            color: ThemeColors_platbell.secondaryStart_platbell.opacity(0.18),
            radius: 15,
            x: 0,
            y: 8
        )
    }
    
    /// 统计信息卡片
    private var statsCardsView_platbell: some View {
        HStack(spacing: 12) {
            // 帖子数
            UserStatCard_platbell(
                icon_platbell: "doc.text.fill",
                value_platbell: "\(userPosts_platbell.count)",
                label_platbell: "Posts",
                gradientIndex_platbell: 0
            )
            
            // 关注数
            UserStatCard_platbell(
                icon_platbell: "person.2.fill",
                value_platbell: "\(user_platbell.userFollow_platbell ?? 0)",
                label_platbell: "Following",
                gradientIndex_platbell: 1
            )
            
            // 粉丝数
            UserStatCard_platbell(
                icon_platbell: "heart.fill",
                value_platbell: "\(user_platbell.userFans_platbell ?? 0)",
                label_platbell: "Fans",
                gradientIndex_platbell: 2
            )
        }
    }
    
    /// 快捷操作按钮（增强版）
    private var quickActionsView_platbell: some View {
        HStack(spacing: 12) {
            // 关注/取消关注按钮
            Button(action: {
                userVM_platbell.followUser_platbell(user_platbell: user_platbell)
                
                // 触觉反馈
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(isFollowing_platbell ? 0 : 0.25))
                            .frame(width: 26, height: 26)
                        
                        Image(systemName: isFollowing_platbell ? "checkmark" : "person.badge.plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(isFollowing_platbell ? .secondary : .white)
                    }
                    
                    Text(isFollowing_platbell ? "Followed" : "Follow")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundColor(isFollowing_platbell ? .secondary : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    ZStack {
                        if isFollowing_platbell {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray5))
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ThemeColors_platbell.gradient_platbell(at: 2))
                            
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isFollowing_platbell
                                ? Color.gray.opacity(0.2)
                                : Color.clear,
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: isFollowing_platbell ? Color.clear : ThemeColors_platbell.secondaryStart_platbell.opacity(0.3),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            
            // 私信按钮（增强版）
            Button(action: {
                router_platbell.toUserChat_platbell(user_platbell: user_platbell)
            }) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(ThemeColors_platbell.accentBlueStart_platbell.opacity(0.2))
                            .frame(width: 26, height: 26)
                        
                        Image(systemName: "message.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ThemeColors_platbell.accentBlueStart_platbell)
                    }
                    
                    Text("Message")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundColor(ThemeColors_platbell.accentBlueStart_platbell)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.7),
                                        ThemeColors_platbell.accentBlueStart_platbell.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            ThemeColors_platbell.accentBlueStart_platbell.opacity(0.4),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: ThemeColors_platbell.accentBlueStart_platbell.opacity(0.18),
                    radius: 10,
                    x: 0,
                    y: 5
                )
            }
        }
    }
    
    /// 用户帖子区域
    private var userPostsSection_platbell: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题栏
            HStack(spacing: 12) {
                // 装饰性图标
                ZStack {
                    Circle()
                        .fill(ThemeColors_platbell.gradient_platbell(at: 1).opacity(0.18))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 1))
                }
                
                Text("Posts")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 帖子数量徽章
                HStack(spacing: 6) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 11, weight: .bold))
                    
                    Text("\(userPosts_platbell.count)")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(ThemeColors_platbell.gradient_platbell(at: 1))
                )
                .shadow(
                    color: ThemeColors_platbell.secondaryStart_platbell.opacity(0.35),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .padding(.horizontal, 20)
            
            // 帖子列表
            if userPosts_platbell.isEmpty {
                emptyPostsView_platbell
                    .padding(.top, 12)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(userPosts_platbell.indices, id: \.self) { index_platbell in
                        let post_platbell = userPosts_platbell[index_platbell]
                        
                        PostCard_platbell(
                            post_platbell: post_platbell,
                            gradientIndex_platbell: index_platbell % ThemeColors_platbell.allGradients_platbell.count,
                            isVisible_platbell: cardsVisible_platbell,
                            animationDelay_platbell: 0.5 + Double(index_platbell) * 0.08
                        )
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.top, 4)
                .padding(.horizontal, 16)
            }
        }
    }
    
    /// 空帖子状态视图
    private var emptyPostsView_platbell: some View {
        VStack(spacing: 16) {
            // 图标
            ZStack {
                Circle()
                    .fill(
                        ThemeColors_platbell.gradient_platbell(at: 1).opacity(0.15)
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "doc.richtext")
                    .font(.system(size: 36))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 1))
            }
            
            // 文本
            VStack(spacing: 8) {
                Text("No posts yet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("This user hasn't shared anything")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    Color.gray.opacity(0.15),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    // MARK: - 事件处理
    
    /// 启动动画（性能优化版）
    private func startAnimations_platbell() {
        // 立即显示内容，减少等待
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                cardsVisible_platbell = true
            }
        }
        
        // 延迟启动头像动画，减少初始负载
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            avatarBreathing_platbell = true
        }
    }
}

// MARK: - 用户统计卡片组件

/// 用户统计卡片组件（增强版）
struct UserStatCard_platbell: View {
    
    let icon_platbell: String
    let value_platbell: String
    let label_platbell: String
    let gradientIndex_platbell: Int
    
    @State private var isAnimating_platbell: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            // 图标（简化版）
            ZStack {
                // 背景圆
                Circle()
                    .fill(
                        ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.2)
                    )
                    .frame(width: 54, height: 54)
                
                // 图标
                Image(systemName: icon_platbell)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
            }
            .scaleEffect(isAnimating_platbell ? 1.0 : 0.8)
            .opacity(isAnimating_platbell ? 1.0 : 0.0)
            
            // 数值
            Text(value_platbell)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
            
            // 标签
            Text(label_platbell)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.35),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.18),
            radius: 10,
            x: 0,
            y: 5
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2 + Double(gradientIndex_platbell) * 0.1)) {
                isAnimating_platbell = true
            }
        }
    }
}
