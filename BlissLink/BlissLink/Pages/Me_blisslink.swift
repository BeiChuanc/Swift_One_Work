import SwiftUI

// MARK: - 个人中心页
// 核心作用：展示当前用户的个人信息、统计数据、帖子列表
// 设计思路：现代化卡片设计，数据可视化，Tab切换帖子，动画自然有趣
// 关键功能：用户信息展示、统计数据、我的帖子/喜欢的帖子切换

/// 帖子Tab枚举
enum PostTab_blisslink: Equatable {
    case myPosts_blisslink
    case likedPosts_blisslink
}

/// 个人中心页
struct Me_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var userVM_blisslink = UserViewModel_blisslink.shared_blisslink
    @ObservedObject var router_blisslink = Router_blisslink.shared_blisslink
    @ObservedObject var practiceVM_blisslink = PracticeViewModel_blisslink.shared_blisslink
    @ObservedObject var titleVM_blisslink = TitleViewModel_blisslink.shared_blisslink
    @ObservedObject var localData_blisslink = LocalData_blisslink.shared_blisslink
    
    // MARK: - 状态
    
    @State private var selectedTab_blisslink: PostTab_blisslink = .myPosts_blisslink
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层
            ZStack {
                // 主背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "F0F4FF"),
                        Color(hex: "FFF5F7"),
                        Color(hex: "F7FAFC")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 顶部装饰背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "667EEA").opacity(0.15),
                        Color(hex: "FA8BFF").opacity(0.1),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 320.h_blisslink)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // 装饰圆圈
                Circle()
                    .fill(Color(hex: "667EEA").opacity(0.1))
                    .frame(width: 300.w_blisslink, height: 300.h_blisslink)
                    .offset(x: -150.w_blisslink, y: -180.h_blisslink)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color(hex: "FA8BFF").opacity(0.08))
                    .frame(width: 330.w_blisslink, height: 330.h_blisslink)
                    .offset(x: 165.w_blisslink, y: 180.h_blisslink)
                    .blur(radius: 55)
                
                Circle()
                    .fill(Color(hex: "2BD2FF").opacity(0.06))
                    .frame(width: 280.w_blisslink, height: 280.h_blisslink)
                    .offset(x: -80.w_blisslink, y: 500.h_blisslink)
                    .blur(radius: 48)
            }
            .ignoresSafeArea()
            
            // 内容层
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
                .padding(.top, 70.h_blisslink)
                .padding(.bottom, 100.h_blisslink)
            }
        }
    }
    
    // MARK: - 用户信息卡片
    
    private var userProfileCard_blisslink: some View {
        VStack(spacing: 20.h_blisslink) {
            // 头像和基本信息
            VStack(spacing: 16.h_blisslink) {
                // 头像（使用 CurrentUserAvatarView 组件）
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
                    CurrentUserAvatarView_blisslink(
                        size_blisslink: 100.w_blisslink,
                        showOnlineIndicator_blisslink: true,
                        showEditButton_blisslink: false
                    )
                    .shadow(color: Color(hex: "667EEA").opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .bounceIn_blisslink(delay_blisslink: 0.1)
                
                // 用户名和简介
                VStack(spacing: 10.h_blisslink) {
                    // 用户名
                    Text(currentUser_blisslink.userName_blisslink ?? "Guest")
                        .font(.system(size: 24.sp_blisslink, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // 验证徽章
                    HStack(spacing: 6.w_blisslink) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14.sp_blisslink))
                            .foregroundColor(Color(hex: "56CCF2"))
                        
                        Text("Verified Member")
                            .font(.system(size: 13.sp_blisslink, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // 用户简介
                    Text(userIntro_blisslink.isEmpty ? "Nothing yet." : userIntro_blisslink)
                        .font(.system(size: 14.sp_blisslink))
                        .foregroundColor(userIntro_blisslink.isEmpty ? .secondary.opacity(0.7) : .secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 20.w_blisslink)
                        .padding(.top, 4.h_blisslink)
                }
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.2)
            }
            
            // 按钮区域
            VStack(spacing: 10.h_blisslink) {
                // 编辑按钮
                Button(action: {
                    router_blisslink.toEditInfo_blisslink()
                }) {
                    HStack(spacing: 8.w_blisslink) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14.sp_blisslink, weight: .semibold))
                        
                        Text("Edit Profile")
                            .font(.system(size: 15.sp_blisslink, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "667EEA"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12.h_blisslink)
                    .background(
                        RoundedRectangle(cornerRadius: 12.w_blisslink)
                            .fill(Color(hex: "667EEA").opacity(0.1))
                    )
                }
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.25)
                
                // 设置按钮
                Button(action: {
                    // 触觉反馈
                    let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
                    generator_blisslink.impactOccurred()
                    
                    router_blisslink.toSettings_blisslink()
                }) {
                    HStack(spacing: 8.w_blisslink) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14.sp_blisslink, weight: .semibold))
                        
                        Text("Settings")
                            .font(.system(size: 15.sp_blisslink, weight: .semibold))
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12.h_blisslink)
                    .background(
                        RoundedRectangle(cornerRadius: 12.w_blisslink)
                            .fill(Color.gray.opacity(0.08))
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
                value_blisslink: "\(currentUser_blisslink.userPosts_blisslink.count)",
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
                value_blisslink: "\(currentUser_blisslink.userFollow_blisslink.count)",
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
                value_blisslink: "0",
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
    
    /// 统计行
    private func statRow_blisslink(
        icon_blisslink: String,
        title_blisslink: String,
        value_blisslink: String,
        gradientColors_blisslink: [Color]
    ) -> some View {
        HStack(spacing: 12.w_blisslink) {
            // 图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors_blisslink),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44.w_blisslink, height: 44.h_blisslink)
                
                Image(systemName: icon_blisslink)
                    .font(.system(size: 20.sp_blisslink, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // 标题
            Text(title_blisslink)
                .font(.system(size: 15.sp_blisslink, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // 数值
            Text(value_blisslink)
                .font(.system(size: 18.sp_blisslink, weight: .bold))
                .foregroundColor(.primary)
                .monospacedDigit()
        }
    }
    
    // MARK: - 帖子Tab切换区域
    
    private var postsTabSection_blisslink: some View {
        VStack(spacing: 0) {
            // Tab切换栏
            HStack(spacing: 0) {
                // 我的帖子
                tabButton_blisslink(
                    icon_blisslink: "doc.text.fill",
                    title_blisslink: "My Posts",
                    count_blisslink: currentUser_blisslink.userPosts_blisslink.count,
                    tab_blisslink: .myPosts_blisslink,
                    isSelected_blisslink: selectedTab_blisslink == .myPosts_blisslink
                )
                
                // 喜欢的帖子
                tabButton_blisslink(
                    icon_blisslink: "heart.fill",
                    title_blisslink: "Liked",
                    count_blisslink: currentUser_blisslink.userLike_blisslink.count,
                    tab_blisslink: .likedPosts_blisslink,
                    isSelected_blisslink: selectedTab_blisslink == .likedPosts_blisslink
                )
            }
            .padding(.horizontal, 20.w_blisslink)
            .padding(.top, 16.h_blisslink)
            .background(Color.white)
            
            // 帖子列表
            TabView(selection: $selectedTab_blisslink) {
                // 我的帖子列表
                postsListView_blisslink(posts_blisslink: currentUser_blisslink.userPosts_blisslink)
                    .tag(PostTab_blisslink.myPosts_blisslink)
                
                // 喜欢的帖子列表
                postsListView_blisslink(posts_blisslink: currentUser_blisslink.userLike_blisslink)
                    .tag(PostTab_blisslink.likedPosts_blisslink)
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
        tab_blisslink: PostTab_blisslink,
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
                        
                        Image(systemName: selectedTab_blisslink == .myPosts_blisslink ? "doc.text" : "heart")
                            .font(.system(size: 40.sp_blisslink))
                            .foregroundColor(Color(hex: "667EEA").opacity(0.6))
                    }
                    
                    Text(selectedTab_blisslink == .myPosts_blisslink ? "No posts yet" : "No liked posts yet")
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
    
    /// 当前用户
    private var currentUser_blisslink: LoginUserModel_blisslink {
        return userVM_blisslink.getCurrentUser_blisslink()
    }
    
    /// 用户简介
    private var userIntro_blisslink: String {
        return currentUser_blisslink.userIntroduce_blisslink ?? ""
    }
}
