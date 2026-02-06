import SwiftUI

// MARK: - 发现页
// 核心作用：展示穿搭挑战和时光胶囊功能
// 设计思路：分为两个核心模块 - 挑战和时光胶囊，强调社区互动和纪念价值
// 关键功能：参与挑战、创建挑战、封存穿搭、解锁时光胶囊

/// 发现页主视图
struct Discover_lite: View {
    
    @ObservedObject private var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var localData_lite = LocalData_lite.shared_lite
    
    @State private var selectedTab_lite: DiscoverTab_lite = .challenge_lite
    @State private var showCreateChallenge_lite = false
    @State private var showCreateCapsule_lite = false
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            AnimatedDiscoverBackground_lite()
                .ignoresSafeArea()
            
            // 装饰性浮动元素
            FloatingDiscoverElements_lite()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                headerView_lite
                    .padding(.horizontal, 20.w_lite)
                    .padding(.top, 10.h_lite)
                
                // 标签切换
                tabSelector_lite
                    .padding(.horizontal, 20.w_lite)
                    .padding(.top, 24.h_lite)
                
                // 内容区域 - 平滑过渡动画版
                ZStack {
                    // 挑战页面
                    ScrollView {
                        LazyVStack(spacing: 28.h_lite, pinnedViews: []) {
                            challengeSection_lite
                        }
                        .padding(.top, 24.h_lite)
                        .padding(.bottom, 100.h_lite)
                    }
                    .opacity(selectedTab_lite == .challenge_lite ? 1 : 0)
                    .offset(x: selectedTab_lite == .challenge_lite ? 0 : -20.w_lite)
                    .blur(radius: selectedTab_lite == .challenge_lite ? 0 : 3)
                    .scaleEffect(selectedTab_lite == .challenge_lite ? 1.0 : 0.95)
                    .zIndex(selectedTab_lite == .challenge_lite ? 1 : 0)
                    .allowsHitTesting(selectedTab_lite == .challenge_lite)
                    
                    // 时光胶囊页面
                    ScrollView {
                        LazyVStack(spacing: 28.h_lite, pinnedViews: []) {
                            capsuleSection_lite
                        }
                        .padding(.top, 24.h_lite)
                        .padding(.bottom, 100.h_lite)
                    }
                    .opacity(selectedTab_lite == .capsule_lite ? 1 : 0)
                    .offset(x: selectedTab_lite == .capsule_lite ? 0 : 20.w_lite)
                    .blur(radius: selectedTab_lite == .capsule_lite ? 0 : 3)
                    .scaleEffect(selectedTab_lite == .capsule_lite ? 1.0 : 0.95)
                    .zIndex(selectedTab_lite == .capsule_lite ? 1 : 0)
                    .allowsHitTesting(selectedTab_lite == .capsule_lite)
                }
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.25),
                    value: selectedTab_lite
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $showCreateChallenge_lite) {
            CreateChallengeView_lite()
        }
        .sheet(isPresented: $showCreateCapsule_lite) {
            CreateCapsuleView_lite()
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var headerView_lite: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6.h_lite) {
                // 添加装饰图标
                HStack(spacing: 8.w_lite) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 26.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "FFD700"))
                        .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 4)
                    
                    Text("Discover")
                        .font(.system(size: 32.sp_lite, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Text("Challenge yourself, capture memories")
                    .font(.system(size: 14.sp_lite, weight: .medium))
                    .foregroundColor(Color(hex: "495057"))
            }
            
            Spacer()
            
            // 移除创建按钮，仅在时光胶囊标签显示
            if selectedTab_lite == .capsule_lite {
                Button {
                    showCreateCapsule_lite = true
                } label: {
                    ZStack {
                        // 外圈光环
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "f093fb").opacity(0.3), Color(hex: "f5576c").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48.w_lite, height: 48.h_lite)
                            .blur(radius: 8)
                        
                        // 主按钮
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32.sp_lite, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
                .buttonStyle(ScaleButtonStyle_lite())
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.25),
                    value: selectedTab_lite
                )
            }
        }
    }
    
    // MARK: - 标签切换
    
    private var tabSelector_lite: some View {
        HStack(spacing: 14.w_lite) {
            ForEach(DiscoverTab_lite.allCases, id: \.self) { tab_lite in
                Button {
                    // 使用与内容区域一致的平滑过渡动画
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.25)) {
                        selectedTab_lite = tab_lite
                    }
                } label: {
                    VStack(spacing: 0) {
                        HStack(spacing: 10.w_lite) {
                            // 图标 - 增强版
                            ZStack {
                                if selectedTab_lite == tab_lite {
                                    Circle()
                                        .fill(Color.white.opacity(0.25))
                                        .frame(width: 32.w_lite, height: 32.h_lite)
                                }
                                
                                Image(systemName: tab_lite.icon_lite)
                                    .font(.system(size: 17.sp_lite, weight: .bold))
                            }
                            
                            Text(tab_lite.title_lite)
                                .font(.system(size: 16.sp_lite, weight: .bold))
                        }
                        .foregroundColor(selectedTab_lite == tab_lite ? .white : Color(hex: "6C757D"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16.h_lite)
                        .background(
                            ZStack {
                                if selectedTab_lite == tab_lite {
                                    // 渐变背景
                                    LinearGradient(
                                        colors: tab_lite.gradientColors_lite,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    
                                    // 高光效果
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                } else {
                                    LinearGradient(
                                        colors: [Color.white, Color(hex: "F8F9FA")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            }
                        )
                        .cornerRadius(16.w_lite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16.w_lite)
                                .stroke(
                                    selectedTab_lite == tab_lite ?
                                        Color.white.opacity(0.5) :
                                        Color(hex: "E9ECEF"),
                                    lineWidth: selectedTab_lite == tab_lite ? 1.5 : 1
                                )
                        )
                        .shadow(
                            color: selectedTab_lite == tab_lite
                                ? tab_lite.gradientColors_lite[0].opacity(0.4)
                                : Color.black.opacity(0.05),
                            radius: selectedTab_lite == tab_lite ? 12 : 6,
                            x: 0,
                            y: selectedTab_lite == tab_lite ? 6 : 3
                        )
                        // 添加平滑的过渡效果
                        .scaleEffect(selectedTab_lite == tab_lite ? 1.0 : 0.98)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.25),
                            value: selectedTab_lite
                        )
                    }
                }
                .buttonStyle(ScaleButtonStyle_lite())
            }
        }
    }
    
    // MARK: - 挑战模块
    
    private var challengeSection_lite: some View {
        LazyVStack(alignment: .leading, spacing: 24.h_lite, pinnedViews: []) {
            // 官方灵感
            let officialChallenges_lite = titleVM_lite.getActiveChallenges_lite().filter { $0.isOfficial_lite }
            
            if !officialChallenges_lite.isEmpty {
                LazyVStack(alignment: .leading, spacing: 16.h_lite, pinnedViews: []) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 18.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "FFC107"))
                        
                        Text("Official Inspiration")
                            .font(.system(size: 20.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "212529"))
                    }
                    .padding(.horizontal, 20.w_lite)
                    
                    ForEach(officialChallenges_lite) { challenge_lite in
                        ChallengeCard_lite(
                            challenge_lite: challenge_lite,
                            onJoin_lite: {
                                // 跳转到灵感详情页
                                Router_lite.shared_lite.navigate_lite(to: .inspirationDetail_lite(challenge_lite: challenge_lite))
                            }
                        )
                        .padding(.horizontal, 20.w_lite)
                        .id(challenge_lite.challengeId_lite)
                    }
                }
                
                // 穿搭灵感瀑布流
                outfitPostsWaterfall_lite
            } else {
                // 空状态
                emptyStateView_lite(
                    icon_lite: "lightbulb",
                    title_lite: "No Active Inspiration",
                    subtitle_lite: "Stay tuned for official inspiration events!"
                )
                .padding(.top, 40.h_lite)
            }
        }
    }
    
    // MARK: - 穿搭帖子瀑布流
    
    /// 穿搭帖子瀑布流视图
    private var outfitPostsWaterfall_lite: some View {
        VStack(alignment: .leading, spacing: 16.h_lite) {
            // 标题
            HStack {
                ZStack {
                    // 背景光晕
                    Circle()
                        .fill(Color(hex: "f093fb").opacity(0.15))
                        .frame(width: 36.w_lite, height: 36.h_lite)
                        .blur(radius: 8)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 18.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "f093fb"))
                }
                
                Text("Style Inspiration")
                    .font(.system(size: 20.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
            }
            .padding(.horizontal, 20.w_lite)
            .padding(.top, 8.h_lite)
            
            // 瀑布流布局
            WaterfallPostsGrid_lite(posts_lite: titleVM_lite.getPosts_lite())
                .padding(.horizontal, 20.w_lite)
        }
    }
    
    // MARK: - 时光胶囊模块
    
    private var capsuleSection_lite: some View {
        LazyVStack(alignment: .leading, spacing: 20.h_lite, pinnedViews: []) {
            // 时光胶囊列表（所有用户可见）
            let allCapsules_lite = localData_lite.capsuleList_lite
            
            if !allCapsules_lite.isEmpty {
                LazyVStack(alignment: .leading, spacing: 16.h_lite, pinnedViews: []) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "f093fb"))
                        
                        Text("Time Capsules")
                            .font(.system(size: 20.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "212529"))
                        
                        Spacer()
                        
                        // 显示胶囊数量
                        Text("\(allCapsules_lite.count)")
                            .font(.system(size: 16.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "f093fb"))
                            .padding(.horizontal, 12.w_lite)
                            .padding(.vertical, 6.h_lite)
                            .background(Color(hex: "f093fb").opacity(0.15))
                            .cornerRadius(12.w_lite)
                    }
                    .padding(.horizontal, 20.w_lite)
                    
                    ForEach(allCapsules_lite) { capsule_lite in
                        CapsuleCard_lite(
                            capsule_lite: capsule_lite,
                            onUnlock_lite: {
                                titleVM_lite.unlockCapsule_lite(capsule_lite: capsule_lite)
                            }
                        )
                        .padding(.horizontal, 20.w_lite)
                        .id(capsule_lite.capsuleId_lite) // 添加ID确保视图复用
                    }
                }
            } else {
                emptyStateView_lite(
                    icon_lite: "envelope.fill",
                    title_lite: "No Capsules Yet",
                    subtitle_lite: "Create your first memory capsule"
                )
                .padding(.top, 40.h_lite)
            }
        }
    }
    
    // MARK: - 空状态视图
    
    private func emptyStateView_lite(icon_lite: String, title_lite: String, subtitle_lite: String) -> some View {
        VStack(spacing: 16.h_lite) {
            Image(systemName: icon_lite)
                .font(.system(size: 60.sp_lite))
                .foregroundColor(Color(hex: "ADB5BD"))
            
            Text(title_lite)
                .font(.system(size: 18.sp_lite, weight: .semibold))
                .foregroundColor(Color(hex: "495057"))
            
            Text(subtitle_lite)
                .font(.system(size: 14.sp_lite, weight: .regular))
                .foregroundColor(Color(hex: "6C757D"))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 标签枚举

/// 发现页标签枚举
enum DiscoverTab_lite: CaseIterable {
    case challenge_lite
    case capsule_lite
    
    var title_lite: String {
        switch self {
        case .challenge_lite: return "Inspiration"
        case .capsule_lite: return "Capsules"
        }
    }
    
    var icon_lite: String {
        switch self {
        case .challenge_lite: return "lightbulb.fill"
        case .capsule_lite: return "envelope.fill"
        }
    }
    
    var gradientColors_lite: [Color] {
        switch self {
        case .challenge_lite: return [Color(hex: "667eea"), Color(hex: "764ba2")]
        case .capsule_lite: return [Color(hex: "f093fb"), Color(hex: "f5576c")]
        }
    }
}

// MARK: - 挑战卡片组件

/// 挑战卡片 - 增强版
struct ChallengeCard_lite: View {
    
    let challenge_lite: OutfitChallenge_lite
    let onJoin_lite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18.h_lite) {
            // 顶部信息 - 增强版
            HStack(spacing: 16.w_lite) {
                // 基础单品图标 - 增强版
                ZStack {
                    // 背景光晕
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: MediaConfig_lite.getGradientColors_lite(for: challenge_lite.baseItem_lite.itemName_lite).map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72.w_lite, height: 72.h_lite)
                        .blur(radius: 8)
                    
                    // 主图标
                    Image(systemName: challenge_lite.baseItem_lite.itemImage_lite)
                        .font(.system(size: 28.sp_lite, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 64.w_lite, height: 64.h_lite)
                        .background(
                            ZStack {
                                LinearGradient(
                                    colors: MediaConfig_lite.getGradientColors_lite(for: challenge_lite.baseItem_lite.itemName_lite),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                // 高光
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        )
                        .cornerRadius(18.w_lite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18.w_lite)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                
                VStack(alignment: .leading, spacing: 8.h_lite) {
                    // 官方标识
                    if challenge_lite.isOfficial_lite {
                        HStack(spacing: 5.w_lite) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 13.sp_lite, weight: .bold))
                            
                            Text("Official")
                                .font(.system(size: 12.sp_lite, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "FFC107"))
                        .padding(.horizontal, 10.w_lite)
                        .padding(.vertical, 5.h_lite)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(Color(hex: "FFC107").opacity(0.15))
                                
                                Capsule()
                                    .stroke(Color(hex: "FFC107").opacity(0.3), lineWidth: 1)
                            }
                        )
                    }
                    
                    Text(challenge_lite.challengeTitle_lite)
                        .font(.system(size: 19.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "212529"))
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            // 描述
            Text(challenge_lite.challengeDescription_lite)
                .font(.system(size: 14.sp_lite, weight: .regular))
                .foregroundColor(Color(hex: "6C757D"))
                .lineLimit(3)
                .lineSpacing(3)
            
            // 统计信息 - 增强版
            HStack(spacing: 24.w_lite) {
                HStack(spacing: 8.w_lite) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "667eea").opacity(0.15))
                            .frame(width: 32.w_lite, height: 32.h_lite)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "667eea"))
                    }
                    
                    VStack(alignment: .leading, spacing: 2.h_lite) {
                        Text("\(challenge_lite.submissions_lite.count)")
                            .font(.system(size: 16.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "212529"))
                        
                        Text("joined")
                            .font(.system(size: 11.sp_lite, weight: .medium))
                            .foregroundColor(Color(hex: "6C757D"))
                    }
                }
                
                HStack(spacing: 8.w_lite) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "f093fb").opacity(0.15))
                            .frame(width: 32.w_lite, height: 32.h_lite)
                        
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "f093fb"))
                    }
                    
                    VStack(alignment: .leading, spacing: 2.h_lite) {
                        Text(daysRemainingNumber_lite(endDate_lite: challenge_lite.endDate_lite))
                            .font(.system(size: 16.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "212529"))
                        
                        Text("days left")
                            .font(.system(size: 11.sp_lite, weight: .medium))
                            .foregroundColor(Color(hex: "6C757D"))
                    }
                }
            }
            .padding(.vertical, 4.h_lite)
            
            // 参与按钮 - 增强版，检查是否已参与
            Button(action: onJoin_lite) {
                HStack(spacing: 8.w_lite) {
                    let isParticipated_lite = TitleViewModel_lite.shared_lite.hasParticipatedInChallenge_lite(challengeId_lite: challenge_lite.challengeId_lite)
                    
                    Image(systemName: isParticipated_lite ? "checkmark.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 18.sp_lite, weight: .bold))
                    
                    Text(isParticipated_lite ? "Participated" : "Join Inspiration")
                        .font(.system(size: 16.sp_lite, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16.h_lite)
                .background(
                    ZStack {
                        let isParticipated_lite = TitleViewModel_lite.shared_lite.hasParticipatedInChallenge_lite(challengeId_lite: challenge_lite.challengeId_lite)
                        
                        LinearGradient(
                            colors: isParticipated_lite ?
                                [Color(hex: "43e97b"), Color(hex: "38f9d7")] :
                                [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // 高光效果
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
                .cornerRadius(16.w_lite)
                .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(ScaleButtonStyle_lite())
        }
        .padding(22.w_lite)
        .background(
            ZStack {
                // 基础背景
                LinearGradient(
                    colors: [Color.white, Color(hex: "F8F9FA")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 装饰性元素
                Circle()
                    .fill(Color(hex: "667eea").opacity(0.05))
                    .frame(width: 100.w_lite, height: 100.h_lite)
                    .offset(x: 120.w_lite, y: -40.h_lite)
                    .blur(radius: 20)
            }
        )
        .cornerRadius(24.w_lite)
        .overlay(
            RoundedRectangle(cornerRadius: 24.w_lite)
                .stroke(
                    LinearGradient(
                        colors: [Color.white, Color(hex: "E9ECEF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
        .shadow(color: Color(hex: "667eea").opacity(0.15), radius: 15, x: 0, y: 5)
    }
    
    /// 计算剩余天数
    private func daysRemaining_lite(endDate_lite: Date) -> String {
        let days_lite = Calendar.current.dateComponents([.day], from: Date(), to: endDate_lite).day ?? 0
        return days_lite > 0 ? "\(days_lite) days left" : "Ended"
    }
    
    /// 计算剩余天数数字
    private func daysRemainingNumber_lite(endDate_lite: Date) -> String {
        let days_lite = Calendar.current.dateComponents([.day], from: Date(), to: endDate_lite).day ?? 0
        return days_lite > 0 ? "\(days_lite)" : "0"
    }
}

// MARK: - 时光胶囊卡片组件

/// 时光胶囊卡片 - 性能优化版
struct CapsuleCard_lite: View {
    
    let capsule_lite: OutfitCapsule_lite
    let onUnlock_lite: () -> Void
    
    @State private var showReportSheet_lite = false
    @State private var showDeleteConfirm_lite = false
    
    /// 判断是否为当前用户的胶囊
    private var isOwnCapsule_lite: Bool {
        let currentUserId_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite().userId_lite ?? 0
        return capsule_lite.userId_lite == currentUserId_lite
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18.h_lite) {
            // 顶部状态 - 增强版
            HStack(spacing: 12.w_lite) {
                // 锁状态图标 - 简化版
                ZStack {
                    // 主图标背景
                    Circle()
                        .fill(
                            capsule_lite.isUnlocked_lite ?
                                LinearGradient(
                                    colors: [Color(hex: "43e97b"), Color(hex: "38f9d7")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 44.w_lite, height: 44.h_lite)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                        .shadow(
                            color: (capsule_lite.isUnlocked_lite ? Color(hex: "43e97b") : Color(hex: "f093fb")).opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    
                    Image(systemName: capsule_lite.isUnlocked_lite ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 20.sp_lite, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4.h_lite) {
                    Text(capsule_lite.isUnlocked_lite ? "Unlocked" : "Sealed")
                        .font(.system(size: 16.sp_lite, weight: .bold))
                        .foregroundColor(capsule_lite.isUnlocked_lite ? Color(hex: "43e97b") : Color(hex: "f093fb"))
                    
                    Text(dateFormatter_lite.string(from: capsule_lite.sealDate_lite))
                        .font(.system(size: 12.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "6C757D"))
                }
                
                Spacer()
                
                // 装饰性星星
                Image(systemName: capsule_lite.isUnlocked_lite ? "star.fill" : "star")
                    .font(.system(size: 20.sp_lite))
                    .foregroundColor(Color(hex: "FFD700"))
                    .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 4)
                
                // 删除/举报按钮
                Button {
                    if isOwnCapsule_lite {
                        // 如果是自己的胶囊，显示删除确认
                        showDeleteConfirm_lite = true
                    } else {
                        // 如果是他人的胶囊，显示举报菜单
                        showReportSheet_lite = true
                    }
                } label: {
                    ZStack {
                        // 背景圆形
                        Circle()
                            .fill(isOwnCapsule_lite ? Color(hex: "FFE5E5") : Color(hex: "F8F9FA"))
                            .frame(width: 32.w_lite, height: 32.h_lite)
                            .overlay(
                                Circle()
                                    .stroke(isOwnCapsule_lite ? Color(hex: "FF6B6B").opacity(0.3) : Color(hex: "E9ECEF"), lineWidth: 1)
                            )
                        
                        // 图标：删除或举报
                        Image(systemName: isOwnCapsule_lite ? "trash.fill" : "ellipsis")
                            .font(.system(size: isOwnCapsule_lite ? 14.sp_lite : 16.sp_lite, weight: .bold))
                            .foregroundColor(isOwnCapsule_lite ? Color(hex: "FF6B6B") : Color(hex: "6C757D"))
                    }
                }
                .buttonStyle(ScaleButtonStyle_lite())
            }
            
            // 分隔线
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            (capsule_lite.isUnlocked_lite ? Color(hex: "43e97b") : Color(hex: "f093fb")).opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
            // 穿搭信息
            Text(capsule_lite.outfit_lite.comboTitle_lite)
                .font(.system(size: 19.sp_lite, weight: .bold))
                .foregroundColor(Color(hex: "212529"))
            
            // 心得 - 增强版
            VStack(alignment: .leading, spacing: 8.h_lite) {
                HStack(spacing: 6.w_lite) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 12.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "6C757D"))
                    
                    Text("Original Thought")
                        .font(.system(size: 12.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "6C757D"))
                }
                
                Text(capsule_lite.thoughtNote_lite)
                    .font(.system(size: 14.sp_lite, weight: .regular))
                    .foregroundColor(Color(hex: "495057"))
                    .lineLimit(3)
                    .lineSpacing(3)
            }
            .padding(14.w_lite)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12.w_lite)
                        .fill(Color(hex: "F8F9FA"))
                    
                    RoundedRectangle(cornerRadius: 12.w_lite)
                        .stroke(Color(hex: "E9ECEF"), lineWidth: 1)
                }
            )
            
            // 解锁信息
            if !capsule_lite.isUnlocked_lite {
                HStack(spacing: 8.w_lite) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "f093fb").opacity(0.15))
                            .frame(width: 28.w_lite, height: 28.h_lite)
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 13.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "f093fb"))
                    }
                    
                    Text("Unlock on \(dateFormatter_lite.string(from: capsule_lite.unlockDate_lite))")
                        .font(.system(size: 13.sp_lite, weight: .semibold))
                        .foregroundColor(Color(hex: "495057"))
                    
                    Spacer()
                }
                .padding(.vertical, 4.h_lite)
                
                // 解锁按钮 - 增强版
                if Date() >= capsule_lite.unlockDate_lite {
                    Button(action: onUnlock_lite) {
                        HStack(spacing: 10.w_lite) {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 18.sp_lite, weight: .bold))
                            
                            Text("Unlock Now")
                                .font(.system(size: 16.sp_lite, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16.h_lite)
                        .background(
                            ZStack {
                                LinearGradient(
                                    colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                // 高光效果
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                        .cornerRadius(16.w_lite)
                        .shadow(color: Color(hex: "f093fb").opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(ScaleButtonStyle_lite())
                }
            } else {
                // 已解锁的对比心得 - 增强版
                if let unlockNote_lite = capsule_lite.unlockNote_lite {
                    VStack(alignment: .leading, spacing: 8.h_lite) {
                        HStack(spacing: 6.w_lite) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12.sp_lite, weight: .bold))
                                .foregroundColor(Color(hex: "43e97b"))
                            
                            Text("Reflection")
                                .font(.system(size: 12.sp_lite, weight: .bold))
                                .foregroundColor(Color(hex: "43e97b"))
                        }
                        
                        Text(unlockNote_lite)
                            .font(.system(size: 14.sp_lite, weight: .regular))
                            .foregroundColor(Color(hex: "495057"))
                            .lineSpacing(3)
                    }
                    .padding(14.w_lite)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 12.w_lite)
                                .fill(Color(hex: "43e97b").opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 12.w_lite)
                                .stroke(Color(hex: "43e97b").opacity(0.3), lineWidth: 1)
                        }
                    )
                }
            }
        }
        .padding(22.w_lite)
        .background(
            ZStack {
                // 基础背景
                LinearGradient(
                    colors: [Color.white, Color(hex: "FAFAFA")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 装饰性光晕
                Circle()
                    .fill(
                        (capsule_lite.isUnlocked_lite ? Color(hex: "43e97b") : Color(hex: "f093fb")).opacity(0.08)
                    )
                    .frame(width: 150.w_lite, height: 150.h_lite)
                    .offset(x: -60.w_lite, y: -50.h_lite)
                    .blur(radius: 40)
            }
        )
        .cornerRadius(24.w_lite)
        .overlay(
            RoundedRectangle(cornerRadius: 24.w_lite)
                .stroke(
                    LinearGradient(
                        colors: capsule_lite.isUnlocked_lite
                            ? [Color(hex: "43e97b"), Color(hex: "38f9d7")]
                            : [Color(hex: "f093fb"), Color(hex: "f5576c")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
        .shadow(
            color: (capsule_lite.isUnlocked_lite ? Color(hex: "43e97b") : Color(hex: "f093fb")).opacity(0.2),
            radius: 15,
            x: 0,
            y: 5
        )
        .overlay(
            // 添加举报菜单
            ReportActionSheet_lite(
                isShowing_lite: $showReportSheet_lite,
                isBlockUser_lite: false,
                onConfirm_lite: {
                    reportCapsule_lite()
                }
            )
        )
        .alert(isPresented: $showDeleteConfirm_lite) {
            Alert(
                title: Text("Delete Capsule"),
                message: Text("Are you sure you want to delete this capsule? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteCapsule_lite()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    /// 删除时空胶囊方法
    /// 功能：删除自己发布的时空胶囊
    private func deleteCapsule_lite() {
        // 调用举报助手方法（内部会判断是否为自己的胶囊）
        ReportHelper_lite.reportCapsule_lite(capsule_lite: capsule_lite) {}
    }
    
    /// 举报时空胶囊方法
    /// 功能：调用ReportHelper举报他人发布的胶囊
    private func reportCapsule_lite() {
        // 调用举报助手方法
        ReportHelper_lite.reportCapsule_lite(capsule_lite: capsule_lite) {}
    }
    
    private var dateFormatter_lite: DateFormatter {
        let formatter_lite = DateFormatter()
        formatter_lite.dateFormat = "MMM dd, yyyy"
        return formatter_lite
    }
}

// MARK: - 创建挑战视图

/// 创建挑战视图
struct CreateChallengeView_lite: View {
    
    @Environment(\.dismiss) private var dismiss_lite
    @ObservedObject private var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject private var localData_lite = LocalData_lite.shared_lite
    
    @State private var challengeTitle_lite = ""
    @State private var challengeDescription_lite = ""
    @State private var selectedItem_lite: OutfitItem_lite?
    @State private var endDate_lite = Date().addingTimeInterval(7 * 24 * 60 * 60)
    
    var body: some View {
        NavigationView {
            ZStack {
                // 动态渐变背景
                LinearGradient(
                    colors: [
                        Color(hex: "667eea").opacity(0.1),
                        Color(hex: "764ba2").opacity(0.05),
                        Color(hex: "F8F9FA")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28.h_lite) {
                        // 标题输入 - 增强版
                        VStack(alignment: .leading, spacing: 10.h_lite) {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "text.alignleft")
                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "667eea"))
                                
                                Text("Challenge Title")
                                    .font(.system(size: 15.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "495057"))
                            }
                            
                            TextField("Enter challenge title", text: $challengeTitle_lite)
                                .font(.system(size: 16.sp_lite, weight: .medium))
                                .padding(18.w_lite)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14.w_lite)
                                            .fill(Color.white)
                                        
                                        RoundedRectangle(cornerRadius: 14.w_lite)
                                            .stroke(
                                                challengeTitle_lite.isEmpty ?
                                                    Color(hex: "E9ECEF") :
                                                    Color(hex: "667eea").opacity(0.3),
                                                lineWidth: 1.5
                                            )
                                    }
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                        
                        // 描述输入 - 增强版
                        VStack(alignment: .leading, spacing: 10.h_lite) {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "667eea"))
                                
                                Text("Description")
                                    .font(.system(size: 15.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "495057"))
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if challengeDescription_lite.isEmpty {
                                    Text("Describe your challenge...")
                                        .font(.system(size: 16.sp_lite))
                                        .foregroundColor(Color(hex: "ADB5BD"))
                                        .padding(.horizontal, 12.w_lite)
                                        .padding(.vertical, 18.h_lite)
                                }
                                
                                TextEditor(text: $challengeDescription_lite)
                                    .font(.system(size: 16.sp_lite, weight: .medium))
                                    .frame(height: 130.h_lite)
                                    .padding(.horizontal, 8.w_lite)
                                    .padding(.vertical, 12.h_lite)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14.w_lite)
                                        .fill(Color.white)
                                    
                                    RoundedRectangle(cornerRadius: 14.w_lite)
                                        .stroke(
                                            challengeDescription_lite.isEmpty ?
                                                Color(hex: "E9ECEF") :
                                                Color(hex: "667eea").opacity(0.3),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                        
                        // 选择基础单品 - 增强版
                        VStack(alignment: .leading, spacing: 12.h_lite) {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "tshirt")
                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "667eea"))
                                
                                Text("Base Item")
                                    .font(.system(size: 15.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "495057"))
                                
                                if selectedItem_lite != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14.sp_lite))
                                        .foregroundColor(Color(hex: "43e97b"))
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14.w_lite) {
                                    ForEach(localData_lite.outfitItemList_lite) { item_lite in
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedItem_lite = item_lite
                                            }
                                        } label: {
                                            VStack(spacing: 10.h_lite) {
                                                ZStack {
                                                    // 选中效果
                                                    if selectedItem_lite?.itemId_lite == item_lite.itemId_lite {
                                                        Circle()
                                                            .fill(Color(hex: "667eea").opacity(0.2))
                                                            .frame(width: 76.w_lite, height: 76.h_lite)
                                                            .blur(radius: 8)
                                                    }
                                                    
                                                    Image(systemName: item_lite.itemImage_lite)
                                                        .font(.system(size: 28.sp_lite, weight: .bold))
                                                        .foregroundColor(selectedItem_lite?.itemId_lite == item_lite.itemId_lite ? .white : Color(hex: "667eea"))
                                                        .frame(width: 68.w_lite, height: 68.h_lite)
                                                        .background(
                                                            ZStack {
                                                                if selectedItem_lite?.itemId_lite == item_lite.itemId_lite {
                                                                    LinearGradient(
                                                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                                                        startPoint: .topLeading,
                                                                        endPoint: .bottomTrailing
                                                                    )
                                                                    
                                                                    LinearGradient(
                                                                        colors: [Color.white.opacity(0.3), Color.clear],
                                                                        startPoint: .topLeading,
                                                                        endPoint: .bottomTrailing
                                                                    )
                                                                } else {
                                                                    Color.white
                                                                }
                                                            }
                                                        )
                                                        .cornerRadius(16.w_lite)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 16.w_lite)
                                                                .stroke(
                                                                    selectedItem_lite?.itemId_lite == item_lite.itemId_lite ?
                                                                        Color.white.opacity(0.5) :
                                                                        Color(hex: "667eea").opacity(0.3),
                                                                    lineWidth: selectedItem_lite?.itemId_lite == item_lite.itemId_lite ? 2 : 1.5
                                                                )
                                                        )
                                                        .shadow(
                                                            color: selectedItem_lite?.itemId_lite == item_lite.itemId_lite ?
                                                                Color(hex: "667eea").opacity(0.4) :
                                                                Color.black.opacity(0.05),
                                                            radius: selectedItem_lite?.itemId_lite == item_lite.itemId_lite ? 10 : 5,
                                                            x: 0,
                                                            y: 4
                                                        )
                                                    
                                                    // 选中标记
                                                    if selectedItem_lite?.itemId_lite == item_lite.itemId_lite {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .font(.system(size: 20.sp_lite, weight: .bold))
                                                            .foregroundColor(Color(hex: "43e97b"))
                                                            .background(
                                                                Circle()
                                                                    .fill(Color.white)
                                                                    .frame(width: 18.w_lite, height: 18.h_lite)
                                                            )
                                                            .offset(x: 28.w_lite, y: -28.h_lite)
                                                    }
                                                }
                                                
                                                Text(item_lite.itemName_lite)
                                                    .font(.system(size: 12.sp_lite, weight: selectedItem_lite?.itemId_lite == item_lite.itemId_lite ? .bold : .medium))
                                                    .foregroundColor(
                                                        selectedItem_lite?.itemId_lite == item_lite.itemId_lite ?
                                                            Color(hex: "667eea") :
                                                            Color(hex: "6C757D")
                                                    )
                                                    .lineLimit(1)
                                            }
                                            .frame(width: 90.w_lite)
                                        }
                                        .buttonStyle(ScaleButtonStyle_lite())
                                    }
                                }
                                .padding(.horizontal, 4.w_lite)
                                .padding(.vertical, 8.h_lite)
                            }
                        }
                        
                        // 结束日期 - 增强版
                        VStack(alignment: .leading, spacing: 10.h_lite) {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "667eea"))
                                
                                Text("End Date")
                                    .font(.system(size: 15.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "495057"))
                            }
                            
                            DatePicker("", selection: $endDate_lite, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding(18.w_lite)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16.w_lite)
                                            .fill(Color.white)
                                        
                                        RoundedRectangle(cornerRadius: 16.w_lite)
                                            .stroke(Color(hex: "E9ECEF"), lineWidth: 1.5)
                                    }
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        }
                        
                        // 创建按钮 - 增强版
                        Button {
                            createChallenge_lite()
                        } label: {
                            HStack(spacing: 10.w_lite) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20.sp_lite, weight: .bold))
                                
                                Text("Create Challenge")
                                    .font(.system(size: 17.sp_lite, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18.h_lite)
                            .background(
                                ZStack {
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    
                                    // 高光效果
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            )
                            .cornerRadius(18.w_lite)
                            .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        .buttonStyle(ScaleButtonStyle_lite())
                        .disabled(challengeTitle_lite.isEmpty || challengeDescription_lite.isEmpty || selectedItem_lite == nil)
                        .opacity((challengeTitle_lite.isEmpty || challengeDescription_lite.isEmpty || selectedItem_lite == nil) ? 0.5 : 1.0)
                    }
                    .padding(20.w_lite)
                }
            }
            .navigationTitle("New Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss_lite()
                    }
                }
            }
        }
    }
    
    private func createChallenge_lite() {
        guard let selectedItem_lite = selectedItem_lite else { return }
        
        titleVM_lite.createChallenge_lite(
            title_lite: challengeTitle_lite,
            description_lite: challengeDescription_lite,
            baseItem_lite: selectedItem_lite,
            endDate_lite: endDate_lite
        )
        
        dismiss_lite()
    }
}

