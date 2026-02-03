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
    @State private var showMemoryDetail_blisslink: Bool = false
    @State private var selectedMemory_blisslink: MemorySticker_blisslink?
    
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
                }
                .padding(.top, 60.h_baseswiftui)
                .padding(.bottom, 100.h_baseswiftui)
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
            
            // 纪念贴纸放大查看
            if showMemoryDetail_blisslink, let memory_blisslink = selectedMemory_blisslink {
                MemoryDetailView_blisslink(
                    sticker_blisslink: memory_blisslink,
                    isShowing_blisslink: $showMemoryDetail_blisslink
                )
                .ignoresSafeArea()
                .transition(.scale.combined(with: .opacity))
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
                
                Text(userVM_baseswiftui.getCurrentUser_baseswiftui().userName_baseswiftui ?? "Guest")
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
                            handleMemoryTap_blisslink(sticker_blisslink)
                        },
                        onDelete_blisslink: {
                            handleDeleteMemory_blisslink(sticker_blisslink)
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
            // 标题和跳转按钮
            HStack {
                Text("My Progress")
                    .font(.system(size: 20.sp_baseswiftui, weight: .bold))
                    .foregroundColor(currentBackground_blisslink.textColor_blisslink)
                
                Spacer()
                
                // 跳转到计时页面按钮
                Button(action: {
                    handleTimerTap_blisslink()
                }) {
                    HStack(spacing: 6.w_baseswiftui) {
                        Image(systemName: "timer")
                            .font(.system(size: 14.sp_baseswiftui, weight: .semibold))
                        
                        Text("Start")
                            .font(.system(size: 14.sp_baseswiftui, weight: .bold))
                    }
                    .foregroundColor(currentBackground_blisslink.textColor_blisslink)
                    .padding(.horizontal, 16.w_baseswiftui)
                    .padding(.vertical, 8.h_baseswiftui)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                    )
                }
            }
            .padding(.horizontal, 20.w_baseswiftui)
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.4)
            
            // 数据卡片 - 累计练习时长
            dataRow_blisslink(
                icon_blisslink: "clock.fill",
                title_blisslink: "Total Practice",
                value_blisslink: "\(totalPracticeDuration_blisslink) min",
                gradient_blisslink: [Color(hex: "F2994A"), Color(hex: "F2C94C")]
            )
            .padding(20.w_baseswiftui)
            .background(
                RoundedRectangle(cornerRadius: 20.w_baseswiftui)
                    .fill(Color.white.opacity(0.25))
                    .blur(radius: 20)
            )
            .padding(.horizontal, 20.w_baseswiftui)
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.5)
            
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
    
    /// 总练习时长（未登录为0，登录后显示真实数据）
    private var totalPracticeDuration_blisslink: Int {
        if userVM_baseswiftui.isLoggedIn_baseswiftui {
            return practiceVM_blisslink.getPracticeStats_blisslink()?.totalDuration_blisslink ?? 0
        } else {
            return 0
        }
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
    
    /// 处理计时器点击
    private func handleTimerTap_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        // 跳转到计时页面
        router_baseswiftui.navigate_baseswiftui(to: .practiceTimer_blisslink)
        
        print("⏱️ 打开计时页面")
    }
    
    /// 处理纪念贴纸点击（放大查看）
    private func handleMemoryTap_blisslink(_ sticker_blisslink: MemorySticker_blisslink) {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 设置选中的纪念贴纸并显示放大视图
        selectedMemory_blisslink = sticker_blisslink
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showMemoryDetail_blisslink = true
        }
        
        print("📸 查看纪念：\(sticker_blisslink.title_blisslink)")
    }
    
    /// 处理删除纪念贴
    private func handleDeleteMemory_blisslink(_ sticker_blisslink: MemorySticker_blisslink) {
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        // 从用户数据中移除
        userVM_baseswiftui.deleteMemorySticker_blisslink(sticker_blisslink: sticker_blisslink)
        
        print("🗑️ 删除纪念贴：\(sticker_blisslink.title_blisslink)")
    }
}

