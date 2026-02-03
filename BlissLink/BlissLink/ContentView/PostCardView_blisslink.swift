import SwiftUI

// MARK: - 社区动态卡片组件
// 核心作用：展示用户分享的帖子内容
// 设计思路：支持图片展示、点赞评论、练习标签
// 关键属性：帖子数据、交互回调

/// 社区动态卡片视图
struct PostCardView_blisslink: View {
    
    // MARK: - 属性
    
    /// 帖子数据
    let post_blisslink: TitleModel_baseswiftui
    
    /// 点击回调
    var onTap_blisslink: (() -> Void)?
    
    /// 点赞回调
    var onLike_blisslink: (() -> Void)?
    
    /// 评论回调
    var onComment_blisslink: (() -> Void)?
    
    /// 动画状态
    @State private var isPressed_blisslink: Bool = false
    @State private var isLiked_blisslink: Bool = false
    @State private var showReportSheet_blisslink: Bool = false
    @State private var showDeleteAlert_blisslink: Bool = false
    
    /// ViewModels
    @ObservedObject var titleVM_baseswiftui = TitleViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var practiceVM_blisslink = PracticeViewModel_blisslink.shared_blisslink
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    @ObservedObject var localData_baseswiftui = LocalData_baseswiftui.shared_baseswiftui
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.h_baseswiftui) {
            // 用户信息
            userHeader_blisslink
            
            // 帖子内容
            postContent_blisslink
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap_blisslink?()
                }
            
            // 媒体展示（如果有）
            if !post_blisslink.titleMeidas_baseswiftui.isEmpty {
                mediaView_blisslink
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTap_blisslink?()
                    }
            }
            
            // 练习标签（如果是练习成果）
            if let postType_blisslink = post_blisslink.postType_blisslink,
               postType_blisslink == .practiceAchievement_blisslink {
                practiceTag_blisslink
            }
            
            // 交互按钮
            interactionButtons_blisslink
        }
        .padding(16.w_baseswiftui)
        .background(
            RoundedRectangle(cornerRadius: 16.w_baseswiftui)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(isPressed_blisslink ? 0.985 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: isPressed_blisslink)
        .alert("Delete Post", isPresented: $showDeleteAlert_blisslink) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deletePost_blisslink()
            }
        } message: {
            Text("Are you sure you want to delete this post? This action cannot be undone.")
        }
        .onAppear {
            isLiked_blisslink = titleVM_baseswiftui.isLikedPost_baseswiftui(post_baseswiftui: post_blisslink)
        }
    }
    
    // MARK: - 用户头部
    
    private var userHeader_blisslink: some View {
        HStack(spacing: 10.w_baseswiftui) {
            // 用户头像（使用 UserAvatarView 组件）
            UserAvatarView_baseswiftui(
                userId_baseswiftui: post_blisslink.titleUserId_baseswiftui,
                avatarPath_baseswiftui: getUserAvatarPath_blisslink(),
                userName_baseswiftui: post_blisslink.titleUserName_baseswiftui,
                size_baseswiftui: 44.w_baseswiftui,
                isClickable_baseswiftui: true,
                onTapped_baseswiftui: {
                    print("点击头像")
                    handleUserTap_blisslink()
                }
            )
            
            VStack(alignment: .leading, spacing: 2.h_baseswiftui) {
                // 用户名
                Text(post_blisslink.titleUserName_baseswiftui)
                    .font(.system(size: 15.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
                
                // 时间（模拟）
                Text("2 hours ago")
                    .font(.system(size: 12.sp_baseswiftui))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 更多按钮（举报/删除）
            Button(action: {
                handleMoreAction_blisslink()
            }) {
                Image(systemName: isMyPost_blisslink ? "trash" : "ellipsis")
                    .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(isMyPost_blisslink ? 0 : 90))
            }
        }
        .background(
            // 举报ActionSheet
            ReportActionSheet_blisslink(
                isShowing_blisslink: $showReportSheet_blisslink,
                isBlockUser_blisslink: false,
                onConfirm_blisslink: {
                    handleReport_blisslink()
                }
            )
        )
    }
    
    // MARK: - 帖子内容
    
    private var postContent_blisslink: some View {
        VStack(alignment: .leading, spacing: 6.h_baseswiftui) {
            // 标题
            if !post_blisslink.title_baseswiftui.isEmpty {
                Text(post_blisslink.title_baseswiftui)
                    .font(.system(size: 16.sp_baseswiftui, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            // 内容
            Text(post_blisslink.titleContent_baseswiftui)
                .font(.system(size: 14.sp_baseswiftui))
                .foregroundColor(.secondary)
                .lineLimit(4)
        }
    }
    
    // MARK: - 媒体视图
    
    private var mediaView_blisslink: some View {
        Group {
            // 使用 MediaDisplayView 展示媒体
            if let firstMedia_blisslink = post_blisslink.titleMeidas_baseswiftui.first {
                MediaDisplayView_baseswiftui(
                    mediaPath_baseswiftui: firstMedia_blisslink,
                    isVideo_baseswiftui: false,
                    cornerRadius_baseswiftui: 14.w_baseswiftui
                )
            } else {
                // 占位符
                ZStack {
                    RoundedRectangle(cornerRadius: 14.w_baseswiftui)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA").opacity(0.3), Color(hex: "764BA2").opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Image(systemName: "photo.fill")
                        .font(.system(size: 50.sp_baseswiftui))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .frame(height: 220.h_baseswiftui)
        .clipped()
    }
    
    // MARK: - 练习标签
    
    /// 练习成果标签
    /// 核心作用：展示练习成果类型的帖子标识
    private var practiceTag_blisslink: some View {
        HStack(spacing: 8.w_baseswiftui) {
            Image(systemName: "figure.yoga")
                .font(.system(size: 14.sp_baseswiftui))
            
            Text("Practice Achievement")
                .font(.system(size: 13.sp_baseswiftui, weight: .medium))
        }
        .foregroundColor(Color(hex: "667EEA"))
        .padding(.horizontal, 12.w_baseswiftui)
        .padding(.vertical, 6.h_baseswiftui)
        .background(
            Capsule()
                .fill(Color(hex: "667EEA").opacity(0.1))
        )
    }
    
    // MARK: - 交互按钮
    
    private var interactionButtons_blisslink: some View {
        HStack(spacing: 20.w_baseswiftui) {
            // 点赞按钮
            Button(action: {
                handleLike_blisslink()
            }) {
                HStack(spacing: 6.w_baseswiftui) {
                    Image(systemName: isLiked_blisslink ? "heart.fill" : "heart")
                        .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                        .foregroundColor(isLiked_blisslink ? .red : .secondary)
                    
                    Text("\(post_blisslink.likes_baseswiftui)")
                        .font(.system(size: 14.sp_baseswiftui, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .scaleEffect(isLiked_blisslink ? 1.15 : 1.0)
            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: isLiked_blisslink)
            
            // 评论按钮
            Button(action: {
                handleComment_blisslink()
            }) {
                HStack(spacing: 6.w_baseswiftui) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text("\(post_blisslink.reviews_baseswiftui.count)")
                        .font(.system(size: 14.sp_baseswiftui, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.top, 4.h_baseswiftui)
    }
    
    // MARK: - 计算属性
    
    /// 判断是否是自己的帖子
    private var isMyPost_blisslink: Bool {
        return userVM_baseswiftui.isCurrentUser_baseswiftui(userId_baseswiftui: post_blisslink.titleUserId_baseswiftui)
    }
    
    // MARK: - 事件处理
    
    /// 处理点赞
    private func handleLike_blisslink() {
        // 检查是否登录
        if !userVM_baseswiftui.isLoggedIn_baseswiftui {            
            // 延迟跳转到登录页面
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
                Router_baseswiftui.shared_baseswiftui.toLogin_baseswiftui()
            }
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 切换点赞状态
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            isLiked_blisslink.toggle()
        }
        
        // 执行点赞逻辑（内部会再次检查登录状态）
        titleVM_baseswiftui.likePost_baseswiftui(post_baseswiftui: post_blisslink)
        
        // 执行回调
        onLike_blisslink?()
    }
    
    /// 处理评论
    private func handleComment_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 执行回调
        onComment_blisslink?()
    }
    
    /// 处理更多操作（举报/删除）
    private func handleMoreAction_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        if isMyPost_blisslink {
            // 自己的帖子 - 直接删除
            showDeleteConfirmation_blisslink()
        } else {
            // 别人的帖子 - 显示举报菜单
            showReportSheet_blisslink = true
        }
    }
    
    /// 显示删除确认对话框
    /// 核心作用：弹出删除确认对话框，让用户确认是否删除
    private func showDeleteConfirmation_blisslink() {
        showDeleteAlert_blisslink = true
    }
    
    /// 执行删除操作
    /// 核心作用：用户确认后执行实际的删除逻辑
    private func deletePost_blisslink() {
        Utils_baseswiftui.showLoading_baseswiftui(message_baseswiftui: "Deleting...")
        
        ReportHelper_blisslink.deletePost_blisslink(post_blisslink: post_blisslink) {
            Utils_baseswiftui.dismissLoading_baseswiftui()
        }
    }
    
    /// 处理举报
    private func handleReport_blisslink() {
        ReportHelper_blisslink.reportPost_blisslink(post_blisslink: post_blisslink) {}
    }
    
    /// 获取用户头像路径
    /// 核心作用：根据用户ID获取头像，优先检查是否为登录用户
    private func getUserAvatarPath_blisslink() -> String? {
        // 1. 先检查是否是登录用户的帖子
        if isMyPost_blisslink {
            return userVM_baseswiftui.getCurrentUser_baseswiftui().userHead_baseswiftui
        }
        
        // 2. 从预制用户列表中查找
        if let user_blisslink = localData_baseswiftui.userList_baseswiftui.first(where: { 
            $0.userId_baseswiftui == post_blisslink.titleUserId_baseswiftui 
        }) {
            return user_blisslink.userHead_baseswiftui
        }
        
        return nil
    }
    
    /// 处理用户头像点击
    /// 核心作用：点击头像跳转到用户中心，区分登录用户和其他用户
    private func handleUserTap_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 如果是自己的帖子，跳转到个人中心
        if isMyPost_blisslink {
            return
        }
        
        // 查找预制用户信息，跳转到串门页面
        if let user_blisslink = localData_baseswiftui.userList_baseswiftui.first(where: { 
            $0.userId_baseswiftui == post_blisslink.titleUserId_baseswiftui 
        }) {
            // 跳转到用户中心页面
            router_baseswiftui.toUserInfo_baseswiftui(user_baseswiftui: user_blisslink)
        }
    }
}
