import SwiftUI
import Combine

// MARK: - 用户信息页
// 核心作用：展示其他用户的个人信息、统计数据和发布内容
// 设计思路：现代化设计，强调互动性（关注、消息），展示用户内容
// 关键功能：用户信息、统计数据、关注/取关、发送消息、举报、帖子展示

/// 用户信息页
struct Prewuser_lite: View {
    
    /// 用户数据
    let user_lite: PrewUserModel_lite
    
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var router_lite = Router_lite.shared_lite
    @ObservedObject private var localData_lite = LocalData_lite.shared_lite
    
    @State private var showReportSheet_lite = false
    @State private var userPosts_lite: [TitleModel_lite] = []
    
    var body: some View {
        ZStack {
            // 增强渐变背景
            enhancedBackground_lite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 自定义顶部导航栏
                customHeaderView_lite
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24.h_lite) {
                        // 用户信息区域
                        profileSection_lite
                            .padding(.horizontal, 20.w_lite)
                            .padding(.top, 24.h_lite)
                        
                        // 互动按钮（关注+消息）
                        actionButtons_lite
                            .padding(.horizontal, 20.w_lite)
                        
                        // 统计数据
                        statsSection_lite
                            .padding(.horizontal, 20.w_lite)
                        
                        // 用户帖子列表
                        userPostsSection_lite
                            .padding(.horizontal, 20.w_lite)
                            .padding(.bottom, 120.h_lite)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadUserPosts_lite()
        }
        .onReceive(localData_lite.objectWillChange) { _ in
            // 监听数据变化，自动刷新帖子列表
            loadUserPosts_lite()
        }
        .background(
            ReportActionSheet_lite(
                isShowing_lite: $showReportSheet_lite,
                isBlockUser_lite: true,
                onConfirm_lite: {
                    ReportHelper_lite.blockUser_lite(user_lite: user_lite) {
                        Utils_lite.showSuccess_lite(message_lite: "User blocked successfully")
                        router_lite.pop_lite()
                    }
                }
            )
        )
    }
    
    // MARK: - 私有方法
    
    /// 加载用户帖子
    private func loadUserPosts_lite() {
        userPosts_lite = user_lite.userLike_lite.filter { post in
            localData_lite.titleList_lite.contains { $0.titleId_lite == post.titleId_lite }
        }
    }
    
    // MARK: - 增强背景
    
