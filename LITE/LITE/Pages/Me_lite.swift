import SwiftUI

// MARK: - 个人中心页
// 核心作用：展示当前用户的个人信息、统计数据和发布内容
// 设计思路：顶部用户信息+统计数据+内容展示，类似社交媒体个人主页
// 关键功能：用户信息、数据统计、帖子/喜欢切换展示、快捷操作入口

/// 内容标签页枚举
enum ContentTab_lite {
    case posts_lite
    case likes_lite
}

/// 个人中心页
struct Me_lite: View {
    
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject private var router_lite = Router_lite.shared_lite
    
    @State private var pulseAnimation_lite = false
    @State private var rotateAnimation_lite = false
    @State private var selectedTab_lite: ContentTab_lite = .posts_lite
    
    var body: some View {
        ZStack {
            // 增强渐变背景
            enhancedBackground_lite
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 顶部用户信息区域
                    profileHeaderSection_lite
                        .padding(.horizontal, 20.w_lite)
                        .padding(.top, 20.h_lite)
                    
                    // 快捷按钮（编辑+设置）
                    quickActionButtons_lite
                        .padding(.horizontal, 20.w_lite)
                        .padding(.top, 20.h_lite)
                    
                    // 数据统计区域
                    statsSection_lite
                        .padding(.horizontal, 20.w_lite)
                        .padding(.top, 20.h_lite)
                    
                    // 内容切换标签
                    contentTabBar_lite
                        .padding(.top, 24.h_lite)
                    
                    // 内容展示区域
                    contentSection_lite
                        .padding(.horizontal, 20.w_lite)
                        .padding(.top, 20.h_lite)
                        .padding(.bottom, 120.h_lite)
                }
            }
        }
        .onAppear {
            startAnimations_lite()
        }
    }
    
    // MARK: - 顶部用户信息区域
    
    /// 顶部用户信息区域
    private var profileHeaderSection_lite: some View {
        HStack(spacing: 20.w_lite) {
            // 用户头像
            profileAvatarView_lite
            
            // 用户信息
            VStack(alignment: .leading, spacing: 8.h_lite) {
                // 用户名
                Text(userVM_lite.getCurrentUser_lite().userName_lite ?? "Guest")
                    .font(.system(size: 24.sp_lite, weight: .black))
                    .foregroundColor(Color(hex: "212529"))
                    .lineLimit(1)
                
                // 用户简介
                if let introduce_lite = userVM_lite.getCurrentUser_lite().userIntroduce_lite,
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
    
    /// 用户头像视图
    private var profileAvatarView_lite: some View {
        ZStack {
            // 外圈光晕动画
            Circle()
                .fill(
                    RadialGradient(
                        colors: MediaConfig_lite.getGradientColors_lite(
                            for: userVM_lite.getCurrentUser_lite().userName_lite ?? ""
                        ).map { $0.opacity(0.3) },
                        center: .center,
                        startRadius: 38.w_lite,
                        endRadius: 50.w_lite
                    )
                )
                .frame(width: 94.w_lite, height: 94.h_lite)
                .scaleEffect(pulseAnimation_lite ? 1.15 : 1.0)
                .opacity(pulseAnimation_lite ? 0.4 : 0.9)
                .blur(radius: 6)
            
            // 旋转光环
            Circle()
                .trim(from: 0, to: 0.65)
                .stroke(
                    LinearGradient(
                        colors: MediaConfig_lite.getGradientColors_lite(
                            for: userVM_lite.getCurrentUser_lite().userName_lite ?? ""
                        ).map { $0.opacity(0.6) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 88.w_lite, height: 88.h_lite)
                .rotationEffect(.degrees(rotateAnimation_lite ? 360 : 0))
            
            // 主头像
            Circle()
                .fill(
                    LinearGradient(
                        colors: MediaConfig_lite.getGradientColors_lite(
                            for: userVM_lite.getCurrentUser_lite().userName_lite ?? ""
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80.w_lite, height: 80.h_lite)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.8), Color.white.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
            
            // 用户名首字母或图标
            if let userName_lite = userVM_lite.getCurrentUser_lite().userName_lite,
               !userName_lite.isEmpty {
                Text(String(userName_lite.prefix(1)).uppercased())
                    .font(.system(size: 36.sp_lite, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 36.sp_lite, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
            }
        }
        .shadow(color: MediaConfig_lite.getGradientColors_lite(for: userVM_lite.getCurrentUser_lite().userName_lite ?? "")[0].opacity(0.4), radius: 20, x: 0, y: 10)
        .shadow(color: Color.black.opacity(0.12), radius: 15, x: 0, y: 8)
    }
    
    // MARK: - 快捷按钮
    
    /// 快捷操作按钮组（增强版）
    private var quickActionButtons_lite: some View {
        HStack(spacing: 12.w_lite) {
            // 编辑资料按钮（增强版）
            Button {
                router_lite.toEditInfo_liteui()
            } label: {
                HStack(spacing: 10.w_lite) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 20.sp_lite, weight: .bold))
                    
                    Text("Edit Profile")
                        .font(.system(size: 16.sp_lite, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16.h_lite)
                .background(
                    ZStack {
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
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
                .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 20, x: 0, y: 10)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle_lite())
            
            // 设置按钮（增强版）
            Button {
                router_lite.toSettings_lite()
            } label: {
                HStack(spacing: 10.w_lite) {
                    Image(systemName: "gearshape.circle.fill")
                        .font(.system(size: 20.sp_lite, weight: .bold))
                    
                    Text("Settings")
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
                .shadow(color: Color(hex: "f093fb").opacity(0.5), radius: 20, x: 0, y: 10)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle_lite())
        }
    }
    
    // MARK: - 增强背景
    
    /// 增强渐变背景
    private var enhancedBackground_lite: some View {
        ZStack {
            // 主渐变
            LinearGradient(
                colors: [
                    Color(hex: "F8F9FA"),
                    Color(hex: "FFFFFF"),
                    Color(hex: "F8F9FA")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 装饰圆圈
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "667eea").opacity(0.06), Color.clear],
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: 200.w_lite
                    )
                )
                .frame(width: 350.w_lite, height: 350.h_lite)
                .offset(x: UIScreen.main.bounds.width - 100.w_lite, y: -100.h_lite)
                .blur(radius: 30)
        }
    }
    
    // MARK: - 数据统计区域
    
    /// 数据统计区域（增强版）
    private var statsSection_lite: some View {
        HStack(spacing: 12.w_lite) {
            // 发布帖子数
            EnhancedStatItem_lite(
                icon_lite: "photo.on.rectangle.angled",
                count_lite: userVM_lite.getCurrentUser_lite().userPosts_lite.count,
                label_lite: "Posts",
                colors_lite: [Color(hex: "f093fb"), Color(hex: "f5576c")]
            )
            
            // 关注数
            EnhancedStatItem_lite(
                icon_lite: "person.2.fill",
                count_lite: userVM_lite.getCurrentUser_lite().userFollow_lite.count,
                label_lite: "Following",
                colors_lite: [Color(hex: "667eea"), Color(hex: "764ba2")]
            )
            
            // 被关注数（粉丝数）
            EnhancedStatItem_lite(
                icon_lite: "heart.circle.fill",
                count_lite: 0,
                label_lite: "Followers",
                colors_lite: [Color(hex: "fa709a"), Color(hex: "fee140")]
            )
        }
    }
    
    // MARK: - 内容切换标签
    
    /// 内容切换标签栏（优化版）
    private var contentTabBar_lite: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // 我的帖子
                EnhancedTabButton_lite(
                    icon_lite: "photo.on.rectangle.angled",
                    title_lite: "My Posts",
                    isSelected_lite: selectedTab_lite == .posts_lite,
                    onTap_lite: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTab_lite = .posts_lite
                        }
                    }
                )
                
                // 我喜欢的
                EnhancedTabButton_lite(
                    icon_lite: "heart.fill",
                    title_lite: "Favorites",
                    isSelected_lite: selectedTab_lite == .likes_lite,
                    onTap_lite: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTab_lite = .likes_lite
                        }
                    }
                )
            }
            .background(Color.white)
            .cornerRadius(20.w_lite)
            .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
        }
        .padding(.horizontal, 20.w_lite)
    }
    
    // MARK: - 内容展示区域
    
    /// 内容展示区域（增强版）
    private var contentSection_lite: some View {
        Group {
            if selectedTab_lite == .posts_lite {
                // 显示我发布的帖子
                let myPosts_lite = userVM_lite.getCurrentUser_lite().userPosts_lite
                
                VStack(spacing: 16.h_lite) {
                    if myPosts_lite.isEmpty {
                        emptyStateView_lite(
                            icon_lite: "photo.on.rectangle.angled",
                            title_lite: "No posts yet",
                            subtitle_lite: "Share your first outfit to get started"
                        )
                    } else {
                        ForEach(myPosts_lite) { post_lite in
                            PostCard_lite(post_lite: post_lite)
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                // 显示我喜欢的帖子
                let likedPosts_lite = userVM_lite.getCurrentUser_lite().userLike_lite
                
                VStack(spacing: 16.h_lite) {
                    if likedPosts_lite.isEmpty {
                        emptyStateView_lite(
                            icon_lite: "heart",
                            title_lite: "No favorites yet",
                            subtitle_lite: "Like posts to save them here"
                        )
                    } else {
                        ForEach(likedPosts_lite) { post_lite in
                            PostCard_lite(post_lite: post_lite)
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }
    
    // MARK: - 空状态视图
    
    /// 空状态视图
    private func emptyStateView_lite(
        icon_lite: String,
        title_lite: String,
        subtitle_lite: String
    ) -> some View {
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
                
                Image(systemName: icon_lite)
                    .font(.system(size: 36.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "ADB5BD"))
            }
            .padding(.top, 40.h_lite)
            
            Text(title_lite)
                .font(.system(size: 20.sp_lite, weight: .bold))
                .foregroundColor(Color(hex: "495057"))
            
            Text(subtitle_lite)
                .font(.system(size: 14.sp_lite, weight: .medium))
                .foregroundColor(Color(hex: "ADB5BD"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50.h_lite)
    }
    
    // MARK: - 辅助方法
    
    /// 启动动画
    private func startAnimations_lite() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseAnimation_lite.toggle()
        }
        
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            rotateAnimation_lite.toggle()
        }
    }
}

// MARK: - 增强统计项组件

/// 增强统计项
struct EnhancedStatItem_lite: View {
    
    let icon_lite: String
    let count_lite: Int
    let label_lite: String
    let colors_lite: [Color]
    
    @State private var appeared_lite = false
    
    var body: some View {
        VStack(spacing: 10.h_lite) {
            // 图标（增强版）
            ZStack {
                // 外圈光晕
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
                
                // 主圆圈
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors_lite.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50.w_lite, height: 50.h_lite)
                
                // 图标
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

// MARK: - 增强标签按钮组件

/// 增强标签按钮（优化版）
struct EnhancedTabButton_lite: View {
    
    let icon_lite: String
    let title_lite: String
    let isSelected_lite: Bool
    let onTap_lite: () -> Void
    
    var body: some View {
        Button(action: onTap_lite) {
            VStack(spacing: 0) {
                HStack(spacing: 8.w_lite) {
                    Image(systemName: icon_lite)
                        .font(.system(size: 17.sp_lite, weight: .bold))
                    
                    Text(title_lite)
                        .font(.system(size: 16.sp_lite, weight: .bold))
                }
                .foregroundStyle(
                    isSelected_lite ?
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color(hex: "ADB5BD"), Color(hex: "ADB5BD")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
                .padding(.vertical, 16.h_lite)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected_lite ?
                        LinearGradient(
                            colors: [Color(hex: "667eea").opacity(0.08), Color(hex: "764ba2").opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.clear, Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
                
                // 底部指示器
                ZStack {
                    // 基础分隔线
                    Rectangle()
                        .fill(Color(hex: "F1F3F5"))
                        .frame(height: 1)
                    
                    // 选中指示器
                    if isSelected_lite {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 3.h_lite)
                            .cornerRadius(1.5.h_lite)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.5, anchor: .bottom).combined(with: .opacity),
                                removal: .scale(scale: 0.5, anchor: .bottom).combined(with: .opacity)
                            ))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 帖子卡片组件

/// 帖子卡片（用于个人中心）
struct PostCard_lite: View {
    
    let post_lite: TitleModel_lite
    
    @State private var isPressed_lite = false
    
    var body: some View {
        Button {
            Router_lite.shared_lite.toPostDetail_liteui(post_lite: post_lite)
        } label: {
            VStack(alignment: .leading, spacing: 14.h_lite) {
                // 媒体预览
                ZStack {
                    RoundedRectangle(cornerRadius: 20.w_lite)
                        .fill(
                            LinearGradient(
                                colors: MediaConfig_lite.getGradientColors_lite(for: post_lite.title_lite),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200.h_lite)
                    
                    // 装饰图案
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120.w_lite, height: 120.h_lite)
                        .offset(x: -40.w_lite, y: -30.h_lite)
                        .blur(radius: 20)
                    
                    Image(systemName: "photo.fill")
                        .font(.system(size: 50.sp_lite, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // 帖子信息
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
                .padding(.bottom, 16.h_lite)
            }
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
    }
}