// MARK: - 纪念贴纸放大查看组件

/// 纪念贴纸放大查看视图
/// 核心作用：全屏展示纪念贴纸的照片和详细信息
/// 设计思路：沉浸式查看体验，支持缩放和关闭
struct MemoryDetailView_blisslink: View {
    
    // MARK: - 属性
    
    /// 贴纸数据
    let sticker_blisslink: MemorySticker_blisslink
    
    /// 是否显示
    @Binding var isShowing_blisslink: Bool
    
    /// 缩放比例
    @State private var scale_blisslink: CGFloat = 1.0
    @State private var lastScale_blisslink: CGFloat = 1.0
    
    /// 偏移量
    @State private var offset_blisslink: CGSize = .zero
    @State private var lastOffset_blisslink: CGSize = .zero
    
    /// 加载的图片
    @State private var loadedImage_blisslink: UIImage?
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景（半透明黑色）
            Color.black.opacity(0.95)
                .ignoresSafeArea()
                .onTapGesture {
                    handleClose_blisslink()
                }
            
            // 图片展示
            if let image_blisslink = loadedImage_blisslink {
                Image(uiImage: image_blisslink)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(scale_blisslink)
                    .offset(offset_blisslink)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value_blisslink in
                                scale_blisslink = lastScale_blisslink * value_blisslink
                            }
                            .onEnded { _ in
                                // 限制缩放范围
                                if scale_blisslink < 1.0 {
                                    withAnimation(.spring()) {
                                        scale_blisslink = 1.0
                                    }
                                } else if scale_blisslink > 5.0 {
                                    scale_blisslink = 5.0
                                }
                                lastScale_blisslink = scale_blisslink
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value_blisslink in
                                offset_blisslink = CGSize(
                                    width: lastOffset_blisslink.width + value_blisslink.translation.width,
                                    height: lastOffset_blisslink.height + value_blisslink.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset_blisslink = offset_blisslink
                            }
                    )
                    .onTapGesture(count: 2) {
                        // 双击重置缩放
                        withAnimation(.spring()) {
                            scale_blisslink = 1.0
                            lastScale_blisslink = 1.0
                            offset_blisslink = .zero
                            lastOffset_blisslink = .zero
                        }
                    }
            } else {
                // 加载中占位符
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
            
            // 顶部信息栏
            VStack {
                HStack {
                    // 标题和日期
                    VStack(alignment: .leading, spacing: 4.h_baseswiftui) {
                        Text(sticker_blisslink.title_blisslink)
                            .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(formatDate_blisslink(sticker_blisslink.memoryDate_blisslink))
                            .font(.system(size: 14.sp_baseswiftui, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // 关闭按钮
                    Button(action: {
                        handleClose_blisslink()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 44.w_baseswiftui, height: 44.h_baseswiftui)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20.w_baseswiftui)
                .padding(.top, 50.h_baseswiftui)
                
                Spacer()
            }
        }
        .onAppear {
            loadImage_blisslink()
        }
    }
    
    // MARK: - 辅助方法
    
    /// 加载图片
    private func loadImage_blisslink() {
        // 先尝试从 Assets 加载
        if let image_blisslink = UIImage(named: sticker_blisslink.photoUrl_blisslink) {
            loadedImage_blisslink = image_blisslink
            return
        }
        
        // 如果 Assets 中没有，尝试从文档目录加载
        let fileManager_blisslink = FileManager.default
        guard let documentsDirectory_blisslink = fileManager_blisslink.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent("\(sticker_blisslink.photoUrl_blisslink).jpg")
        
        if let image_blisslink = UIImage(contentsOfFile: fileURL_blisslink.path) {
            loadedImage_blisslink = image_blisslink
        }
    }
    
    /// 格式化日期
    private func formatDate_blisslink(_ date: Date) -> String {
        let formatter_blisslink = DateFormatter()
        formatter_blisslink.dateFormat = "MMMM d, yyyy"
        return formatter_blisslink.string(from: date)
    }
    
    /// 处理关闭
    private func handleClose_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isShowing_blisslink = false
        }
    }
}
