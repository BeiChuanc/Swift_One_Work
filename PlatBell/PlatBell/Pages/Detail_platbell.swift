import SwiftUI

// MARK: - 帖子详情页
// 核心作用：展示帖子的完整内容和作者信息
// 设计思路：现代化设计 + 沉浸式媒体展示 + 话题标签 + 简洁优雅
// 关键功能：媒体轮播、用户信息、话题标签、举报

/// 帖子详情页
struct Detail_platbell: View {
    
    /// 帖子数据
    let post_platbell: TitleModel_platbell
    
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 当前媒体索引
    @State private var currentMediaIndex_platbell: Int = 0
    
    /// 是否显示举报菜单
    @State private var showReportSheet_platbell: Bool = false
    
    /// 内容动画状态
    @State private var contentVisible_platbell: Bool = false
    
    /// 媒体缩放状态
    @State private var mediaScale_platbell: CGFloat = 1.0
    
    /// 评论输入文本
    @State private var commentText_platbell: String = ""
    
    /// 输入框聚焦状态
    @FocusState private var isCommentFocused_platbell: Bool
    
    /// 是否显示礼物界面
    @State private var showGiftView_platbell: Bool = false
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundView_platbell
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 媒体展示区
                    mediaSection_platbell
                        .padding(.bottom, 24)
                    
                    // 帖子内容区
                    contentSection_platbell
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // 话题标签（仅话题帖子显示）
                    if post_platbell.type_platbell == 1 && !post_platbell.tags_platbell.isEmpty {
                        topicTagsSection_platbell
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                    }
                    