// MARK: - 创建时光胶囊视图

/// 创建时光胶囊视图
struct CreateCapsuleView_lite: View {
    
    @Environment(\.dismiss) private var dismiss_lite
    @ObservedObject private var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject private var localData_lite = LocalData_lite.shared_lite
    
    @State private var selectedOutfit_lite: OutfitCombo_lite?
    @State private var thoughtNote_lite = ""
    @State private var unlockDate_lite = Date().addingTimeInterval(365 * 24 * 60 * 60)
    
    var body: some View {
        NavigationView {
            ZStack {
                // 动态渐变背景
                LinearGradient(
                    colors: [
                        Color(hex: "f093fb").opacity(0.1),
                        Color(hex: "f5576c").opacity(0.05),
                        Color(hex: "F8F9FA")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28.h_lite) {
                        // 选择穿搭 - 增强版
                        VStack(alignment: .leading, spacing: 12.h_lite) {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "f093fb"))
                                
                                Text("Select Outfit")
                                    .font(.system(size: 15.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "495057"))
                                
                                if selectedOutfit_lite != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14.sp_lite))
                                        .foregroundColor(Color(hex: "43e97b"))
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14.w_lite) {
                                    ForEach(localData_lite.outfitComboList_lite.prefix(5)) { outfit_lite in
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedOutfit_lite = outfit_lite
                                            }
                                        } label: {
                                            VStack(alignment: .leading, spacing: 12.h_lite) {
                                                // 单品图标 - 增强版
                                                HStack(spacing: 6.w_lite) {
                                                    ForEach(outfit_lite.items_lite.prefix(3)) { item_lite in
                                                        ZStack {
                                                            Circle()
                                                                .fill(
                                                                    LinearGradient(
                                                                        colors: MediaConfig_lite.getGradientColors_lite(for: item_lite.itemName_lite),
                                                                        startPoint: .topLeading,
                                                                        endPoint: .bottomTrailing
                                                                    )
                                                                )
                                                                .frame(width: 38.w_lite, height: 38.h_lite)
                                                            
                                                            Image(systemName: item_lite.itemImage_lite)
                                                                .font(.system(size: 18.sp_lite, weight: .bold))
                                                                .foregroundColor(.white)
                                                        }
                                                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                                                    }
                                                }
                                                .padding(.top, 4.h_lite)
                                                
                                                Text(outfit_lite.comboTitle_lite)
                                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                                    .foregroundColor(Color(hex: "212529"))
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.leading)
                                                
                                                // 选中标记
                                                if selectedOutfit_lite?.comboId_lite == outfit_lite.comboId_lite {
                                                    HStack(spacing: 4.w_lite) {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .font(.system(size: 12.sp_lite))
                                                            .foregroundColor(Color(hex: "43e97b"))
                                                        
                                                        Text("Selected")
                                                            .font(.system(size: 11.sp_lite, weight: .bold))
                                                            .foregroundColor(Color(hex: "43e97b"))
                                                    }
                                                    .padding(.horizontal, 8.w_lite)
                                                    .padding(.vertical, 4.h_lite)
                                                    .background(Color(hex: "43e97b").opacity(0.15))
                                                    .cornerRadius(8.w_lite)
                                                }
                                            }
                                            .padding(14.w_lite)
                                            .frame(width: 150.w_lite, height: 130.h_lite, alignment: .topLeading)
                                            .background(
                                                ZStack {
                                                    if selectedOutfit_lite?.comboId_lite == outfit_lite.comboId_lite {
                                                        LinearGradient(
                                                            colors: [Color(hex: "f093fb").opacity(0.1), Color.white],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    } else {
                                                        Color.white
                                                    }
                                                }
                                            )
                                            .cornerRadius(16.w_lite)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16.w_lite)
                                                    .stroke(
                                                        selectedOutfit_lite?.comboId_lite == outfit_lite.comboId_lite ?
                                                            Color(hex: "f093fb") :
                                                            Color(hex: "E9ECEF"),
                                                        lineWidth: selectedOutfit_lite?.comboId_lite == outfit_lite.comboId_lite ? 2 : 1.5
                                                    )
                                            )
                                            .shadow(
                                                color: selectedOutfit_lite?.comboId_lite == outfit_lite.comboId_lite ?
                                                    Color(hex: "f093fb").opacity(0.3) :
                                                    Color.black.opacity(0.05),
                                                radius: selectedOutfit_lite?.comboId_lite == outfit_lite.comboId_lite ? 12 : 6,
                                                x: 0,
                                                y: 4
                                            )
                                        }
                                        .buttonStyle(ScaleButtonStyle_lite())
                                    }
                                }
                                .padding(.horizontal, 4.w_lite)
                                .padding(.vertical, 8.h_lite)
                            }
                        }
                        
                        // 心得输入 - 增强版
                        VStack(alignment: .leading, spacing: 10.h_lite) {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "quote.bubble")
                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "f093fb"))
                                
                                Text("Your Thoughts")
                                    .font(.system(size: 15.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "495057"))
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if thoughtNote_lite.isEmpty {
                                    Text("Write your current feelings about this outfit...")
                                        .font(.system(size: 16.sp_lite))
                                        .foregroundColor(Color(hex: "ADB5BD"))
                                        .padding(.horizontal, 12.w_lite)
                                        .padding(.vertical, 18.h_lite)
                                }
                                
                                TextEditor(text: $thoughtNote_lite)
                                    .font(.system(size: 16.sp_lite, weight: .medium))
                                    .frame(height: 130.h_lite)
                                    .padding(.horizontal, 8.w_lite)
                                    .padding(.vertical, 12.h_lite)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14.w_lite)
                                        .fill(Color.white)
                                    
                                    RoundedRectangle(cornerRadius: 14.w_lite)
                                        .stroke(
                                            thoughtNote_lite.isEmpty ?
                                                Color(hex: "E9ECEF") :
                                                Color(hex: "f093fb").opacity(0.3),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                        
                        // 解锁日期 - 增强版
                        VStack(alignment: .leading, spacing: 10.h_lite) {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "lock.shield")
                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "f093fb"))
                                
                                Text("Unlock Date")
                                    .font(.system(size: 15.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "495057"))
                            }
                            
                            DatePicker("", selection: $unlockDate_lite, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding(18.w_lite)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16.w_lite)
                                            .fill(Color.white)
                                        
                                        RoundedRectangle(cornerRadius: 16.w_lite)
                                            .stroke(Color(hex: "E9ECEF"), lineWidth: 1.5)
                                    }
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        }
                        
                        // 创建按钮 - 增强版
                        Button {
                            createCapsule_lite()
                        } label: {
                            HStack(spacing: 10.w_lite) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 20.sp_lite, weight: .bold))
                                
                                Text("Seal Capsule")
                                    .font(.system(size: 17.sp_lite, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18.h_lite)
                            .background(
                                ZStack {
                                    LinearGradient(
                                        colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    
                                    // 高光效果
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            )
                            .cornerRadius(18.w_lite)
                            .shadow(color: Color(hex: "f093fb").opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        .buttonStyle(ScaleButtonStyle_lite())
                        .disabled(selectedOutfit_lite == nil || thoughtNote_lite.isEmpty)
                        .opacity((selectedOutfit_lite == nil || thoughtNote_lite.isEmpty) ? 0.5 : 1.0)
                    }
                    .padding(20.w_lite)
                }
            }
            .navigationTitle("New Capsule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss_lite()
                    }
                }
            }
        }
    }
    
    private func createCapsule_lite() {
        guard let selectedOutfit_lite = selectedOutfit_lite else { return }
        
        titleVM_lite.createCapsule_lite(
            outfit_lite: selectedOutfit_lite,
            thoughtNote_lite: thoughtNote_lite,
            unlockDate_lite: unlockDate_lite
        )
        
        dismiss_lite()
    }
}

