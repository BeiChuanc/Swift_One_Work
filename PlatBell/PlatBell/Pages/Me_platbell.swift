import SwiftUI

// MARK: - 个人中心页
// 核心作用：展示当前用户的个人信息、统计数据和快捷操作
// 设计思路：现代化毛玻璃设计 + 动态统计卡片 + 精致帖子列表 + 流畅动画
// 关键功能：个人信息展示、帖子列表、编辑资料、设置
// UI优化：多层次渐变、呼吸动画、微交互反馈、视觉层次优化

/// 个人中心页
struct Me_platbell: View {
    
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    
    /// 卡片可见状态
    @State private var cardsVisible_platbell = false
    
    /// 头像呼吸动画状态
    @State private var avatarBreathing_platbell = false
    
    /// 当前用户
    private var currentUser_platbell: LoginUserModel_platbell {
        userVM_platbell.getCurrentUser_platbell()
    }
    
    /// 是否已登录
    private var isLoggedIn_platbell: Bool {
        userVM_platbell.isLoggedIn_platbell
    }
    
    /// 用户帖子列表（限制初始显示数量以优化性能）
    private var userPosts_platbell: [TitleModel_platbell] {
        let allPosts_platbell = currentUser_platbell.userPosts_platbell
        // 初始仅显示前20个帖子，减少渲染压力
        return Array(allPosts_platbell.prefix(20))
    }
    
    var body: some View {
        ZStack {
            // 多层次渐变背景
            backgroundView_platbell
            
            // 动态装饰性粒子
            decorativeParticles_platbell
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 顶部安全区占位
                    Color.clear.frame(height: 8)
                    
                    // 个人信息头部 - 增强版
                    profileHeaderView_platbell
                        .padding(.top, 12)
                        .padding(.horizontal, 20)
                        .opacity(cardsVisible_platbell ? 1 : 0)
                        .offset(y: cardsVisible_platbell ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1), value: cardsVisible_platbell)
                    
                    // 统计信息卡片 - 增强动画
                    statsCardsView_platbell
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .opacity(cardsVisible_platbell ? 1 : 0)
                        .offset(y: cardsVisible_platbell ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.2), value: cardsVisible_platbell)
                    