                    // 统计信息卡片
                    statsCard_platbell
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // 分割线
                    Divider()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    
                    // 评论区
                    commentsSection_platbell
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                }
            }
            
            // 底部评论输入栏
            VStack {
                Spacer()
                commentInputBar_platbell
            }
            
            // 顶部导航栏
            VStack {
                customNavigationBar_platbell
                    .padding(.top, 50)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            
            // 礼物界面
            if showGiftView_platbell {
                GiftView_platbell(isPresented_platbell: $showGiftView_platbell)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(edges: .vertical)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                contentVisible_platbell = true
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                mediaScale_platbell = 1.05
            }
        }
        .background(
            ReportActionSheet_platbell(
                isShowing_platbell: $showReportSheet_platbell,
                isBlockUser_platbell: false,
                onConfirm_platbell: {
                    ReportHelper_platbell.reportPost_platbell(post_platbell: post_platbell, completion_platbell: {
                        router_platbell.pop_platbell()
                    })
                }
            )
        )
    }
    
    // MARK: - 子视图
    
    /// 渐变背景
    private var backgroundView_platbell: some View {
        LinearGradient(
            colors: [
                ThemeColors_platbell.allStartColors_platbell[post_platbell.titleId_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.12),
                ThemeColors_platbell.allEndColors_platbell[post_platbell.titleId_platbell % ThemeColors_platbell.allEndColors_platbell.count].opacity(0.06),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    /// 自定义导航栏
    private var customNavigationBar_platbell: some View {
        HStack(spacing: 12) {
            // 返回按钮
            Button(action: {
                router_platbell.pop_platbell()
            }) {
                ZStack {
                    // 模糊背景
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
            
            // 举报按钮
            Button(action: {
                showReportSheet_platbell = true
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
    
    /// 媒体展示区
    private var mediaSection_platbell: some View {
        TabView(selection: $currentMediaIndex_platbell) {
            ForEach(post_platbell.titleMeidas_platbell.indices, id: \.self) { index_platbell in
                let mediaName_platbell = post_platbell.titleMeidas_platbell[index_platbell]
                
                GeometryReader { geometry_platbell in
                    ZStack {
                        // 渐变背景
                        ThemeColors_platbell.gradient_platbell(
                            at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                        )
                        .opacity(0.25)
                        
                        // 媒体内容
                        MediaDisplayView_platbell(
                            mediaPath_platbell: mediaName_platbell,
                            isVideo_platbell: mediaName_platbell.contains(".mp4"),
                            cornerRadius_platbell: 0
                        )
                        .frame(width: geometry_platbell.size.width, height: geometry_platbell.size.height)
                        .scaleEffect(mediaScale_platbell)
                    }
                }
                .tag(index_platbell)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: post_platbell.titleMeidas_platbell.count > 1 ? .always : .never))
        .frame(height: 450)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
    
    /// 帖子内容区
    private var contentSection_platbell: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 作者信息栏
            authorInfoBar_platbell
            
            // 帖子标题
            Text(post_platbell.title_platbell)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(5)
            
            // 帖子内容
            Text(post_platbell.titleContent_platbell)
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .lineSpacing(6)
        }
        .opacity(contentVisible_platbell ? 1 : 0)
        .offset(y: contentVisible_platbell ? 0 : 20)
    }
    
    /// 作者信息栏
    private var authorInfoBar_platbell: some View {
        HStack(spacing: 14) {
            // 用户头像
            UserAvatarView_platbell(
                userId_platbell: post_platbell.titleUserId_platbell,
                size_platbell: 52,
                isClickable_platbell: true,
                onTapped_platbell: {
                    let user_platbell = userVM_platbell.getUserById_platbell(userId_platbell: post_platbell.titleUserId_platbell)
                    router_platbell.toUserInfo_platbell(user_platbell: user_platbell)
                }
            )
            .overlay(
                Circle()
                    .stroke(
                        ThemeColors_platbell.gradient_platbell(
                            at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                        )
                        .opacity(0.5),
                        lineWidth: 2.5
                    )
            )
            .shadow(
                color: ThemeColors_platbell.allStartColors_platbell[post_platbell.titleId_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.3),
                radius: 10,
                x: 0,
                y: 5
            )
            
            VStack(alignment: .leading, spacing: 5) {
                // 用户名
                Text(post_platbell.titleUserName_platbell)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                
                // 发布时间（模拟）
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 11, weight: .semibold))
                    
                    Text("2 hours ago")
                        .font(.system(size: 14))
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 关注按钮
            if !userVM_platbell.isCurrentUser_platbell(userId_platbell: post_platbell.titleUserId_platbell) {
                followButton_platbell
            }
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [
                            ThemeColors_platbell.allStartColors_platbell[post_platbell.titleId_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.3),
                            ThemeColors_platbell.allEndColors_platbell[post_platbell.titleId_platbell % ThemeColors_platbell.allEndColors_platbell.count].opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
    
    /// 关注按钮
    private var followButton_platbell: some View {
        let user_platbell = userVM_platbell.getUserById_platbell(userId_platbell: post_platbell.titleUserId_platbell)
        let isFollowing_platbell = userVM_platbell.isFollowing_platbell(user_platbell: user_platbell)
        
        return Button(action: {
            userVM_platbell.followUser_platbell(user_platbell: user_platbell)
            
            // 触觉反馈
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }) {
            HStack(spacing: 6) {
                Image(systemName: isFollowing_platbell ? "checkmark" : "plus")
                    .font(.system(size: 13, weight: .bold))
                
                Text(isFollowing_platbell ? "Followed" : "Follow")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(isFollowing_platbell ? .secondary : .white)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isFollowing_platbell {
                        Capsule()
                            .fill(Color(.systemGray5))
                    } else {
                        Capsule()
                            .fill(
                                ThemeColors_platbell.gradient_platbell(
                                    at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                                )
                            )
                    }
                }
            )
            .shadow(
                color: isFollowing_platbell ? Color.clear : ThemeColors_platbell.allStartColors_platbell[post_platbell.titleId_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.35),
                radius: 10,
                x: 0,
                y: 5
            )
        }
        .buttonStyle(.plain)
    }
    
    /// 话题标签区域
    private var topicTagsSection_platbell: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 标题
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            ThemeColors_platbell.gradient_platbell(
                                at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                            )
                            .opacity(0.15)
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "tag.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(
                            ThemeColors_platbell.gradient_platbell(
                                at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                            )
                        )
                }
                
                Text("Topics")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // 标签云
            TagCloud_platbell(
                tags_platbell: post_platbell.tags_platbell,
                gradientIndex_platbell: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count,
                isClickable_platbell: true,
                onTagTapped_platbell: { tag_platbell in
                    Utils_platbell.showInfo_platbell(
                        message_platbell: "Topic: \(tag_platbell)",
                        delay_platbell: 1.0
                    )
                },
                showDecoration_platbell: true
            )
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        ThemeColors_platbell.gradient_platbell(
                            at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                        )
                        .opacity(0.08)
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [
                            ThemeColors_platbell.allStartColors_platbell[post_platbell.titleId_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.35),
                            ThemeColors_platbell.allEndColors_platbell[post_platbell.titleId_platbell % ThemeColors_platbell.allEndColors_platbell.count].opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
    
    /// 统计信息卡片
    private var statsCard_platbell: some View {
        HStack(spacing: 20) {
            // 点赞数
            DetailStatItem_platbell(
                icon_platbell: "heart.fill",
                count_platbell: post_platbell.likes_platbell,
                label_platbell: "Likes",
                color_platbell: .red
            )
            
            Divider()
                .frame(height: 30)
            
            // 评论数
            DetailStatItem_platbell(
                icon_platbell: "bubble.left.fill",
                count_platbell: post_platbell.reviews_platbell.count,
                label_platbell: "Comments",
                color_platbell: ThemeColors_platbell.accentBlueStart_platbell
            )
            
            Divider()
                .frame(height: 30)
            
            // 浏览数（模拟）
            DetailStatItem_platbell(
                icon_platbell: "eye.fill",
                count_platbell: post_platbell.likes_platbell * 8,
                label_platbell: "Views",
                color_platbell: ThemeColors_platbell.accentGreenStart_platbell
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    Color.gray.opacity(0.15),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
    
    /// 评论区
    private var commentsSection_platbell: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 评论标题
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            ThemeColors_platbell.accentBlueStart_platbell.opacity(0.15)
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(
                            ThemeColors_platbell.gradient_platbell(
                                at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                            )
                        )
                }
                
                Text("Comments")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("(\(post_platbell.reviews_platbell.count))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // 评论列表
            if post_platbell.reviews_platbell.isEmpty {
                emptyCommentsView_platbell
            } else {
                VStack(spacing: 12) {
                    ForEach(post_platbell.reviews_platbell) { comment_platbell in
                        CommentCard_platbell(
                            comment_platbell: comment_platbell,
                            post_platbell: post_platbell,
                            gradientIndex_platbell: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                        )
                    }
                }
            }
        }
    }
    
    /// 空评论视图
    private var emptyCommentsView_platbell: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        ThemeColors_platbell.gradient_platbell(
                            at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                        )
                        .opacity(0.12)
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "text.bubble")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        ThemeColors_platbell.gradient_platbell(
                            at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                        )
                    )
            }
            
            Text("No comments yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Be the first to share your thoughts")
                .font(.system(size: 15))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
    
    /// 底部评论输入栏
    private var commentInputBar_platbell: some View {
        HStack(spacing: 14) {
            // 当前用户头像
            UserAvatarView_platbell(
                userId_platbell: userVM_platbell.getCurrentUser_platbell().userId_platbell ?? 0,
                size_platbell: 40,
                isClickable_platbell: false
            )
            .overlay(
                Circle()
                    .stroke(
                        ThemeColors_platbell.gradient_platbell(
                            at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                        )
                        .opacity(0.4),
                        lineWidth: 2
                    )
            )
            
            // 评论输入框
            HStack(spacing: 10) {
                TextField("Write a comment...", text: $commentText_platbell)
                    .font(.system(size: 16))
                    .focused($isCommentFocused_platbell)
                    .submitLabel(.send)
                    .onSubmit {
                        handleSendComment_platbell()
                    }
                
                // Gift按钮
                Button(action: {
                    handleGiftButtonTap_platbell()
                }) {
                    Image("gift_btn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 46, height: 46)
                }
                
                // 发布按钮
                Button(action: handleSendComment_platbell) {
                    ZStack {
                        Circle()
                            .fill(
                                ThemeColors_platbell.gradient_platbell(
                                    at: post_platbell.titleId_platbell % ThemeColors_platbell.allGradients_platbell.count
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(
                        color: ThemeColors_platbell.allStartColors_platbell[post_platbell.titleId_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
            }
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            ZStack {
                Rectangle()
                    .fill(Color(.systemBackground))
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: -5)
        )
    }
    
    // MARK: - 事件处理
    
    /// 处理发送评论
    private func handleSendComment_platbell() {
        let trimmedComment_platbell = commentText_platbell.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedComment_platbell.isEmpty else { return }
        
        // 检查是否登录
        guard userVM_platbell.isLoggedIn_platbell else {
            Utils_platbell.showWarning_platbell(
                message_platbell: "Please login to comment",
                delay_platbell: 2.0
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router_platbell.toLogin_platbellui()
            }
            return
        }
        
        // 创建评论
        let newComment_platbell = Comment_platbell(
            commentId_platbell: Int.random(in: 10000...99999),
            commentUserId_platbell: userVM_platbell.getCurrentUser_platbell().userId_platbell ?? 0,
            commentUserName_platbell: userVM_platbell.getCurrentUser_platbell().userName_platbell ?? "User",
            commentContent_platbell: trimmedComment_platbell
        )
        
        // 添加评论
        titleVM_platbell.addComment_platbell(post_platbell: post_platbell, comment_platbell: newComment_platbell)
        
        // 清空输入框
        commentText_platbell = ""
        isCommentFocused_platbell = false
        
        // 显示成功提示
        Utils_platbell.showSuccess_platbell(
            message_platbell: "Comment posted successfully",
            delay_platbell: 1.2
        )
        
        // 触觉反馈
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    /// 处理礼物按钮点击
    private func handleGiftButtonTap_platbell() {
        // 关闭键盘
        isCommentFocused_platbell = false
        
        // 显示礼物界面
        withAnimation(AnimationPresets_platbell.standardSpring_platbell) {
            showGiftView_platbell = true
        }
        
        // 触觉反馈
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - 评论卡片组件

/// 评论卡片组件
struct CommentCard_platbell: View {
    
    let comment_platbell: Comment_platbell
    let post_platbell: TitleModel_platbell
    let gradientIndex_platbell: Int
    
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 是否显示举报菜单
    @State private var showReportMenu_platbell: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // 评论者头像
            UserAvatarView_platbell(
                userId_platbell: comment_platbell.commentUserId_platbell,
                size_platbell: 42,
                isClickable_platbell: true,
                onTapped_platbell: {
                    let user_platbell = userVM_platbell.getUserById_platbell(userId_platbell: comment_platbell.commentUserId_platbell)
                    router_platbell.toUserInfo_platbell(user_platbell: user_platbell)
                }
            )
            
            VStack(alignment: .leading, spacing: 8) {
                // 用户名和时间
                HStack(spacing: 8) {
                    Text(comment_platbell.commentUserName_platbell)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("Just now")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // 举报按钮
                    Button(action: {
                        showReportMenu_platbell = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray6))
                            )
                    }
                }
                
                // 评论内容
                Text(comment_platbell.commentContent_platbell)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.gray.opacity(0.12),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        .background(
            ReportActionSheet_platbell(
                isShowing_platbell: $showReportMenu_platbell,
                isBlockUser_platbell: false,
                onConfirm_platbell: {
                    ReportHelper_platbell.reportComment_platbell(
                        comment_platbell: comment_platbell,
                        post_platbell: post_platbell
                    )
                }
            )
        )
    }
}

// MARK: - 统计项组件

/// 详情页统计项组件
struct DetailStatItem_platbell: View {
    
    let icon_platbell: String
    let count_platbell: Int
    let label_platbell: String
    let color_platbell: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // 图标
            ZStack {
                Circle()
                    .fill(color_platbell.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon_platbell)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color_platbell)
            }
            
            // 数字
            Text("\(count_platbell)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            // 标签
            Text(label_platbell)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