// MARK: - 瀑布流布局组件

/// 瀑布流帖子网格 - 性能优化版
struct WaterfallPostsGrid_lite: View {
    
    let posts_lite: [TitleModel_lite]
    
    // 缓存分组结果，避免每次重新计算
    private var leftPosts_lite: [TitleModel_lite] {
        posts_lite.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
    }
    
    private var rightPosts_lite: [TitleModel_lite] {
        posts_lite.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12.w_lite) {
            // 左列 - 使用LazyVStack提高性能
            LazyVStack(spacing: 12.h_lite, pinnedViews: []) {
                ForEach(leftPosts_lite) { post_lite in
                    WaterfallPostCard_lite(post_lite: post_lite)
                        .id(post_lite.titleId_lite) // 添加ID确保视图复用
                }
            }
            
            // 右列 - 使用LazyVStack提高性能
            LazyVStack(spacing: 12.h_lite, pinnedViews: []) {
                ForEach(rightPosts_lite) { post_lite in
                    WaterfallPostCard_lite(post_lite: post_lite)
                        .id(post_lite.titleId_lite) // 添加ID确保视图复用
                }
            }
        }
    }
}

/// 瀑布流帖子卡片 - 性能优化版
struct WaterfallPostCard_lite: View {
    
    let post_lite: TitleModel_lite
    