    /// 增强渐变背景
    private var enhancedBackground_lite: some View {
        ZStack {
            // 主渐变
            LinearGradient(
                colors: [
                    Color(hex: "667eea").opacity(0.06),
                    Color(hex: "F8F9FA"),
                    Color(hex: "f093fb").opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 装饰圆圈
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "f093fb").opacity(0.08), Color.clear],
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: 200.w_lite
                    )
                )
                .frame(width: 300.w_lite, height: 300.h_lite)
                .offset(x: UIScreen.main.bounds.width - 100.w_lite, y: -80.h_lite)
                .blur(radius: 30)
        }
    }
    
    // MARK: - 自定义顶部导航栏
    
    /// 自定义顶部导航栏
    private var customHeaderView_lite: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12.w_lite) {
                // 返回按钮
                Button {
                    router_lite.pop_lite()
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
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "667eea").opacity(0.3), Color(hex: "764ba2").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle_lite())
                
                // 用户名标题
                VStack(alignment: .leading, spacing: 4.h_lite) {
                    Text(user_lite.userName_lite ?? "User")
                        .font(.system(size: 20.sp_lite, weight: .black))
                        .foregroundColor(Color(hex: "212529"))
                        .lineLimit(1)
                    
                    Text("Profile")
                        .font(.system(size: 13.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "6C757D"))
                }
                
                Spacer()
                
                // 举报按钮
                Button {
                    showReportSheet_lite = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white, Color(hex: "FFF5F5")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44.w_lite, height: 44.h_lite)
                        
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 20.sp_lite, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "f5576c"), Color(hex: "f093fb")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "f5576c").opacity(0.3), Color(hex: "f093fb").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(hex: "f5576c").opacity(0.3), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
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
    
    // MARK: - 用户信息区域
    
    /// 用户信息区域
    private var profileSection_lite: some View {
        HStack(spacing: 20.w_lite) {
            // 用户头像 - 使用UserAvatarView_lite组件
            UserAvatarView_lite(
                userId_lite: user_lite.userId_lite ?? 0,
                size_lite: 80
            )
            
            // 用户信息
            VStack(alignment: .leading, spacing: 8.h_lite) {
                // 用户名
                Text(user_lite.userName_lite ?? "Unknown")
                    .font(.system(size: 24.sp_lite, weight: .black))
                    .foregroundColor(Color(hex: "212529"))
                    .lineLimit(1)
                
                // 用户简介
                if let introduce_lite = user_lite.userIntroduce_lite,
                   !introduce_lite.isEmpty {
                    Text(introduce_lite)
                        .font(.system(size: 14.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "6C757D"))
                        .lineLimit(2)
                } else {
                    Text("No bio yet")
                        .font(.system(size: 14.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "ADB5BD"))
                        .italic()
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - 互动按钮
    
    /// 互动按钮组
    private var actionButtons_lite: some View {
        HStack(spacing: 12.w_lite) {
            // 关注/取关按钮
            Button {
                userVM_lite.followUser_lite(user_lite: user_lite)
            } label: {
                HStack(spacing: 10.w_lite) {
                    Image(systemName: userVM_lite.isFollowing_lite(user_lite: user_lite) ? "person.fill.checkmark" : "person.fill.badge.plus")
                        .font(.system(size: 18.sp_lite, weight: .bold))
                    
                    Text(userVM_lite.isFollowing_lite(user_lite: user_lite) ? "Followed" : "Follow")
                        .font(.system(size: 16.sp_lite, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16.h_lite)
                .background(
                    ZStack {
                        LinearGradient(
                            colors: userVM_lite.isFollowing_lite(user_lite: user_lite) ?
                                [Color(hex: "ADB5BD"), Color(hex: "6C757D")] :
                                [Color(hex: "f093fb"), Color(hex: "f5576c")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    }
                )
                .cornerRadius(22.w_lite)
                .overlay(
                    RoundedRectangle(cornerRadius: 22.w_lite)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
                .shadow(
                    color: userVM_lite.isFollowing_lite(user_lite: user_lite) ?
                        Color.black.opacity(0.15) :
                        Color(hex: "f093fb").opacity(0.5),
                    radius: 20,
                    x: 0,
                    y: 10
                )
            }
            .buttonStyle(ScaleButtonStyle_lite())
            
            // 发送消息按钮
            Button {
                router_lite.pop_lite()
                router_lite.toUserChat_lite(user_lite: user_lite)
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56.w_lite, height: 56.h_lite)
                    
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(Circle())
                    .frame(width: 56.w_lite, height: 56.h_lite)
                    
                    Image(systemName: "message.fill")
                        .font(.system(size: 22.sp_lite, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
                .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 20, x: 0, y: 10)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle_lite())
        }
    }
    
    // MARK: - 统计数据区域
    
    /// 统计数据区域
    private var statsSection_lite: some View {
        HStack(spacing: 12.w_lite) {
            // 帖子数
            UserStatCard_lite(
                icon_lite: "photo.on.rectangle.angled",
                count_lite: user_lite.userLike_lite.count,
                label_lite: "Posts",
                colors_lite: [Color(hex: "f093fb"), Color(hex: "f5576c")]
            )
            
            // 关注数
            UserStatCard_lite(
                icon_lite: "person.2.fill",
                count_lite: user_lite.userFollow_lite ?? 0,
                label_lite: "Following",
                colors_lite: [Color(hex: "667eea"), Color(hex: "764ba2")]
            )
            
            // 粉丝数
            UserStatCard_lite(
                icon_lite: "heart.circle.fill",
                count_lite: user_lite.userFans_lite ?? 0,
                label_lite: "Followers",
                colors_lite: [Color(hex: "fa709a"), Color(hex: "fee140")]
            )
        }
    }
    
    // MARK: - 用户帖子列表
    
    /// 用户帖子列表区域
    private var userPostsSection_lite: some View {
        VStack(alignment: .leading, spacing: 16.h_lite) {
            // 标题
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text("Posts")
                    .font(.system(size: 20.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
                
                Text("\(userPosts_lite.count)")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "ADB5BD"))
            }
            .padding(.horizontal, 4.w_lite)
            
            // 帖子列表
            if userPosts_lite.isEmpty {
                // 空状态
                emptyPostsView_lite
            } else {
                ForEach(userPosts_lite) { post_lite in
                    UserPostCard_lite(post_lite: post_lite)
                }
            }
        }
    }
    
    /// 空帖子状态
    private var emptyPostsView_lite: some View {
        VStack(spacing: 16.h_lite) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "E9ECEF"), Color(hex: "DEE2E6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80.w_lite, height: 80.h_lite)
                
                Image(systemName: "photo.stack")
                    .font(.system(size: 36.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "ADB5BD"))
            }
            .padding(.top, 40.h_lite)
            
            Text("No posts yet")
                .font(.system(size: 20.sp_lite, weight: .bold))
                .foregroundColor(Color(hex: "495057"))
            
            Text("This user hasn't shared anything")
                .font(.system(size: 14.sp_lite, weight: .medium))
                .foregroundColor(Color(hex: "ADB5BD"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50.h_lite)
    }
    
}

// MARK: - 用户统计卡片组件

/// 用户统计卡片
struct UserStatCard_lite: View {
    
    let icon_lite: String
    let count_lite: Int
    let label_lite: String
    let colors_lite: [Color]
    
    @State private var appeared_lite = false
    
    var body: some View {
        VStack(spacing: 10.h_lite) {
            // 图标
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: colors_lite.map { $0.opacity(0.3) },
                            center: .center,
                            startRadius: 22.w_lite,
                            endRadius: 30.w_lite
                        )
                    )
                    .frame(width: 56.w_lite, height: 56.h_lite)
                    .blur(radius: 6)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors_lite.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50.w_lite, height: 50.h_lite)
                
                Image(systemName: icon_lite)
                    .font(.system(size: 24.sp_lite, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors_lite,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: colors_lite[0].opacity(0.6), radius: 4, x: 0, y: 2)
            }
            
            // 数字
            Text("\(count_lite)")
                .font(.system(size: 24.sp_lite, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: colors_lite,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 标签
            Text(label_lite)
                .font(.system(size: 12.sp_lite, weight: .bold))
                .foregroundColor(Color(hex: "6C757D"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16.h_lite)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20.w_lite)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(hex: "FAFBFC")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                RoundedRectangle(cornerRadius: 20.w_lite)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20.w_lite)
                .stroke(
                    LinearGradient(
                        colors: colors_lite.map { $0.opacity(0.3) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
        .shadow(color: colors_lite[0].opacity(0.25), radius: 15, x: 0, y: 8)
        .scaleEffect(appeared_lite ? 1.0 : 0.85)
        .opacity(appeared_lite ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double.random(in: 0...0.2))) {
                appeared_lite = true
            }
        }
    }
}

// MARK: - 用户帖子卡片组件

/// 用户帖子卡片
struct UserPostCard_lite: View {
    
    let post_lite: TitleModel_lite
    
    @ObservedObject private var localData_lite = LocalData_lite.shared_lite
    @State private var isPressed_lite = false
    @State private var showReportSheet_lite = false
    
    var body: some View {
        Button {
            Router_lite.shared_lite.toPostDetail_liteui(post_lite: post_lite)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // 媒体预览 - 使用MediaDisplayView_lite组件
                ZStack(alignment: .topTrailing) {
                    Group {
                        if let mediaPath_lite = post_lite.titleMeidas_lite.first {
                            MediaDisplayView_lite(
                                mediaPath_lite: mediaPath_lite,
                                isVideo_lite: mediaPath_lite.contains("video"),
                                cornerRadius_lite: 0
                            )
                            .frame(height: 200.h_lite)
                        } else {
                            // 无媒体时显示渐变占位
                            ZStack {
                                LinearGradient(
                                    colors: MediaConfig_lite.getGradientColors_lite(for: post_lite.title_lite),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                // 装饰图案
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 120.w_lite, height: 120.h_lite)
                                    .offset(x: -40.w_lite, y: -30.h_lite)
                                    .blur(radius: 20)
                                
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 100.w_lite, height: 100.h_lite)
                                    .offset(x: 50.w_lite, y: 30.h_lite)
                                    .blur(radius: 18)
                                
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 50.sp_lite, weight: .bold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(height: 200.h_lite)
                        }
                    }
                    
                    // 举报按钮（右上角）
                    Button {
                        showReportSheet_lite = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 32.w_lite, height: 32.h_lite)
                            
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14.sp_lite, weight: .bold))
                                .foregroundColor(Color(hex: "6C757D"))
                        }
                    }
                    .buttonStyle(ScaleButtonStyle_lite())
                    .padding(10.w_lite)
                }
                
                // 帖子信息（添加顶部间距）
                VStack(alignment: .leading, spacing: 8.h_lite) {
                    Text(post_lite.title_lite)
                        .font(.system(size: 17.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "212529"))
                        .lineLimit(2)
                    
                    Text(post_lite.titleContent_lite)
                        .font(.system(size: 14.sp_lite, weight: .regular))
                        .foregroundColor(Color(hex: "6C757D"))
                        .lineLimit(2)
                    
                    // 统计信息
                    HStack(spacing: 16.w_lite) {
                        HStack(spacing: 4.w_lite) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12.sp_lite))
                                .foregroundColor(Color(hex: "f5576c"))
                            
                            Text("\(post_lite.likes_lite)")
                                .font(.system(size: 13.sp_lite, weight: .semibold))
                                .foregroundColor(Color(hex: "6C757D"))
                        }
                        
                        HStack(spacing: 4.w_lite) {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 12.sp_lite))
                                .foregroundColor(Color(hex: "667eea"))
                            
                            Text("\(post_lite.reviews_lite.count)")
                                .font(.system(size: 13.sp_lite, weight: .semibold))
                                .foregroundColor(Color(hex: "6C757D"))
                        }
                    }
                }
                .padding(.horizontal, 16.w_lite)
                .padding(.vertical, 16.h_lite)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24.w_lite))
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "FAFBFC")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 24.w_lite)
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
                RoundedRectangle(cornerRadius: 24.w_lite)
                    .stroke(Color(hex: "E9ECEF"), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
            .scaleEffect(isPressed_lite ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed_lite = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed_lite = false
                    }
                }
        )
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
    }
    
    /// 举报帖子
    private func reportPost_lite() {
        ReportHelper_lite.reportPost_lite(post_lite: post_lite)
    }
}
