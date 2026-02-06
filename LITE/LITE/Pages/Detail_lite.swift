import SwiftUI
import Combine

// MARK: - 帖子详情页
// 核心作用：展示帖子的详细内容、评论和操作
// 设计思路：现代化卡片设计，创意交互，流畅动画
// 关键功能：媒体展示、用户信息、互动操作、评论区

/// 帖子详情页
struct Detail_lite: View {
    
    /// 帖子数据
    let post_lite: TitleModel_lite
    
    @ObservedObject private var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var localData_lite = LocalData_lite.shared_lite
    
    @State private var commentText_lite = ""
    @State private var showGiftShop_lite = false
    @State private var showReportSheet_lite = false
    @State private var showDeleteConfirm_lite = false
    @State private var isLiked_lite = false
    @State private var likeAnimation_lite = false
    @State private var isFollowed_lite = false
    @FocusState private var isCommentFocused_lite: Bool
    
    /// 获取最新的帖子数据
    private var currentPost_lite: TitleModel_lite? {
        localData_lite.titleList_lite.first(where: { $0.titleId_lite == post_lite.titleId_lite })
    }
    
    /// 判断帖子是否为当前登录用户发布
    private var isOwnPost_lite: Bool {
        let currentUserId_lite = userVM_lite.getCurrentUser_lite().userId_lite ?? 0
        return post_lite.titleUserId_lite == currentUserId_lite
    }
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            LinearGradient(
                colors: [
                    Color(hex: "f093fb").opacity(0.03),
                    Color(hex: "667eea").opacity(0.02),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 自定义顶部导航栏
                customHeaderView_lite
                
                // 内容区域
                ScrollView {
                    VStack(spacing: 0) {
                        // 媒体展示区域
                        mediaSection_lite
                        
                        // 主要内容卡片
                        contentCard_lite
                            .padding(.horizontal, 16.w_lite)
                            .padding(.top, -30.h_lite)
                        
                        // 评论区域
                        commentsSection_lite
                            .padding(.top, 20.h_lite)
                            .padding(.bottom, 100.h_lite)
                    }
                }
                
                // 底部操作栏
                bottomActionBar_lite
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            isLiked_lite = titleVM_lite.isLikedPost_lite(post_lite: post_lite)
            
            // 获取帖子发布者信息并判断是否已关注
            let postUser_lite = userVM_lite.getUserById_lite(userId_lite: post_lite.titleUserId_lite)
            isFollowed_lite = userVM_lite.isFollowing_lite(user_lite: postUser_lite)
        }
        .onReceive(localData_lite.objectWillChange) { _ in
            // 监听评论变化，自动刷新
            // 不需要额外操作，currentPost_lite会自动从localData获取最新数据
        }
        .sheet(isPresented: $showGiftShop_lite) {
            GiftShop_lite()
        }
        .confirmationDialog("Report Post", isPresented: $showReportSheet_lite, titleVisibility: .visible) {
            Button("Report Sexually Explicit Material") {
                reportPost_lite()
            }
            Button("Report spam") {
                reportPost_lite()
            }
            Button("Report something else") {
                reportPost_lite()
            }
            Button("Report", role: .destructive) {
                reportPost_lite()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(isPresented: $showDeleteConfirm_lite) {
            Alert(
                title: Text("Delete Post"),
                message: Text("Are you sure you want to delete this post? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deletePost_lite()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - 自定义顶部导航栏
    
    /// 自定义顶部导航栏
    private var customHeaderView_lite: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12.w_lite) {
                // 返回按钮
                Button {
                    Router_lite.shared_lite.pop_lite()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white, Color(hex: "F8F9FA")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44.w_lite, height: 44.h_lite)
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20.sp_lite, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "f093fb").opacity(0.3), Color(hex: "f5576c").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(hex: "f093fb").opacity(0.3), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle_lite())
                
                // 标题
                VStack(alignment: .leading, spacing: 4.h_lite) {
                    Text("Post Detail")
                        .font(.system(size: 22.sp_lite, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "212529"), Color(hex: "495057")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("View and interact")
                        .font(.system(size: 12.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "6C757D"))
                }
                
                Spacer()
                
                // 删除/举报按钮
                Button {
                    if isOwnPost_lite {
                        showDeleteConfirm_lite = true
                    } else {
                        showReportSheet_lite = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(isOwnPost_lite ? Color(hex: "FFE5E5") : Color(hex: "F8F9FA"))
                            .frame(width: 44.w_lite, height: 44.h_lite)
                        
                        Image(systemName: isOwnPost_lite ? "trash.fill" : "ellipsis")
                            .font(.system(size: 18.sp_lite, weight: .bold))
                            .foregroundColor(isOwnPost_lite ? Color(hex: "FF6B6B") : Color(hex: "495057"))
                    }
                }
                .buttonStyle(ScaleButtonStyle_lite())
            }
            .padding(.horizontal, 20.w_lite)
            .padding(.top, 12.h_lite)
            .padding(.bottom, 16.h_lite)
            .background(
                Color.white
                    .ignoresSafeArea(edges: .top)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - 媒体展示区域
    
    /// 媒体展示区域
    private var mediaSection_lite: some View {
        ZStack(alignment: .bottomTrailing) {
            // 媒体内容
            if let mediaPath_lite = post_lite.titleMeidas_lite.first {
                MediaDisplayView_lite(
                    mediaPath_lite: mediaPath_lite,
                    isVideo_lite: mediaPath_lite.contains("video"),
                    cornerRadius_lite: 0
                )
                .frame(height: 400.h_lite)
                .clipped()
            } else {
                // 占位渐变
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 400.h_lite)
            }
            
            // 媒体数量指示器
            if post_lite.titleMeidas_lite.count > 1 {
                HStack(spacing: 6.w_lite) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 12.sp_lite, weight: .bold))
                    
                    Text("\(post_lite.titleMeidas_lite.count)")
                        .font(.system(size: 13.sp_lite, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12.w_lite)
                .padding(.vertical, 6.h_lite)
                .background(
                    ZStack {
                        BlurView_lite(style: .systemUltraThinMaterialDark)
                        
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                    }
                )
                .clipShape(Capsule())
                .padding(16.w_lite)
            }
        }
    }
    
    // MARK: - 主要内容卡片
    
    /// 主要内容卡片
    private var contentCard_lite: some View {
        VStack(alignment: .leading, spacing: 20.h_lite) {
            // 用户信息栏
            userInfoSection_lite
            
            // 帖子标题
            Text(post_lite.title_lite)
                .font(.system(size: 22.sp_lite, weight: .bold))
                .foregroundColor(Color(hex: "212529"))
                .lineSpacing(4)
            
            // 帖子内容
            Text(post_lite.titleContent_lite)
                .font(.system(size: 15.sp_lite, weight: .regular))
                .foregroundColor(Color(hex: "495057"))
                .lineSpacing(6)
            
            // 互动统计栏
            interactionStats_lite
        }
        .padding(24.w_lite)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 32.w_lite)
                    .fill(Color.white)
                
                RoundedRectangle(cornerRadius: 32.w_lite)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.8), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32.w_lite)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "E9ECEF"), Color(hex: "F8F9FA")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 25, x: 0, y: 12)
    }
    
    // MARK: - 用户信息栏
    
    /// 用户信息栏
    private var userInfoSection_lite: some View {
        HStack(spacing: 12.w_lite) {
            // 用户头像
            UserAvatarView_lite(
                userId_lite: post_lite.titleUserId_lite,
                size_lite: 48,
                isClickable_lite: true,
                onTapped_lite: {
                    Router_lite.shared_lite.pop_lite()
                    let user_lite = userVM_lite.getUserById_lite(userId_lite: post_lite.titleUserId_lite)
                    Router_lite.shared_lite.toUserInfo_lite(user_lite: user_lite)
                }
            )
            
            VStack(alignment: .leading, spacing: 4.h_lite) {
                Text(post_lite.titleUserName_lite)
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                HStack(spacing: 6.w_lite) {
                    Image(systemName: "clock")
                        .font(.system(size: 11.sp_lite, weight: .semibold))
                    
                    Text("2 hours ago")
                        .font(.system(size: 13.sp_lite, weight: .medium))
                }
                .foregroundColor(Color(hex: "6C757D"))
            }
            
            Spacer()
            
            // 关注按钮（仅在不是自己的帖子时显示）
            if !isOwnPost_lite {
                Button {
                    followUser_lite()
                } label: {
                    HStack(spacing: 6.w_lite) {
                        Image(systemName: isFollowed_lite ? "checkmark" : "plus")
                            .font(.system(size: 12.sp_lite, weight: .bold))
                        
                        Text(isFollowed_lite ? "Followed" : "Follow")
                            .font(.system(size: 14.sp_lite, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16.w_lite)
                    .padding(.vertical, 10.h_lite)
                    .background(
                        LinearGradient(
                            colors: isFollowed_lite ?
                                [Color(hex: "ADB5BD"), Color(hex: "6C757D")] :
                                [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20.w_lite)
                    .shadow(color: isFollowed_lite ? Color.clear : Color(hex: "667eea").opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(ScaleButtonStyle_lite())
            }
        }
    }
    
    // MARK: - 互动统计栏
    
    /// 互动统计栏
    private var interactionStats_lite: some View {
        HStack(spacing: 24.w_lite) {
            // 点赞数
            statItem_lite(
                icon: "heart.fill",
                count: currentPost_lite?.likes_lite ?? post_lite.likes_lite,
                color: Color(hex: "f5576c")
            )
            
            // 评论数
            statItem_lite(
                icon: "bubble.right.fill",
                count: currentPost_lite?.reviews_lite.count ?? post_lite.reviews_lite.count,
                color: Color(hex: "667eea")
            )
            
            Spacer()
        }
        .padding(.top, 8.h_lite)
    }
    
    /// 统计项
    private func statItem_lite(icon: String, count: Int, color: Color) -> some View {
        HStack(spacing: 8.w_lite) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32.w_lite, height: 32.h_lite)
                
                Image(systemName: icon)
                    .font(.system(size: 14.sp_lite, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text("\(count)")
                .font(.system(size: 16.sp_lite, weight: .bold))
                .foregroundColor(Color(hex: "212529"))
        }
    }
    
    // MARK: - 评论区域
    
    /// 评论区域
    private var commentsSection_lite: some View {
        VStack(alignment: .leading, spacing: 16.h_lite) {
            // 评论标题
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text("Comments")
                    .font(.system(size: 20.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Text("(\(currentPost_lite?.reviews_lite.count ?? 0))")
                    .font(.system(size: 16.sp_lite, weight: .semibold))
                    .foregroundColor(Color(hex: "6C757D"))
                
                Spacer()
            }
            .padding(.horizontal, 20.w_lite)
            
            // 评论列表
            if let currentPost = currentPost_lite, !currentPost.reviews_lite.isEmpty {
                VStack(spacing: 12.h_lite) {
                    ForEach(currentPost.reviews_lite) { comment_lite in
                        CommentCard_lite(comment_lite: comment_lite, post_lite: currentPost)
                            .padding(.horizontal, 20.w_lite)
                    }
                }
            } else {
                emptyCommentsView_lite
                    .padding(.horizontal, 20.w_lite)
                    .padding(.vertical, 40.h_lite)
            }
        }
    }
    
    /// 空评论视图
    private var emptyCommentsView_lite: some View {
        VStack(spacing: 16.h_lite) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 50.sp_lite))
                .foregroundColor(Color(hex: "ADB5BD"))
            
            Text("No comments yet")
                .font(.system(size: 16.sp_lite, weight: .semibold))
                .foregroundColor(Color(hex: "495057"))
            
            Text("Be the first to share your thoughts!")
                .font(.system(size: 14.sp_lite, weight: .regular))
                .foregroundColor(Color(hex: "6C757D"))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 底部操作栏
    
    /// 底部操作栏
    private var bottomActionBar_lite: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(hex: "E9ECEF"))
            
            HStack(spacing: 16.w_lite) {
                // 点赞按钮
                actionButton_lite(
                    icon: isLiked_lite ? "heart.fill" : "heart",
                    color: isLiked_lite ? Color(hex: "f5576c") : Color(hex: "6C757D"),
                    scale: likeAnimation_lite ? 1.3 : 1.0
                ) {
                    toggleLike_lite()
                }
                
                // 评论按钮
                actionButton_lite(
                    icon: "bubble.left",
                    color: Color(hex: "667eea")
                ) {
                    isCommentFocused_lite = true
                }
                
                // 送礼按钮
                giftButton_lite
                
                Spacer()
                
                // 评论输入框
                HStack(spacing: 8.w_lite) {
                    TextField("Write a comment...", text: $commentText_lite)
                        .font(.system(size: 14.sp_lite, weight: .medium))
                        .focused($isCommentFocused_lite)
                    
                    if !commentText_lite.isEmpty {
                        Button {
                            postComment_lite()
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16.sp_lite, weight: .bold))
                                .foregroundColor(Color(hex: "667eea"))
                        }
                    }
                }
                .padding(.horizontal, 16.w_lite)
                .padding(.vertical, 10.h_lite)
                .background(Color(hex: "F8F9FA"))
                .cornerRadius(20.w_lite)
            }
            .padding(.horizontal, 16.w_lite)
            .padding(.vertical, 12.h_lite)
            .background(
                Color.white
                    .ignoresSafeArea(edges: .bottom)
                    .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: -5)
            )
        }
    }
    
    /// 操作按钮
    private func actionButton_lite(icon: String, color: Color, scale: CGFloat = 1.0, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22.sp_lite, weight: .semibold))
                .foregroundColor(color)
                .scaleEffect(scale)
        }
        .buttonStyle(ScaleButtonStyle_lite())
    }
    
    /// 送礼按钮
    private var giftButton_lite: some View {
        Button {
            showGiftShop_lite = true
        } label: {
            Image("gift_btn")
                .resizable()
                .scaledToFit()
                .frame(width: 26.w_lite, height: 26.h_lite)
                .foregroundColor(Color(hex: "FFD700"))
        }
        .buttonStyle(ScaleButtonStyle_lite())
    }
    
    // MARK: - 私有方法
    
    /// 切换点赞
    private func toggleLike_lite() {
        // 优先判断用户是否登录
        if !userVM_lite.isLoggedIn_lite {
            // 未登录直接进入登录页，不提示
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
                Router_lite.shared_lite.toLogin_liteui()
            }
            return
        }
        
        isLiked_lite.toggle()
        
        // 点赞动画
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            likeAnimation_lite = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                likeAnimation_lite = false
            }
        }
        
        // 调用ViewModel
        titleVM_lite.likePost_lite(post_lite: post_lite)
    }
    
    /// 关注/取关用户
    private func followUser_lite() {
        let postUser_lite = userVM_lite.getUserById_lite(userId_lite: post_lite.titleUserId_lite)
        userVM_lite.followUser_lite(user_lite: postUser_lite)
        
        // 更新关注状态
        isFollowed_lite = userVM_lite.isFollowing_lite(user_lite: postUser_lite)
    }
    
    /// 删除帖子
    private func deletePost_lite() {
        ReportHelper_lite.deletePost_lite(post_lite: post_lite) {
            Router_lite.shared_lite.pop_lite()
        }
    }
    
    /// 发布评论
    private func postComment_lite() {
        let content_lite = commentText_lite.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content_lite.isEmpty else { return }
        
        if let currentPost = currentPost_lite {
            titleVM_lite.releaseComment_lite(post_lite: currentPost, content_lite: content_lite)
            commentText_lite = ""
            isCommentFocused_lite = false
        }
    }
    
    /// 举报帖子
    private func reportPost_lite() {
        ReportHelper_lite.reportPost_lite(post_lite: post_lite) {
            Router_lite.shared_lite.pop_lite()
        }
    }
}