    // 使用固定高度，避免onAppear中的随机计算导致重绘
    private var imageHeight_lite: CGFloat {
        let baseHeight_lite: CGFloat = 160
        let variation_lite: CGFloat = CGFloat((post_lite.titleId_lite * 17) % 140)
        return baseHeight_lite + variation_lite
    }
    
    var body: some View {
        Button {
            // 点击跳转到帖子详情页
            Router_lite.shared_lite.toPostDetail_liteui(post_lite: post_lite)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // 图片区域 - 使用MediaDisplayView_lite组件
                ZStack(alignment: .topTrailing) {
                    // 媒体展示
                    if let mediaPath_lite = post_lite.titleMeidas_lite.first {
                        MediaDisplayView_lite(
                            mediaPath_lite: mediaPath_lite,
                            isVideo_lite: mediaPath_lite.contains("video"),
                            cornerRadius_lite: 12
                        )
                        .frame(height: imageHeight_lite)
                        .clipped()
                    } else {
                        // 无媒体时显示渐变占位
                        ZStack {
                            LinearGradient(
                                colors: getGradientForPost_lite(),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // 装饰性光斑
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 60.w_lite, height: 60.h_lite)
                                .blur(radius: 20)
                                .offset(x: -20.w_lite, y: -30.h_lite)
                            
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 40.w_lite, height: 40.h_lite)
                                .blur(radius: 15)
                                .offset(x: 40.w_lite, y: 30.h_lite)
                        }
                        .frame(height: imageHeight_lite)
                        .cornerRadius(12.w_lite)
                    }
                    
                    // 点赞标记
                    HStack(spacing: 4.w_lite) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10.sp_lite, weight: .bold))
                        
