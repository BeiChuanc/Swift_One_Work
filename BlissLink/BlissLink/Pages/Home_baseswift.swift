import SwiftUI

// MARK: - 首页
// 核心作用：专属瑜伽垫空间 - 展示个人练习数据、徽章、好友动态、纪念贴纸
// 设计思路：私密场景化设计、可自定义背景、支持串门功能
// 关键功能：背景切换、徽章展示、好友动态、纪念贴纸、核心数据统计

/// 首页
struct Home_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var titleVM_baseswiftui = TitleViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var practiceVM_blisslink = PracticeViewModel_blisslink.shared_blisslink
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var localData_baseswiftui = LocalData_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    // MARK: - 状态
    
    @State private var showBackgroundSelector_blisslink: Bool = false
    @State private var showBadgeDetail_blisslink: Bool = false
    @State private var selectedBadge_blisslink: MeditationBadge_blisslink?
    @State private var showAddMemory_blisslink: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 瑜伽垫背景
            yogaMatBackground_blisslink
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20.h_baseswiftui) {
                    // 顶部控制栏
                    topControlBar_blisslink
                    
                    // 瑜伽垫主区域
                    yogaMatMainArea_blisslink
                    
                    // 核心数据卡片
                    coreStatsCard_blisslink
                    
                    // 好友瑜伽垫动态
                    friendActivitiesSection_blisslink
                    
                    // 底部间距
                    Spacer()
                        .frame(height: 100.h_baseswiftui)
                }
                .padding(.top, 60.h_baseswiftui)
            }
            
            // 背景选择器（Sheet）
            if showBackgroundSelector_blisslink {
                VStack {
                    Spacer()
                    BackgroundSelector_blisslink(
                        selectedBackground_blisslink: Binding(
                            get: { userVM_baseswiftui.getCurrentYogaMatBackground_blisslink() },
                            set: { userVM_baseswiftui.changeYogaMatBackground_blisslink(background_blisslink: $0) }
                        ),
                        isShowing_blisslink: $showBackgroundSelector_blisslink
                    )
                    .transition(.move(edge: .bottom))
                }
                .background(Color.black.opacity(0.4).ignoresSafeArea())
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showBackgroundSelector_blisslink = false
                    }
                }
            }
            
            // 徽章详情弹窗
            if showBadgeDetail_blisslink, let badge_blisslink = selectedBadge_blisslink {
                BadgeDetailView_blisslink(
                    badge_blisslink: badge_blisslink,
                    onDismiss_blisslink: {
                        withAnimation {
                            showBadgeDetail_blisslink = false
                            selectedBadge_blisslink = nil
                        }
                    }
                )
                .ignoresSafeArea(.all)
                .transition(.scale.combined(with: .opacity))
            }
            
            // 添加纪念Sheet
            if showAddMemory_blisslink {
                Color.clear
                    .sheet(isPresented: $showAddMemory_blisslink) {
                        AddMemorySheet_blisslink(
                            onDismiss_blisslink: {
                                showAddMemory_blisslink = false
                            },
                            onAdd_blisslink: { sticker_blisslink in
                                userVM_baseswiftui.addMemorySticker_blisslink(sticker_blisslink: sticker_blisslink)
                            },
                            existingStickers_blisslink: userVM_baseswiftui.getMemoryStickers_blisslink()
                        )
                    }
            }
        }
        .onAppear {
            initializeData_blisslink()
        }
    }
    
    // MARK: - 瑜伽垫背景
    
    private var yogaMatBackground_blisslink: some View {
        LinearGradient(
            gradient: Gradient(colors: userVM_baseswiftui.getCurrentYogaMatBackground_blisslink().gradientColors_blisslink),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // 图案装饰
            Image(systemName: userVM_baseswiftui.getCurrentYogaMatBackground_blisslink().iconName_blisslink)
                .font(.system(size: 200.sp_baseswiftui, weight: .thin))
                .foregroundColor(.white.opacity(0.08))
                .offset(x: 50.w_baseswiftui, y: -100.h_baseswiftui)
        )
    }
    
    // MARK: - 顶部控制栏
    
    private var topControlBar_blisslink: some View {
        HStack {
            // 用户信息
            VStack(alignment: .leading, spacing: 4.h_baseswiftui) {
                Text(greetingText_blisslink)
                    .font(.system(size: 20.sp_baseswiftui, weight: .bold))
                    .foregroundColor(currentBackground_blisslink.textColor_blisslink)
                
                Text("My Yoga Mat")
                    .font(.system(size: 14.sp_baseswiftui, weight: .medium))
                    .foregroundColor(currentBackground_blisslink.secondaryTextColor_blisslink)
            }
            .slideIn_blisslink(from: .top, delay_blisslink: 0.1)
            
            Spacer()
            
            // 背景设置按钮
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
                    showBackgroundSelector_blisslink = true
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 44.w_baseswiftui, height: 44.h_baseswiftui)
                    
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 20.sp_baseswiftui))
                        .foregroundColor(currentBackground_blisslink.textColor_blisslink)
                }
            }
            .bounceIn_blisslink(delay_blisslink: 0.2)
        }
        .padding(.horizontal, 20.w_baseswiftui)
    }
    
    // MARK: - 瑜伽垫主区域
    
    private var yogaMatMainArea_blisslink: some View {
        let hasStickers_blisslink = !userVM_baseswiftui.getMemoryStickers_blisslink().isEmpty
        let matHeight_blisslink = hasStickers_blisslink ? APPSCREEN_baseswift.WIDTH_baseswift * 1.3 : 150.h_baseswiftui
        
        return GeometryReader { geometry_blisslink in
            ZStack {
                // 瑜伽垫卡片背景
                RoundedRectangle(cornerRadius: 24.w_baseswiftui)
                    .fill(Color.white.opacity(0.15))
                    .blur(radius: 30)
                    .frame(height: hasStickers_blisslink ? geometry_blisslink.size.width * 1.3 : 150.h_baseswiftui)
                
                // 纪念贴纸层
                ForEach(userVM_baseswiftui.getMemoryStickers_blisslink()) { sticker_blisslink in
                    MemoryStickerView_blisslink(
                        sticker_blisslink: sticker_blisslink,
                        containerSize_blisslink: CGSize(
                            width: geometry_blisslink.size.width,
                            height: geometry_blisslink.size.width * 1.3
                        ),
                        onTap_blisslink: {
                            print("📸 查看纪念：\(sticker_blisslink.title_blisslink)")
                        }
                    )
                }
                
                // 添加纪念贴纸按钮
                if userVM_baseswiftui.getMemoryStickers_blisslink().count < 5 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            AddMemoryStickerButton_blisslink {
                                handleAddMemory_blisslink()
                            }
                            .padding(20.w_baseswiftui)
                        }
                    }
                    .frame(height: hasStickers_blisslink ? geometry_blisslink.size.width * 1.3 : 150.h_baseswiftui)
                }
            }
        }
        .frame(height: matHeight_blisslink)
        .padding(.horizontal, 20.w_baseswiftui)
        .bounceIn_blisslink(delay_blisslink: 0.3)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hasStickers_blisslink)
    }
    
    // MARK: - 核心数据卡片
    
    private var coreStatsCard_blisslink: some View {
        VStack(spacing: 16.h_baseswiftui) {
            // 标题
            HStack {
                Text("My Progress")
                    .font(.system(size: 20.sp_baseswiftui, weight: .bold))
                    .foregroundColor(currentBackground_blisslink.textColor_blisslink)
                
                Spacer()
            }
            .padding(.horizontal, 20.w_baseswiftui)
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.4)
            
            // 数据卡片
            if let stats_blisslink = practiceVM_blisslink.getPracticeStats_blisslink() {
                VStack(spacing: 16.h_baseswiftui) {
                    // 累计练习时长
                    dataRow_blisslink(
                        icon_blisslink: "clock.fill",
                        title_blisslink: "Total Practice",
                        value_blisslink: "\(stats_blisslink.totalDuration_blisslink) min",
                        gradient_blisslink: [Color(hex: "F2994A"), Color(hex: "F2C94C")]
                    )
                    .slideIn_blisslink(from: .bottom, delay_blisslink: 0.5)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    // 连续打卡天数
                    dataRow_blisslink(
                        icon_blisslink: "flame.fill",
                        title_blisslink: "Streak Days",
                        value_blisslink: "\(stats_blisslink.streakDays_blisslink) days",
                        gradient_blisslink: [Color(hex: "FF6B6B"), Color(hex: "FFE66D")]
                    )
                    .slideIn_blisslink(from: .bottom, delay_blisslink: 0.6)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    // 本周练习次数
                    dataRow_blisslink(
                        icon_blisslink: "checkmark.circle.fill",
                        title_blisslink: "This Week",
                        value_blisslink: "\(stats_blisslink.weeklySessionCount_blisslink) sessions",
                        gradient_blisslink: [Color(hex: "56CCF2"), Color(hex: "2F80ED")]
                    )
                    .slideIn_blisslink(from: .bottom, delay_blisslink: 0.7)
                }
                .padding(20.w_baseswiftui)
                .background(
                    RoundedRectangle(cornerRadius: 20.w_baseswiftui)
                        .fill(Color.white.opacity(0.25))
                        .blur(radius: 20)
                )
                .padding(.horizontal, 20.w_baseswiftui)
            }
            
            // 获得的徽章
            badgesSection_blisslink
        }
    }
    
    /// 数据行
    private func dataRow_blisslink(icon_blisslink: String, title_blisslink: String, value_blisslink: String, gradient_blisslink: [Color]) -> some View {
        HStack {
            // 图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradient_blisslink),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40.w_baseswiftui, height: 40.h_baseswiftui)
                
                Image(systemName: icon_blisslink)
                    .font(.system(size: 20.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // 标题
            Text(title_blisslink)
                .font(.system(size: 15.sp_baseswiftui, weight: .medium))
                .foregroundColor(currentBackground_blisslink.secondaryTextColor_blisslink)
            
            Spacer()
            
            // 数值
            Text(value_blisslink)
                .font(.system(size: 16.sp_baseswiftui, weight: .bold))
                .foregroundColor(currentBackground_blisslink.textColor_blisslink)
                .monospacedDigit()
        }
    }
    
    /// 徽章区域
    private var badgesSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_baseswiftui) {
            HStack {
                Text("Meditation Badges")
                    .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                    .foregroundColor(currentBackground_blisslink.textColor_blisslink)
                
                Spacer()
                
                Text("\(getUnlockedBadgeCount_blisslink())/\(localData_baseswiftui.badgeList_blisslink.count)")
                    .font(.system(size: 14.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(currentBackground_blisslink.secondaryTextColor_blisslink)
            }
            .padding(.horizontal, 20.w_baseswiftui)
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.8)
            
            // 徽章列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16.w_baseswiftui) {
                    ForEach(Array(localData_baseswiftui.badgeList_blisslink.prefix(5).enumerated()), id: \.element.id) { index_blisslink, badge_blisslink in
                        BadgeView_blisslink(
                            badge_blisslink: badge_blisslink,
                            size_blisslink: 60.w_baseswiftui,
                            showName_blisslink: true,
                            onTap_blisslink: {
                                selectedBadge_blisslink = badge_blisslink
                                withAnimation {
                                    showBadgeDetail_blisslink = true
                                }
                            }
                        )
                        .bounceIn_blisslink(delay_blisslink: 0.9 + Double(index_blisslink) * 0.08)
                    }
                }
                .padding(.horizontal, 20.w_baseswiftui)
            }
        }
    }
    
    private var friendActivitiesSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_baseswiftui) {
            // 标题
            HStack {
                Text("Friends' Mats")
                    .font(.system(size: 20.sp_baseswiftui, weight: .bold))
                    .foregroundColor(currentBackground_blisslink.textColor_blisslink)
                
                Spacer()
                
                Button(action: {
                    // 查看所有好友
                }) {
                    Text("See All")
                        .font(.system(size: 14.sp_baseswiftui, weight: .semibold))
                        .foregroundColor(currentBackground_blisslink.secondaryTextColor_blisslink)
                }
            }
            .padding(.horizontal, 20.w_baseswiftui)
            .slideIn_blisslink(from: .bottom, delay_blisslink: 1.1)
            
            // 好友动态列表
            VStack(spacing: 12.h_baseswiftui) {
                ForEach(Array(localData_baseswiftui.friendActivities_blisslink.prefix(3).enumerated()), id: \.element.id) { index_blisslink, activity_blisslink in
                    FriendActivityCard_blisslink(
                        activity_blisslink: activity_blisslink,
                        onTap_blisslink: {
                            handleFriendTap_blisslink(activity_blisslink)
                        }
                    )
                    .slideIn_blisslink(from: .bottom, delay_blisslink: 1.2 + Double(index_blisslink) * 0.1)
                }
            }
            .padding(.horizontal, 20.w_baseswiftui)
        }
    }
    
    // MARK: - 计算属性
    
    /// 当前背景
    private var currentBackground_blisslink: YogaMatBackground_blisslink {
        return userVM_baseswiftui.getCurrentYogaMatBackground_blisslink()
    }
    
    /// 根据时间返回问候语
    private var greetingText_blisslink: String {
        let hour_blisslink = Calendar.current.component(.hour, from: Date())
        
        switch hour_blisslink {
        case 5..<12:
            return "Good Morning"
        case 12..<18:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
    
    /// 获取已解锁徽章数量
    private func getUnlockedBadgeCount_blisslink() -> Int {
        return localData_baseswiftui.badgeList_blisslink.filter { $0.isUnlocked_blisslink }.count
    }
    
    // MARK: - 事件处理
    
    /// 初始化数据
    private func initializeData_blisslink() {
        practiceVM_blisslink.initPracticeData_blisslink()
    }
    
    /// 处理好友点击（串门）
    private func handleFriendTap_blisslink(_ activity_blisslink: FriendActivity_blisslink) {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        // 找到对应的好友信息
        if let friend_blisslink = localData_baseswiftui.userList_baseswiftui.first(where: { $0.userId_baseswiftui == activity_blisslink.friendUserId_blisslink }) {
            // 跳转到好友信息页（串门）
            router_baseswiftui.toUserInfo_baseswiftui(user_baseswiftui: friend_blisslink)
            
            Utils_baseswiftui.showSuccess_baseswiftui(
                message_baseswiftui: "Visiting \(activity_blisslink.friendName_blisslink)'s mat",
                image_baseswiftui: UIImage(systemName: "figure.walk")
            )
        }
        
        print("🚪 串门到：\(activity_blisslink.friendName_blisslink)")
    }
    
    /// 处理添加纪念贴纸
    private func handleAddMemory_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        // 显示添加纪念Sheet
        showAddMemory_blisslink = true
        
        print("📸 打开添加纪念贴纸")
    }
}