// MARK: - 评论卡片组件

/// 评论卡片
struct CommentCard_lite: View {
    
    let comment_lite: Comment_lite
    let post_lite: TitleModel_lite
    
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @State private var showReportSheet_lite = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12.w_lite) {
            // 用户头像
            UserAvatarView_lite(
                userId_lite: comment_lite.commentUserId_lite,
                size_lite: 40
            )
            
            VStack(alignment: .leading, spacing: 8.h_lite) {
                // 用户名和时间
                HStack(spacing: 8.w_lite) {
                    Text(comment_lite.commentUserName_lite)
                        .font(.system(size: 14.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "212529"))
                    
                    Text("2m")
                        .font(.system(size: 12.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "ADB5BD"))
                    
                    Spacer()
                    
                    // 举报按钮
                    Button {
                        showReportSheet_lite = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14.sp_lite, weight: .semibold))
                            .foregroundColor(Color(hex: "ADB5BD"))
                    }
                }
                
                // 评论内容
                Text(comment_lite.commentContent_lite)
                    .font(.system(size: 14.sp_lite, weight: .regular))
                    .foregroundColor(Color(hex: "495057"))
                    .lineSpacing(3)
            }
        }
        .padding(16.w_lite)
        .background(Color(hex: "F8F9FA"))
        .cornerRadius(16.w_lite)
        .confirmationDialog("Report Comment", isPresented: $showReportSheet_lite, titleVisibility: .visible) {
            Button("Report Sexually Explicit Material") {
                reportComment_lite()
            }
            Button("Report spam") {
                reportComment_lite()
            }
            Button("Report something else") {
                reportComment_lite()
            }
            Button("Report", role: .destructive) {
                reportComment_lite()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    /// 举报评论
    private func reportComment_lite() {
        ReportHelper_lite.reportComment_lite(comment_lite: comment_lite, post_lite: post_lite)
    }
}

// MARK: - 毛玻璃视图

/// 毛玻璃效果视图
struct BlurView_lite: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