                        Text("\(post_lite.likes_lite)")
                            .font(.system(size: 11.sp_lite, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8.w_lite)
                    .padding(.vertical, 4.h_lite)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.5))
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .padding(10.w_lite)
                }
                
                // 信息区域
                VStack(alignment: .leading, spacing: 8.h_lite) {
                    Text(post_lite.title_lite)
                        .font(.system(size: 14.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "212529"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 6.w_lite) {
                        // 用户头像 - 使用UserAvatarView_lite组件
                        UserAvatarView_lite(
                            userId_lite: post_lite.titleUserId_lite,
                            size_lite: 20
                        )
                        
                        Text(post_lite.titleUserName_lite)
                            .font(.system(size: 12.sp_lite, weight: .semibold))
                            .foregroundColor(Color(hex: "6C757D"))
                        
                        Spacer()
                        
                        // 评论数
                        HStack(spacing: 3.w_lite) {
                            Image(systemName: "bubble.right.fill")
                                .font(.system(size: 10.sp_lite))
                            
                            Text("\(post_lite.reviews_lite.count)")
                                .font(.system(size: 11.sp_lite, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "ADB5BD"))
                    }
                }
                .padding(12.w_lite)
            }
            .background(
                ZStack {
                    Color.white
                    
                    // 微妙的渐变效果
                    LinearGradient(
                        colors: [Color.white, Color(hex: "F8F9FA")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .cornerRadius(16.w_lite)
            .overlay(
                RoundedRectangle(cornerRadius: 16.w_lite)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "E9ECEF"), Color(hex: "F8F9FA")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(ScaleButtonStyle_lite())
    }
    
    /// 根据帖子ID生成渐变色
    private func getGradientForPost_lite() -> [Color] {
        let gradients_lite: [[Color]] = [
            [Color(hex: "667eea"), Color(hex: "764ba2")],
            [Color(hex: "f093fb"), Color(hex: "f5576c")],
            [Color(hex: "4facfe"), Color(hex: "00f2fe")],
            [Color(hex: "43e97b"), Color(hex: "38f9d7")],
            [Color(hex: "fa709a"), Color(hex: "fee140")],
            [Color(hex: "30cfd0"), Color(hex: "330867")],
            [Color(hex: "a8edea"), Color(hex: "fed6e3")],
            [Color(hex: "ff9a9e"), Color(hex: "fecfef")],
            [Color(hex: "ffecd2"), Color(hex: "fcb69f")],
            [Color(hex: "ff6e7f"), Color(hex: "bfe9ff")],
        ]
        
        let index_lite = post_lite.titleId_lite % gradients_lite.count
        return gradients_lite[index_lite]
    }
}

// MARK: - 动态背景组件

/// 发现页动态渐变背景
struct AnimatedDiscoverBackground_lite: View {
    
    @State private var animateGradient_lite = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "f093fb"),
                Color(hex: "f5576c"),
                Color(hex: "667eea"),
                Color(hex: "f093fb")
            ],
            startPoint: animateGradient_lite ? .topLeading : .bottomLeading,
            endPoint: animateGradient_lite ? .bottomTrailing : .topTrailing
        )
        .opacity(0.12)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animateGradient_lite.toggle()
            }
        }
    }
}

/// 发现页浮动装饰元素 - 性能优化版（减少元素和动画）
struct FloatingDiscoverElements_lite: View {
    
    @State private var animate1_lite = false
    @State private var animate2_lite = false
    
    var body: some View {
        ZStack {
            // 元素1 - 挑战主题
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "667eea").opacity(0.2), Color(hex: "764ba2").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200.w_lite, height: 200.h_lite)
                .blur(radius: 40)
                .offset(
                    x: animate1_lite ? -20.w_lite : 20.w_lite,
                    y: animate1_lite ? -60.h_lite : -30.h_lite
                )
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate1_lite)
            
            // 元素2 - 胶囊主题
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "f093fb").opacity(0.2), Color(hex: "f5576c").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 220.w_lite, height: 220.h_lite)
                .blur(radius: 45)
                .offset(
                    x: animate2_lite ? UIScreen.main.bounds.width - 100.w_lite : UIScreen.main.bounds.width - 150.w_lite,
                    y: animate2_lite ? UIScreen.main.bounds.height - 200.h_lite : UIScreen.main.bounds.height - 260.h_lite
                )
                .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate2_lite)
        }
        .onAppear {
            animate1_lite = true
            animate2_lite = true
        }
    }
}