                    // 快捷操作按钮 - 增强动画
                    quickActionsView_platbell
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .opacity(cardsVisible_platbell ? 1 : 0)
                        .offset(y: cardsVisible_platbell ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.3), value: cardsVisible_platbell)
                    
                    // 我的帖子区域 - 增强动画
                    myPostsSection_platbell
                        .padding(.top, 24)
                        .opacity(cardsVisible_platbell ? 1 : 0)
                        .offset(y: cardsVisible_platbell ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.4), value: cardsVisible_platbell)
                    
                    // 底部占位
                    Spacer(minLength: 120)
                }
            }
            .refreshable {
                await performRefresh_platbell()
            }
        }
        .onAppear {
            startAnimations_platbell()
        }
    }
    
    // MARK: - 子视图
    
    /// 多层次渐变背景（性能优化版）
    private var backgroundView_platbell: some View {
        ZStack {
            // 主背景
            Color(.systemBackground)
            
            // 简化渐变 - 仅保留顶部渐变
            LinearGradient(
                colors: [
                    ThemeColors_platbell.warmStart_platbell.opacity(0.12),
                    ThemeColors_platbell.primaryStart_platbell.opacity(0.06),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
    
    /// 动态装饰性粒子（优化版 - 减少粒子数量）
    @ViewBuilder
    private var decorativeParticles_platbell: some View {
        ZStack {
            // 仅保留4个轻量级粒子
            ForEach(0..<4, id: \.self) { index_platbell in
                Circle()
                    .fill(
                        ThemeColors_platbell.allStartColors_platbell[index_platbell].opacity(0.06)
                    )
                    .frame(
                        width: CGFloat(60 + index_platbell * 20),
                        height: CGFloat(60 + index_platbell * 20)
                    )
                    .offset(
                        x: CGFloat([-100, 120, -90, 110][index_platbell]),
                        y: CGFloat([150, 300, 500, 250][index_platbell])
                    )
                    .blur(radius: 8)
                    .breathing_platbell(
                        isEnabled_platbell: cardsVisible_platbell,
                        duration_platbell: 5.0 + Double(index_platbell) * 0.8,
                        scaleRange_platbell: 0.2
                    )
            }
        }
        .allowsHitTesting(false)
    }
    
    /// 个人信息头部（增强版）
    private var profileHeaderView_platbell: some View {
        VStack(spacing: 0) {
            // 装饰性顶部渐变条
            ZStack {
                // 主渐变
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ThemeColors_platbell.warmStart_platbell.opacity(0.2),
                                ThemeColors_platbell.primaryStart_platbell.opacity(0.12),
                                ThemeColors_platbell.secondaryStart_platbell.opacity(0.08),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottom
                        )
                    )
                
                // 高光叠加
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
            .frame(height: 70)
            
            // 用户头像和基本信息
            HStack(spacing: 18) {
                // 使用UserAvatarView组件显示头像
                UserAvatarView_platbell(
                    userId_platbell: currentUser_platbell.userId_platbell ?? 0,
                    size_platbell: 80,
                    isClickable_platbell: true,
                    onTapped_platbell: {
                        // 点击头像跳转到编辑资料页
                        router_platbell.navigate_platbell(to: .EditInfo_platbellui)
                    },
                    showOnlineIndicator_platbell: isLoggedIn_platbell
                )
                .overlay(
                    Circle()
                        .stroke(
                            ThemeColors_platbell.gradient_platbell(at: 4),
                            lineWidth: 3
                        )
                        .opacity(0.6)
                )
                .shadow(
                    color: ThemeColors_platbell.warmStart_platbell.opacity(0.3),
                    radius: 12,
                    x: 0,
                    y: 6
                )
                .breathing_platbell(isEnabled_platbell: avatarBreathing_platbell, duration_platbell: 4.0, scaleRange_platbell: 0.04)
                
                // 用户信息
                VStack(alignment: .leading, spacing: 8) {
                    // 用户名
                    Text(currentUser_platbell.userName_platbell ?? "Guest")
                        .font(.system(size: 26, weight: .bold))
                        .gradientText_platbell(gradientIndex_platbell: 4)
                    
                    // 简介
                    Text(currentUser_platbell.userIntroduce_platbell ?? "Nothing yet.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.9))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .padding(.top, -40) // 向上偏移，与装饰渐变重叠
        }
        .background(
            ZStack {
                // 主背景
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
                
                // 毛玻璃效果叠加
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
                            ThemeColors_platbell.warmStart_platbell.opacity(0.4),
                            ThemeColors_platbell.primaryStart_platbell.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(
            color: ThemeColors_platbell.warmStart_platbell.opacity(0.15),
            radius: 15,
            x: 0,
            y: 8
        )
    }
    
    /// 统计信息卡片（增强版）
    private var statsCardsView_platbell: some View {
        HStack(spacing: 12) {
            // 帖子数
            EnhancedStatCard_platbell(
                icon_platbell: "doc.text.fill",
                value_platbell: "\(userPosts_platbell.count)",
                label_platbell: "Posts",
                gradientIndex_platbell: 0,
                animationDelay_platbell: 0.1
            )
            
            // 关注数
            EnhancedStatCard_platbell(
                icon_platbell: "person.2.fill",
                value_platbell: "\(currentUser_platbell.userFollow_platbell.count)",
                label_platbell: "Following",
                gradientIndex_platbell: 1,
                animationDelay_platbell: 0.15
            )
            
            // 点赞数
            EnhancedStatCard_platbell(
                icon_platbell: "heart.fill",
                value_platbell: "\(currentUser_platbell.userLike_platbell.count)",
                label_platbell: "Likes",
                gradientIndex_platbell: 2,
                animationDelay_platbell: 0.2
            )
        }
    }
    
    /// 快捷操作按钮（增强版）
    private var quickActionsView_platbell: some View {
        VStack(spacing: 14) {
            // 标题（简化版）
            HStack(spacing: 10) {
                // 装饰图标
                ZStack {
                    // 背景圆
                    Circle()
                        .fill(ThemeColors_platbell.gradient_platbell(at: 3).opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 3))
                }
                
                Text("Quick Actions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // 按钮区域
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    EnhancedActionButton_platbell(
                        icon_platbell: "person.crop.circle.badge.checkmark",
                        title_platbell: "Edit Profile",
                        gradientIndex_platbell: 0
                    ) {
                        router_platbell.navigate_platbell(to: .EditInfo_platbellui)
                    }
                    
                    EnhancedActionButton_platbell(
                        icon_platbell: "gearshape.fill",
                        title_platbell: "Settings",
                        gradientIndex_platbell: 4
                    ) {
                        router_platbell.navigate_platbell(to: .settings_platbell)
                    }
                }
            }
        }
    }
    
    /// 我的帖子区域（增强版）
    private var myPostsSection_platbell: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题栏
            HStack(spacing: 12) {
                // 装饰性图标（简化版）
                ZStack {
                    // 背景圆
                    Circle()
                        .fill(ThemeColors_platbell.gradient_platbell(at: 1).opacity(0.18))
                        .frame(width: 36, height: 36)
                    
                    // 图标
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 1))
                }
                
                Text("My Posts")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 帖子数量徽章（增强版）
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
                    ZStack {
                        Capsule()
                            .fill(ThemeColors_platbell.gradient_platbell(at: 1))
                        
                        Capsule()
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
                )
                .shadow(
                    color: ThemeColors_platbell.secondaryStart_platbell.opacity(0.3),
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
    
    /// 空帖子状态视图（增强版）
    private var emptyPostsView_platbell: some View {
        VStack(spacing: 0) {
            // 顶部装饰区（简化版）
            ZStack {
                // 仅保留2层波纹装饰
                ForEach(0..<2, id: \.self) { index_platbell in
                    Circle()
                        .stroke(
                            ThemeColors_platbell.gradient_platbell(at: 1).opacity(0.15 - Double(index_platbell) * 0.05),
                            lineWidth: 2
                        )
                        .frame(
                            width: CGFloat(100 + index_platbell * 30),
                            height: CGFloat(100 + index_platbell * 30)
                        )
                        .breathing_platbell(
                            isEnabled_platbell: cardsVisible_platbell,
                            duration_platbell: 4.0 + Double(index_platbell) * 0.8,
                            scaleRange_platbell: 0.12
                        )
                }
                
                // 主图标组（简化版）
                ZStack {
                    // 图标背景
                    Circle()
                        .fill(
                            ThemeColors_platbell.secondaryStart_platbell.opacity(0.2)
                        )
                        .frame(width: 96, height: 96)
                    
                    // 图标
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 1))
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 28)
            
            // 文本内容
            VStack(spacing: 10) {
                Text("No posts yet")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Share your creativity with the world")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                // 主背景
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                
                // 顶部装饰渐变
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                ThemeColors_platbell.secondaryStart_platbell.opacity(0.10),
                                ThemeColors_platbell.primaryStart_platbell.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                
                // 底部装饰渐变
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                ThemeColors_platbell.accentGreenStart_platbell.opacity(0.06)
                            ],
                            startPoint: .center,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // 高光效果
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    ThemeColors_platbell.secondaryStart_platbell.opacity(0.25),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: ThemeColors_platbell.secondaryStart_platbell.opacity(0.12),
            radius: 12,
            x: 0,
            y: 6
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - 事件处理
    
    /// 启动动画序列（优化版 - 延迟启动减少初始负载）
    private func startAnimations_platbell() {
        // 立即显示卡片，减少延迟
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                cardsVisible_platbell = true
            }
        }
        
        // 延迟启动头像呼吸动画，减少初始渲染压力
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            avatarBreathing_platbell = true
        }
    }
    
    /// 执行刷新
    private func performRefresh_platbell() async {
        // 触觉反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
        
        // 模拟网络请求延迟
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        // 刷新数据
        titleVM_platbell.initPosts_platbell()
        
        // 成功反馈
        let successFeedback_platbell = UINotificationFeedbackGenerator()
        successFeedback_platbell.notificationOccurred(.success)
    }
}

// MARK: - 状态标签组件

/// 状态标签组件（增强版）
struct StatusBadge_platbell: View {
    let icon_platbell: String
    let text_platbell: String
    let color_platbell: Color
    
    var body: some View {
        HStack(spacing: 5) {
            // 图标
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 16, height: 16)
                
                Image(systemName: icon_platbell)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text_platbell)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            ZStack {
                // 主背景
                Capsule()
                    .fill(color_platbell)
                
                // 顶部高光
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .shadow(
            color: color_platbell.opacity(0.45),
            radius: 5,
            x: 0,
            y: 2
        )
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 3,
            x: 0,
            y: 1
        )
    }
}

// MARK: - 增强版统计卡片组件

/// 增强版统计卡片组件
struct EnhancedStatCard_platbell: View {
    let icon_platbell: String
    let value_platbell: String
    let label_platbell: String
    let gradientIndex_platbell: Int
    let animationDelay_platbell: Double
    
    @State private var isAnimating_platbell = false
    
    var body: some View {
        VStack(spacing: 12) {
            // 图标组（简化版）
            ZStack {
                // 背景圆
                Circle()
                    .fill(
                        ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.2)
                    )
                    .frame(width: 50, height: 50)
                
                // 图标
                Image(systemName: icon_platbell)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
            }
            .scaleEffect(isAnimating_platbell ? 1.0 : 0.8)
            .opacity(isAnimating_platbell ? 1.0 : 0.0)
            
            // 数值和标签
            VStack(spacing: 4) {
                Text(value_platbell)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
                
                Text(label_platbell)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.9))
            }
            .offset(y: isAnimating_platbell ? 0 : 10)
            .opacity(isAnimating_platbell ? 1.0 : 0.0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            ZStack {
                // 主背景
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                
                // 顶部高光
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
                
                // 底部装饰渐变
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.06)
                            ],
                            startPoint: .center,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.3),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(animationDelay_platbell)) {
                isAnimating_platbell = true
            }
        }
    }
}

// MARK: - 增强版快捷操作按钮组件

/// 增强版快捷操作按钮组件
struct EnhancedActionButton_platbell: View {
    let icon_platbell: String
    let title_platbell: String
    let gradientIndex_platbell: Int
    let action_platbell: () -> Void
    
    @State private var isPressed_platbell = false
    
    var body: some View {
        Button(action: handleTap_platbell) {
            VStack(spacing: 14) {
            // 图标组（简化版）
            ZStack {
                // 背景圆
                Circle()
                    .fill(
                        ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.2)
                    )
                    .frame(width: 52, height: 52)
                
                // 图标
                Image(systemName: icon_platbell)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
            }
                
                // 标题
                Text(title_platbell)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // 主背景
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                    
                    // 顶部高光
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
                    
                    // 底部装饰
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.05)
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                }
            )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.3),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
            .scaleEffect(isPressed_platbell ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /// 处理点击
    private func handleTap_platbell() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
            isPressed_platbell = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                isPressed_platbell = false
            }
        }
        
        // 触觉反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback_platbell.impactOccurred()
        
        action_platbell()
    }
}

// MARK: - 缩放按钮样式

/// 缩放按钮样式
struct ScaleButtonStyle_platbell: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
