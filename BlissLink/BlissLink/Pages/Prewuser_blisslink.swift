import SwiftUI

// MARK: - 用户信息页
// 核心作用：展示其他用户的个人信息、统计数据、帖子列表
// 设计思路：现代化卡片设计，关注/取消关注，帖子Tab切换，动画自然有趣
// 关键功能：用户信息展示、关注操作、举报功能、帖子列表切换

/// 帖子Tab枚举
enum UserPostTab_blisslink: Equatable {
    case userPosts_blisslink
    case likedPosts_blisslink
}

/// 用户信息页
struct Prewuser_baseswift: View {
    
    // MARK: - 属性
    
    /// 用户数据
    let user_blisslink: PrewUserModel_blisslink
    
    // MARK: - ViewModels
    
    @ObservedObject var userVM_blisslink = UserViewModel_blisslink.shared_blisslink
    @ObservedObject var router_blisslink = Router_blisslink.shared_blisslink
    @ObservedObject var titleVM_blisslink = TitleViewModel_blisslink.shared_blisslink
    
    // MARK: - 状态
    
    @State private var selectedTab_blisslink: UserPostTab_blisslink = .userPosts_blisslink
    @State private var showReportSheet_blisslink: Bool = false
    @State private var isFollowing_blisslink: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "F7FAFC"),
                        Color(hex: "EDF2F7"),
                        Color(hex: "E2E8F0")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 顶部装饰背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "667EEA").opacity(0.12),
                        Color(hex: "764BA2").opacity(0.08),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300.h_blisslink)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // 装饰圆圈
                Circle()
                    .fill(Color(hex: "667EEA").opacity(0.08))
                    .frame(width: 250.w_blisslink, height: 250.h_blisslink)
                    .offset(x: -120.w_blisslink, y: -150.h_blisslink)
                    .blur(radius: 40)
                
                Circle()
                    .fill(Color(hex: "764BA2").opacity(0.08))
                    .frame(width: 280.w_blisslink, height: 280.h_blisslink)
                    .offset(x: 140.w_blisslink, y: 450.h_blisslink)
                    .blur(radius: 50)
            }
            .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar_blisslink
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24.h_blisslink) {
                        // 用户信息卡片
                        userProfileCard_blisslink
                        
                        // 统计数据卡片
                        statsCard_blisslink
                        
                        // 帖子Tab切换区域
                        postsTabSection_blisslink
                    }
                    .padding(.horizontal, 20.w_blisslink)
                    .padding(.top, 24.h_blisslink)
                    .padding(.bottom, 100.h_blisslink)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            initializeData_blisslink()
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar_blisslink: some View {
        HStack {
            // 返回按钮
            Button(action: {
                router_blisslink.pop_blisslink()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36.w_blisslink, height: 36.h_blisslink)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
            }
            
            Spacer()
            
            // 标题
            Text(user_blisslink.userName_blisslink ?? "User")
                .font(.system(size: 18.sp_blisslink, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
            
            // 举报按钮
            Button(action: {
                // 触觉反馈
                let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
                generator_blisslink.impactOccurred()
                
                showReportSheet_blisslink = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 36.w_blisslink, height: 36.h_blisslink)
                    
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16.sp_blisslink, weight: .bold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(90))
                }
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1.5.w_blisslink)
                )
            }
        }
        .padding(.horizontal, 20.w_blisslink)
        .padding(.top, 10.h_blisslink)
        .padding(.bottom, 12.h_blisslink)
        .background(
            ZStack {
                Color.white.opacity(0.85)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .top)
                
                // 底部渐变装饰线
                VStack {
                    Spacer()
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 3.h_blisslink)
                }
                
                // 举报ActionSheet
                ReportActionSheet_blisslink(
                    isShowing_blisslink: $showReportSheet_blisslink,
                    isBlockUser_blisslink: true,
                    onConfirm_blisslink: {
                        handleReportUser_blisslink()
                    }
                )
            }
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - 用户信息卡片
    
    private var userProfileCard_blisslink: some View {
        VStack(spacing: 20.h_blisslink) {
            // 头像和基本信息
            VStack(spacing: 16.h_blisslink) {
                // 头像（使用 UserAvatarView 组件）
                ZStack {
                    // 外层光晕
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "667EEA").opacity(0.3),
                                    Color(hex: "764BA2").opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110.w_blisslink, height: 110.h_blisslink)
                        .blur(radius: 12)
                    
                    // 使用 UserAvatarView 组件
                    UserAvatarView_blisslink(
                        userId_blisslink: user_blisslink.userId_blisslink ?? 0,
                        avatarPath_blisslink: user_blisslink.userHead_blisslink,
                        userName_blisslink: user_blisslink.userName_blisslink,
                        size_blisslink: 100.w_blisslink
                    )
                    .shadow(color: Color(hex: "667EEA").opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .bounceIn_blisslink(delay_blisslink: 0.1)
                
                // 用户名和简介
                VStack(spacing: 10.h_blisslink) {
                    // 用户名
                    Text(user_blisslink.userName_blisslink ?? "User")
                        .font(.system(size: 24.sp_blisslink, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // 验证徽章
                    HStack(spacing: 6.w_blisslink) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14.sp_blisslink))
                            .foregroundColor(Color(hex: "56CCF2"))
                        
                        Text("Community Member")
                            .font(.system(size: 13.sp_blisslink, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // 用户简介
                    if let intro_blisslink = user_blisslink.userIntroduce_blisslink, !intro_blisslink.isEmpty {
                        Text(intro_blisslink)
                            .font(.system(size: 14.sp_blisslink))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 20.w_blisslink)
                            .padding(.top, 4.h_blisslink)
                    } else {
                        Text("Nothing yet.")
                            .font(.system(size: 14.sp_blisslink))
                            .foregroundColor(.secondary.opacity(0.7))
                            .padding(.top, 4.h_blisslink)
                    }
                }
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.2)
            }
            
            // 按钮区域
            HStack(spacing: 12.w_blisslink) {
                // 关注/取消关注按钮
                Button(action: {
                    handleFollowToggle_blisslink()
                }) {
                    HStack(spacing: 8.w_blisslink) {
                        Image(systemName: isFollowing_blisslink ? "checkmark" : "person.badge.plus")
                            .font(.system(size: 15.sp_blisslink, weight: .semibold))
                        
                        Text(isFollowing_blisslink ? "Followed" : "Follow")
                            .font(.system(size: 15.sp_blisslink, weight: .bold))
                    }
                    .foregroundColor(isFollowing_blisslink ? .secondary : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13.h_blisslink)
                    .background(
                        RoundedRectangle(cornerRadius: 12.w_blisslink)
                            .fill(
                                isFollowing_blisslink ?
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.15)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(
                        color: isFollowing_blisslink ? Color.clear : Color(hex: "667EEA").opacity(0.3),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
                }
                .scaleEffect(isFollowing_blisslink ? 1.0 : 1.02)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFollowing_blisslink)
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.25)
                
                // 消息按钮
                Button(action: {
                    handleMessageTap_blisslink()
                }) {
                    HStack(spacing: 8.w_blisslink) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 15.sp_blisslink, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "56CCF2"))
                    .frame(width: 50.w_blisslink)
                    .padding(.vertical, 13.h_blisslink)
                    .background(
                        RoundedRectangle(cornerRadius: 12.w_blisslink)
                            .fill(Color(hex: "56CCF2").opacity(0.12))
                    )
                }
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.28)
            }
        }
        .padding(24.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 24.w_blisslink)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
    
    // MARK: - 统计数据卡片
    
    private var statsCard_blisslink: some View {
        HStack(spacing: 0) {
            // 帖子数
            statColumn_blisslink(
                icon_blisslink: "doc.text.fill",
                title_blisslink: "Posts",
                value_blisslink: "\(userPosts_blisslink.count)",
                gradientColors_blisslink: [Color(hex: "667EEA"), Color(hex: "764BA2")]
            )
            
            // 分隔线
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1.w_blisslink, height: 60.h_blisslink)
            
            // 关注数
            statColumn_blisslink(
                icon_blisslink: "person.2.fill",
                title_blisslink: "Following",
                value_blisslink: "\(user_blisslink.userFollow_blisslink ?? 0)",
                gradientColors_blisslink: [Color(hex: "43E97B"), Color(hex: "38F9D7")]
            )
            
            // 分隔线
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1.w_blisslink, height: 60.h_blisslink)
            
            // 粉丝数
            statColumn_blisslink(
                icon_blisslink: "heart.fill",
                title_blisslink: "Followers",
                value_blisslink: "\(user_blisslink.userFans_blisslink ?? 0)",
                gradientColors_blisslink: [Color(hex: "FF6B6B"), Color(hex: "FFE66D")]
            )
        }
        .padding(.vertical, 24.h_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 20.w_blisslink)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.3)
    }
    
    /// 统计列
    private func statColumn_blisslink(
        icon_blisslink: String,
        title_blisslink: String,
        value_blisslink: String,
        gradientColors_blisslink: [Color]
    ) -> some View {
        VStack(spacing: 10.h_blisslink) {
            // 图标
            Image(systemName: icon_blisslink)
                .font(.system(size: 22.sp_blisslink, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors_blisslink),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 数值
            Text(value_blisslink)
                .font(.system(size: 24.sp_blisslink, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors_blisslink),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .monospacedDigit()
            
            // 标题
            Text(title_blisslink)
                .font(.system(size: 12.sp_blisslink, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 帖子Tab切换区域
    
    private var postsTabSection_blisslink: some View {
        VStack(spacing: 0) {
            // Tab切换栏
            HStack(spacing: 0) {
                // 用户的帖子
                tabButton_blisslink(
                    icon_blisslink: "doc.text.fill",
                    title_blisslink: "Posts",
                    count_blisslink: userPosts_blisslink.count,
                    tab_blisslink: .userPosts_blisslink,
                    isSelected_blisslink: selectedTab_blisslink == .userPosts_blisslink
                )
                
                // 喜欢的帖子
                tabButton_blisslink(
                    icon_blisslink: "heart.fill",
                    title_blisslink: "Liked",
                    count_blisslink: userLikedPosts_blisslink.count,
                    tab_blisslink: .likedPosts_blisslink,
                    isSelected_blisslink: selectedTab_blisslink == .likedPosts_blisslink
                )
            }
            .padding(.horizontal, 20.w_blisslink)
            .padding(.top, 16.h_blisslink)
            .background(Color.white)
            
            // 帖子列表
            TabView(selection: $selectedTab_blisslink) {
                // 用户的帖子列表
                postsListView_blisslink(posts_blisslink: userPosts_blisslink)
                    .tag(UserPostTab_blisslink.userPosts_blisslink)
                
                // 喜欢的帖子列表
                postsListView_blisslink(posts_blisslink: userLikedPosts_blisslink)
                    .tag(UserPostTab_blisslink.likedPosts_blisslink)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 450.h_blisslink)
        }
        .background(
            RoundedRectangle(cornerRadius: 20.w_blisslink)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.4)
    }
    
    /// Tab按钮
    private func tabButton_blisslink(
        icon_blisslink: String,
        title_blisslink: String,
        count_blisslink: Int,
        tab_blisslink: UserPostTab_blisslink,
        isSelected_blisslink: Bool
    ) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedTab_blisslink = tab_blisslink
            }
            
            // 触觉反馈
            let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
            generator_blisslink.impactOccurred()
        }) {
            VStack(spacing: 10.h_blisslink) {
                HStack(spacing: 6.w_blisslink) {
                    Image(systemName: icon_blisslink)
                        .font(.system(size: 14.sp_blisslink, weight: isSelected_blisslink ? .bold : .medium))
                    
                    Text(title_blisslink)
                        .font(.system(size: 15.sp_blisslink, weight: isSelected_blisslink ? .bold : .medium))
                    
                    // 数量徽章
                    Text("\(count_blisslink)")
                        .font(.system(size: 12.sp_blisslink, weight: .bold))
                        .foregroundColor(isSelected_blisslink ? .white : .secondary)
                        .padding(.horizontal, 8.w_blisslink)
                        .padding(.vertical, 3.h_blisslink)
                        .background(
                            Capsule()
                                .fill(
                                    isSelected_blisslink ?
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.2)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .foregroundColor(isSelected_blisslink ? Color(hex: "667EEA") : .secondary)
                
                // 下划线
                Rectangle()
                    .fill(
                        isSelected_blisslink ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3.h_blisslink)
                    .cornerRadius(1.5.h_blisslink)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
    
    /// 帖子列表视图
    private func postsListView_blisslink(posts_blisslink: [TitleModel_blisslink]) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            if posts_blisslink.isEmpty {
                // 空状态
                VStack(spacing: 16.h_blisslink) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "667EEA").opacity(0.1))
                            .frame(width: 80.w_blisslink, height: 80.h_blisslink)
                        
                        Image(systemName: selectedTab_blisslink == .userPosts_blisslink ? "doc.text" : "heart")
                            .font(.system(size: 40.sp_blisslink))
                            .foregroundColor(Color(hex: "667EEA").opacity(0.6))
                    }
                    
                    Text(selectedTab_blisslink == .userPosts_blisslink ? "No posts yet" : "No liked posts yet")
                        .font(.system(size: 16.sp_blisslink, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 80.h_blisslink)
            } else {
                LazyVStack(spacing: 16.h_blisslink) {
                    ForEach(posts_blisslink) { post_blisslink in
                        PostCardView_blisslink(
                            post_blisslink: post_blisslink,
                            onTap_blisslink: {
                                router_blisslink.toPostDetail_blisslink(post_blisslink: post_blisslink)
                            },
                            onLike_blisslink: {},
                            onComment_blisslink: {
                                router_blisslink.toPostDetail_blisslink(post_blisslink: post_blisslink)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16.w_blisslink)
                .padding(.vertical, 16.h_blisslink)
            }
        }
    }
    
    // MARK: - 计算属性
    
    /// 用户的帖子列表（过滤已删除的）
    private var userPosts_blisslink: [TitleModel_blisslink] {
        let posts_blisslink = titleVM_blisslink.getUserPosts_blisslink(user_blisslink: user_blisslink)
        return posts_blisslink.filter { post_blisslink in
            titleVM_blisslink.getPosts_blisslink().contains { $0.titleId_blisslink == post_blisslink.titleId_blisslink }
        }
    }
    
    /// 用户喜欢的帖子列表（过滤已删除的）
    private var userLikedPosts_blisslink: [TitleModel_blisslink] {
        return user_blisslink.userLike_blisslink.filter { post_blisslink in
            titleVM_blisslink.getPosts_blisslink().contains { $0.titleId_blisslink == post_blisslink.titleId_blisslink }
        }
    }
    
    // MARK: - 事件处理
    
    /// 初始化数据
    private func initializeData_blisslink() {
        isFollowing_blisslink = userVM_blisslink.isFollowing_blisslink(user_blisslink: user_blisslink)
    }
    
    /// 处理关注/取消关注
    private func handleFollowToggle_blisslink() {
        // 检查是否登录
        if !userVM_blisslink.isLoggedIn_blisslink {
            // 延迟跳转到登录页面
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 500_000_000)
                router_blisslink.toLogin_blisslink()
            }
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        // 更新关注状态
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isFollowing_blisslink.toggle()
        }
        
        // 更新关注数（立即更新UI）
        if isFollowing_blisslink {
            // 关注：关注数+1
            user_blisslink.userFans_blisslink = (user_blisslink.userFans_blisslink ?? 0) + 1
        } else {
            // 取消关注：关注数-1
            user_blisslink.userFans_blisslink = max(0, (user_blisslink.userFans_blisslink ?? 0) - 1)
        }
        
        // 调用ViewModel执行关注逻辑
        userVM_blisslink.followUser_blisslink(user_blisslink: user_blisslink)
    }
    
    /// 处理发送消息
    private func handleMessageTap_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        router_blisslink.pop_blisslink()
        // 跳转到聊天页面
        router_blisslink.toUserChat_blisslink(user_blisslink: user_blisslink)
    }
    
    /// 处理举报用户
    private func handleReportUser_blisslink() {
        ReportHelper_blisslink.blockUser_blisslink(user_blisslink: user_blisslink) {
            // 返回上一页
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router_blisslink.pop_blisslink()
            }
        }
    }
}
