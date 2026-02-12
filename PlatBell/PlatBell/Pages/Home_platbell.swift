import SwiftUI

// MARK: - 首页
// 核心作用：展示所有用户的帖子时间线，包含故事轮播和帖子流
// 设计思路：故事轮播 + 帖子瀑布流 + 下拉刷新 + 平滑动画
// 关键功能：故事查看、帖子浏览、双击点赞、下拉刷新

/// 排序类型枚举
enum SortType_platbell: String, CaseIterable {
    case latest_platbell = "Latest"
    case popular_platbell = "Popular"
    case trending_platbell = "Trending"
}

/// 首页
struct Home_platbell: View {
    
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    
    /// 是否正在刷新
    @State private var isRefreshing_platbell = false
    
    /// 卡片可见状态
    @State private var cardsVisible_platbell = false
    
    /// 当前排序方式
    @State private var currentSort_platbell: SortType_platbell = .latest_platbell
    
    /// 根据排序方式获取帖子列表（只显示类型为0的普通帖子）
    private var sortedPosts_platbell: [TitleModel_platbell] {
        // 筛选出类型为0的普通帖子
        let normalPosts_platbell = titleVM_platbell.posts_platbell.filter { $0.type_platbell == 0 }
        
        switch currentSort_platbell {
        case .latest_platbell:
            // 按ID倒序（时间线）
            return normalPosts_platbell.sorted { $0.titleId_platbell > $1.titleId_platbell }
        case .popular_platbell:
            // 按点赞数排序
            return normalPosts_platbell.sorted { $0.likes_platbell > $1.likes_platbell }
        case .trending_platbell:
            // 趋势排序：综合点赞数和评论数
            return normalPosts_platbell.sorted { post1_platbell, post2_platbell in
                let score1_platbell = post1_platbell.likes_platbell * 2 + post1_platbell.reviews_platbell.count * 3
                let score2_platbell = post2_platbell.likes_platbell * 2 + post2_platbell.reviews_platbell.count * 3
                return score1_platbell > score2_platbell
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundView_platbell
            
            // 主内容
            ScrollView {
                VStack(spacing: 0) {
                    // 顶部标题
                    headerView_platbell
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    
                    // 轮播图
                    BannerCarousel_platbell()
                        .padding(.top, 16)
                    
                    // 分类标签
                    categorySection_platbell
                        .padding(.top, 20)
                    
                    // 帖子列表标题
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Latest Posts")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("\(sortedPosts_platbell.count) posts found")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 排序按钮
                        Menu {
                            Button(action: {
                                changeSortType_platbell(to: .latest_platbell)
                            }) {
                                Label("Latest", systemImage: "clock")
                                if currentSort_platbell == .latest_platbell {
                                    Image(systemName: "checkmark")
                                }
                            }
                            
                            Button(action: {
                                changeSortType_platbell(to: .popular_platbell)
                            }) {
                                Label("Popular", systemImage: "flame")
                                if currentSort_platbell == .popular_platbell {
                                    Image(systemName: "checkmark")
                                }
                            }
                            
                            Button(action: {
                                changeSortType_platbell(to: .trending_platbell)
                            }) {
                                Label("Trending", systemImage: "chart.line.uptrend.xyaxis")
                                if currentSort_platbell == .trending_platbell {
                                    Image(systemName: "checkmark")
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: getSortIcon_platbell())
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text(currentSort_platbell.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(ThemeColors_platbell.primaryStart_platbell)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(ThemeColors_platbell.primaryStart_platbell.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    
                    // 帖子列表
                    LazyVStack(spacing: 16) {
                        ForEach(sortedPosts_platbell.indices, id: \.self) { index_platbell in
                            let post_platbell = sortedPosts_platbell[index_platbell]
                            
                            PostCard_platbell(
                                post_platbell: post_platbell,
                                gradientIndex_platbell: index_platbell % ThemeColors_platbell.allGradients_platbell.count,
                                isVisible_platbell: cardsVisible_platbell,
                                animationDelay_platbell: Double(index_platbell) * 0.05
                            )
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 100) // 为底部导航栏留出空间
                }
            }
            .refreshable {
                await performRefresh_platbell()
            }
        }
        .onAppear {
            // 延迟显示卡片动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    cardsVisible_platbell = true
                }
            }
        }
    }
    
    // MARK: - 子视图
    
    /// 渐变背景
    private var backgroundView_platbell: some View {
        LinearGradient(
            colors: [
                ThemeColors_platbell.primaryStart_platbell.opacity(0.1),
                ThemeColors_platbell.accentBlueStart_platbell.opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// 顶部标题
    private var headerView_platbell: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                // 装饰性图标
                ZStack {
                    Circle()
                        .fill(
                            ThemeColors_platbell.gradient_platbell(at: 0)
                                .opacity(0.2)
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            ThemeColors_platbell.gradient_platbell(at: 0)
                        )
                }
                .shadow(
                    color: ThemeColors_platbell.primaryStart_platbell.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("PlatBell")
                        .font(.system(size: 32, weight: .bold))
                        .gradientText_platbell(gradientIndex_platbell: 0)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ThemeColors_platbell.secondaryStart_platbell)
                        
                        Text("Discover the forest")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // 欢迎信息卡片
            welcomeCard_platbell
        }
    }
    
    /// 欢迎信息卡片
    private var welcomeCard_platbell: some View {
        HStack(spacing: 12) {
            // 头像
            UserAvatarView_platbell(
                userId_platbell: userVM_platbell.getCurrentUser_platbell().userId_platbell ?? 0,
                size_platbell: 40,
                isClickable_platbell: false
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(userVM_platbell.isLoggedIn_platbell ? "Welcome back!" : "Welcome to PlatBell")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(userVM_platbell.getCurrentUser_platbell().userName_platbell ?? "Explorer")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 每日打卡按钮
            Button(action: {
                handleCheckIn_platbell()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text("Check In")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(ThemeColors_platbell.gradient_platbell(at: 4))
                )
                .shadow(
                    color: ThemeColors_platbell.warmStart_platbell.opacity(0.3),
                    radius: 6,
                    x: 0,
                    y: 3
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            ThemeColors_platbell.primaryStart_platbell.opacity(0.3),
                            ThemeColors_platbell.secondaryStart_platbell.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    /// 处理打卡
    private func handleCheckIn_platbell() {
        if !userVM_platbell.isLoggedIn_platbell {
            router_platbell.toLogin_platbellui()
            return
        }
        
        userVM_platbell.checkIn_platbell()
    }
    
    /// 打卡数据区域
    private var categorySection_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 4))
                
                Text("Check-in Stats")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // 连续打卡天数
                    CheckInStatCard_platbell(
                        icon_platbell: "flame.fill",
                        title_platbell: "Streak",
                        value_platbell: "\(userVM_platbell.getCurrentUser_platbell().checkInStreak_platbell)",
                        unit_platbell: "days",
                        gradientIndex_platbell: 4,
                        isPrimary_platbell: true
                    )
                    
                    // 本周打卡
                    CheckInStatCard_platbell(
                        icon_platbell: "calendar.badge.checkmark",
                        title_platbell: "This Week",
                        value_platbell: "\(userVM_platbell.getCurrentUser_platbell().checkInThisWeek_platbell)",
                        unit_platbell: "check-ins",
                        gradientIndex_platbell: 0,
                        isPrimary_platbell: false
                    )
                    
                    // 总打卡次数
                    CheckInStatCard_platbell(
                        icon_platbell: "checkmark.seal.fill",
                        title_platbell: "Total",
                        value_platbell: "\(userVM_platbell.getCurrentUser_platbell().totalCheckIns_platbell)",
                        unit_platbell: "check-ins",
                        gradientIndex_platbell: 2,
                        isPrimary_platbell: false
                    )
                    
                    // 排名
                    CheckInStatCard_platbell(
                        icon_platbell: "trophy.fill",
                        title_platbell: "Ranking",
                        value_platbell: userVM_platbell.getCurrentUser_platbell().checkInRanking_platbell > 0 ? "#\(userVM_platbell.getCurrentUser_platbell().checkInRanking_platbell)" : "--",
                        unit_platbell: "this month",
                        gradientIndex_platbell: 1,
                        isPrimary_platbell: false
                    )
                    
                    // 积分
                    CheckInStatCard_platbell(
                        icon_platbell: "star.fill",
                        title_platbell: "Points",
                        value_platbell: "\(userVM_platbell.getCurrentUser_platbell().checkInPoints_platbell)",
                        unit_platbell: "total",
                        gradientIndex_platbell: 3,
                        isPrimary_platbell: false
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - 事件处理
    
    /// 执行刷新
    private func performRefresh_platbell() async {
        isRefreshing_platbell = true
        
        // 模拟刷新延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 重新加载数据
        titleVM_platbell.initPosts_platbell()
        
        isRefreshing_platbell = false
    }
    
    /// 切换排序方式
    private func changeSortType_platbell(to sortType_platbell: SortType_platbell) {
        withAnimation(AnimationPresets_platbell.standardSpring_platbell) {
            currentSort_platbell = sortType_platbell
            
            // 重置卡片可见状态，触发重新动画
            cardsVisible_platbell = false
        }
        
        // 震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback_platbell.impactOccurred()
        
        // 延迟显示卡片
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation {
                cardsVisible_platbell = true
            }
        }
        
        // 显示提示
        Utils_platbell.showSuccess_platbell(
            message_platbell: "Sorted by \(sortType_platbell.rawValue)",
            delay_platbell: 1.0
        )
    }
    
    /// 获取当前排序图标
    private func getSortIcon_platbell() -> String {
        switch currentSort_platbell {
        case .latest_platbell:
            return "clock"
        case .popular_platbell:
            return "flame"
        case .trending_platbell:
            return "chart.line.uptrend.xyaxis"
        }
    }
}

// MARK: - 预览

#Preview {
    Home_platbell()
        .onAppear {
            LocalData_platbell.shared_platbell.initData_platbell()
            TitleViewModel_platbell.shared_platbell.initPosts_platbell()
            UserViewModel_platbell.shared_platbell.initUser_platbell()
        }
}
