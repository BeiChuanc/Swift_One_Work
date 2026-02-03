import SwiftUI

// MARK: - 帖子详情页
// 核心作用：展示帖子的详细内容、评论列表、互动操作
// 设计思路：现代化卡片设计，评论列表，点赞评论功能，动画自然有趣
// 关键功能：帖子详情展示、点赞、评论、举报/删除

/// 帖子详情页
struct Detail_baseswift: View {
    
    // MARK: - 属性
    
    /// 帖子数据
    let post_baseswiftui: TitleModel_baseswiftui
    
    // MARK: - ViewModels
    
    @ObservedObject var titleVM_baseswiftui = TitleViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    @ObservedObject var localData_baseswiftui = LocalData_baseswiftui.shared_baseswiftui
    
    // MARK: - 状态
    
    @State private var isLiked_blisslink: Bool = false
    @State private var commentText_blisslink: String = ""
    @State private var showReportSheet_blisslink: Bool = false
    @State private var showDeleteAlert_blisslink: Bool = false
    @FocusState private var isCommentFocused_blisslink: Bool
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层
            ZStack {
                // 主背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "F0F9FF"),
                        Color(hex: "F7FAFC"),
                        Color(hex: "FFF5F7")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 顶部装饰渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "667EEA").opacity(0.08),
                        Color(hex: "FA8BFF").opacity(0.05),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300.h_baseswiftui)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // 装饰圆圈
                Circle()
                    .fill(Color(hex: "667EEA").opacity(0.06))
                    .frame(width: 300.w_baseswiftui, height: 300.h_baseswiftui)
                    .offset(x: -150.w_baseswiftui, y: -200.h_baseswiftui)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color(hex: "2BD2FF").opacity(0.05))
                    .frame(width: 280.w_baseswiftui, height: 280.h_baseswiftui)
                    .offset(x: 140.w_baseswiftui, y: 350.h_baseswiftui)
                    .blur(radius: 48)
            }
            .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar_blisslink
                
                // 内容区域
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24.h_baseswiftui) {
                        // 帖子内容卡片
                        postContentCard_blisslink
                        
                        // 互动按钮区域
                        interactionBar_blisslink
                        
                        // 评论列表
                        commentsSection_blisslink
                    }
                    .padding(.horizontal, 20.w_baseswiftui)
                    .padding(.top, 20.h_baseswiftui)
                    .padding(.bottom, 100.h_baseswiftui)
                }
                
                // 评论输入框
                commentInputBar_blisslink
            }
        }
        .navigationBarHidden(true)
        .alert("Delete Post", isPresented: $showDeleteAlert_blisslink) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deletePost_blisslink()
            }
        } message: {
            Text("Are you sure you want to delete this post? This action cannot be undone.")
        }
        .onAppear {
            initializeData_blisslink()
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar_blisslink: some View {
        HStack {
            // 返回按钮
            Button(action: {
                router_baseswiftui.pop_baseswiftui()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36.w_baseswiftui, height: 36.h_baseswiftui)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
            }
            
            Spacer()
            
            // 标题
            HStack(spacing: 8.w_baseswiftui) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Post Detail")
                    .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // 更多按钮（举报/删除）
            Button(action: {
                // 触觉反馈
                let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
                generator_blisslink.impactOccurred()
                
                // 根据是否是自己的帖子显示不同的操作
                if isMyPost_blisslink {
                    // 自己的帖子 - 显示删除确认
                    showDeleteAlert_blisslink = true
                } else {
                    // 别人的帖子 - 显示举报选项
                    showReportSheet_blisslink = true
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 36.w_baseswiftui, height: 36.h_baseswiftui)
                    
                    Image(systemName: isMyPost_blisslink ? "trash" : "ellipsis")
                        .font(.system(size: 16.sp_baseswiftui, weight: .bold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isMyPost_blisslink ? 0 : 90))
                }
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1.5.w_baseswiftui)
                )
            }
        }
        .padding(.horizontal, 20.w_baseswiftui)
        .padding(.top, 10.h_baseswiftui)
        .padding(.bottom, 12.h_baseswiftui)
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
                    .frame(height: 3.h_baseswiftui)
                }
                
                // 举报ActionSheet
                ReportActionSheet_blisslink(
                    isShowing_blisslink: $showReportSheet_blisslink,
                    isBlockUser_blisslink: false,
                    onConfirm_blisslink: {
                        handleReportOrDelete_blisslink()
                    }
                )
            }
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - 帖子内容卡片
    
    private var postContentCard_blisslink: some View {
        HStack(spacing: 0) {
            // 左侧装饰条
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2"), Color(hex: "FA8BFF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 5.w_baseswiftui)
            .cornerRadius(2.5.w_baseswiftui)
            
            // 主内容区域
            VStack(alignment: .leading, spacing: 20.h_baseswiftui) {
            // 用户信息区域（增强版）
            HStack(spacing: 14.w_baseswiftui) {
                // 用户头像（添加光晕）
                ZStack {
                    // 外层光晕
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "667EEA").opacity(0.25),
                                    Color(hex: "764BA2").opacity(0.25)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60.w_baseswiftui, height: 60.h_baseswiftui)
                        .blur(radius: 8)
                    
                    UserAvatarView_baseswiftui(
                        userId_baseswiftui: post_baseswiftui.titleUserId_baseswiftui,
                        avatarPath_baseswiftui: getUserAvatarPath_blisslink(),
                        userName_baseswiftui: post_baseswiftui.titleUserName_baseswiftui,
                        size_baseswiftui: 54.w_baseswiftui,
                        isClickable_baseswiftui: true,
                        onTapped_baseswiftui: {
                            handlePostUserTap_blisslink()
                        }
                    )
                }
                
                VStack(alignment: .leading, spacing: 6.h_baseswiftui) {
                    // 用户名和徽章
                    HStack(spacing: 6.w_baseswiftui) {
                        Text(post_baseswiftui.titleUserName_baseswiftui)
                            .font(.system(size: 17.sp_baseswiftui, weight: .bold))
                            .foregroundColor(.primary)
                        
                        // 验证徽章（增强）
                        ZStack {
                            Circle()
                                .fill(Color(hex: "56CCF2").opacity(0.15))
                                .frame(width: 22.w_baseswiftui, height: 22.h_baseswiftui)
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14.sp_baseswiftui))
                                .foregroundColor(Color(hex: "56CCF2"))
                        }
                    }
                    
                    // 时间和阅读量
                    HStack(spacing: 8.w_baseswiftui) {
                        HStack(spacing: 4.w_baseswiftui) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11.sp_baseswiftui))
                            
                            Text("2 hours ago")
                                .font(.system(size: 13.sp_baseswiftui, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                        
                        Circle()
                            .fill(Color.secondary.opacity(0.5))
                            .frame(width: 3.w_baseswiftui, height: 3.h_baseswiftui)
                        
                        HStack(spacing: 4.w_baseswiftui) {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 11.sp_baseswiftui))
                            
                            Text("128")
                                .font(.system(size: 13.sp_baseswiftui, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.1)
            
            // 分隔线
            Divider()
                .padding(.vertical, 4.h_baseswiftui)
            
            // 标题区域（增强）
            if !post_baseswiftui.title_baseswiftui.isEmpty {
                HStack(spacing: 10.w_baseswiftui) {
                    // 装饰线条
                    RoundedRectangle(cornerRadius: 2.w_baseswiftui)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4.w_baseswiftui, height: 32.h_baseswiftui)
                    
                    Text(post_baseswiftui.title_baseswiftui)
                        .font(.system(size: 24.sp_baseswiftui, weight: .bold))
                        .foregroundColor(.primary)
                        .lineSpacing(4.h_baseswiftui)
                }
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.15)
            }
            
            // 内容区域（增强）
            Text(post_baseswiftui.titleContent_baseswiftui)
                .font(.system(size: 16.sp_baseswiftui, weight: .regular))
                .foregroundColor(.secondary)
                .lineSpacing(8.h_baseswiftui)
                .padding(.horizontal, 4.w_baseswiftui)
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.2)
            
            // 媒体展示（增强）
            if let firstMedia_blisslink = post_baseswiftui.titleMeidas_baseswiftui.first {
                ZStack(alignment: .bottomLeading) {
                    MediaDisplayView_baseswiftui(
                        mediaPath_baseswiftui: firstMedia_blisslink,
                        isVideo_baseswiftui: false,
                        cornerRadius_baseswiftui: 18.w_baseswiftui
                    )
                    .frame(height: 300.h_baseswiftui)
                    .clipped()
                    
                    // 底部渐变遮罩
                    VStack {
                        Spacer()
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 80.h_baseswiftui)
                    }
                    .cornerRadius(18.w_baseswiftui)
                    
                    // 媒体信息标签
                    HStack(spacing: 8.w_baseswiftui) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 12.sp_baseswiftui))
                        
                        Text("1 / 1")
                            .font(.system(size: 13.sp_baseswiftui, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12.w_baseswiftui)
                    .padding(.vertical, 6.h_baseswiftui)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                    )
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .clipShape(Capsule())
                    .padding(16.w_baseswiftui)
                }
                .shadow(color: Color.black.opacity(0.12), radius: 15, x: 0, y: 8)
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.25)
                .contentShape(Rectangle())
                .onTapGesture {
                    // 触觉反馈
                    let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
                    generator_blisslink.impactOccurred()
                    
                    // 判断是否是视频（根据文件扩展名或命名判断）
                    let isVideo_blisslink = firstMedia_blisslink.contains("media_") || 
                                           firstMedia_blisslink.hasSuffix(".mp4") || 
                                           firstMedia_blisslink.hasSuffix(".mov")
                    
                    // 跳转到媒体播放器
                    router_baseswiftui.toMediaPlayer_baseswiftui(
                        mediaUrl_baseswiftui: firstMedia_blisslink,
                        isVideo_baseswiftui: isVideo_blisslink
                    )
                }
            }
            
            // 练习标签（如果是练习成果）- 增强
            if let postType_blisslink = post_baseswiftui.postType_blisslink,
               postType_blisslink == .practiceAchievement_blisslink {
                HStack(spacing: 12.w_baseswiftui) {
                    // 图标背景
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36.w_baseswiftui, height: 36.h_baseswiftui)
                        
                        Image(systemName: "figure.yoga")
                            .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2.h_baseswiftui) {
                        Text("Practice Achievement")
                            .font(.system(size: 14.sp_baseswiftui, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Shared yoga practice moment")
                            .font(.system(size: 12.sp_baseswiftui, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(16.w_baseswiftui)
                .background(
                    RoundedRectangle(cornerRadius: 16.w_baseswiftui)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "667EEA").opacity(0.08),
                                    Color(hex: "764BA2").opacity(0.12)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16.w_baseswiftui)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "667EEA").opacity(0.3),
                                    Color(hex: "764BA2").opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5.w_baseswiftui
                        )
                )
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.3)
            }
            }
            .padding(.leading, 20.w_baseswiftui)
        }
        .padding(.vertical, 24.w_baseswiftui)
        .padding(.trailing, 24.w_baseswiftui)
        .padding(.leading, 8.w_baseswiftui)
        .background(
            ZStack {
                // 主背景
                RoundedRectangle(cornerRadius: 28.w_baseswiftui)
                    .fill(Color.white)
                
                // 顶部渐变装饰
                VStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "667EEA").opacity(0.05),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100.h_baseswiftui)
                    
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 28.w_baseswiftui))
            }
            .shadow(color: Color.black.opacity(0.1), radius: 18, x: 0, y: 10)
        )
        .bounceIn_blisslink(delay_blisslink: 0.1)
    }
    
    // MARK: - 互动按钮区域
    
    private var interactionBar_blisslink: some View {
        HStack(spacing: 0) {
            // 点赞按钮（增强）
            Button(action: {
                handleLike_blisslink()
            }) {
                HStack(spacing: 12.w_baseswiftui) {
                    ZStack {
                        // 外层光晕
                        if isLiked_blisslink {
                            Circle()
                                .fill(Color.red.opacity(0.25))
                                .frame(width: 56.w_baseswiftui, height: 56.h_baseswiftui)
                                .blur(radius: 10)
                        }
                        
                        // 主背景
                        Circle()
                            .fill(
                                isLiked_blisslink ?
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color(hex: "FF6B6B")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.12), Color.gray.opacity(0.12)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52.w_baseswiftui, height: 52.h_baseswiftui)
                        
                        Image(systemName: isLiked_blisslink ? "heart.fill" : "heart")
                            .font(.system(size: 24.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(isLiked_blisslink ? .white : .secondary)
                    }
                    
                    // 文字和数量
                    VStack(alignment: .leading, spacing: 2.h_baseswiftui) {
                        Text("Like")
                            .font(.system(size: 13.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(isLiked_blisslink ? .red : .secondary)
                        
                        Text("\(post_baseswiftui.likes_baseswiftui)")
                            .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                            .foregroundColor(isLiked_blisslink ? .red : .primary)
                            .monospacedDigit()
                    }
                }
                .padding(.horizontal, 20.w_baseswiftui)
                .padding(.vertical, 14.h_baseswiftui)
                .background(
                    RoundedRectangle(cornerRadius: 16.w_baseswiftui)
                        .fill(isLiked_blisslink ? Color.red.opacity(0.08) : Color.gray.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16.w_baseswiftui)
                        .stroke(
                            isLiked_blisslink ? Color.red.opacity(0.25) : Color.gray.opacity(0.15),
                            lineWidth: 1.5.w_baseswiftui
                        )
                )
            }
            .scaleEffect(isLiked_blisslink ? 1.05 : 1.0)
            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: isLiked_blisslink)
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.35)
            
            Spacer()
            
            // 评论按钮（增强）
            Button(action: {
                isCommentFocused_blisslink = true
            }) {
                HStack(spacing: 12.w_baseswiftui) {
                    // 主背景
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "56CCF2").opacity(0.15),
                                        Color(hex: "2F80ED").opacity(0.15)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52.w_baseswiftui, height: 52.h_baseswiftui)
                        
                        Image(systemName: "bubble.right.fill")
                            .font(.system(size: 22.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(Color(hex: "56CCF2"))
                    }
                    
                    // 文字和数量
                    VStack(alignment: .leading, spacing: 2.h_baseswiftui) {
                        Text("Comment")
                            .font(.system(size: 13.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text("\(post_baseswiftui.reviews_baseswiftui.count)")
                            .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                            .foregroundColor(.primary)
                            .monospacedDigit()
                    }
                }
                .padding(.horizontal, 20.w_baseswiftui)
                .padding(.vertical, 14.h_baseswiftui)
                .background(
                    RoundedRectangle(cornerRadius: 16.w_baseswiftui)
                        .fill(Color(hex: "56CCF2").opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16.w_baseswiftui)
                        .stroke(Color(hex: "56CCF2").opacity(0.25), lineWidth: 1.5.w_baseswiftui)
                )
            }
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.4)
        }
        .padding(20.w_baseswiftui)
        .background(
            RoundedRectangle(cornerRadius: 20.w_baseswiftui)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - 评论列表
    
    private var commentsSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 16.h_baseswiftui) {
            // 标题卡片（增强）
            HStack(spacing: 12.w_baseswiftui) {
                // 图标背景
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "667EEA").opacity(0.15),
                                    Color(hex: "764BA2").opacity(0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44.w_baseswiftui, height: 44.h_baseswiftui)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 20.sp_baseswiftui, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 2.h_baseswiftui) {
                    Text("Comments")
                        .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(post_baseswiftui.reviews_baseswiftui.count) comments")
                        .font(.system(size: 13.sp_baseswiftui, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(16.w_baseswiftui)
            .background(
                RoundedRectangle(cornerRadius: 18.w_baseswiftui)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.45)
            
            // 评论列表
            if post_baseswiftui.reviews_baseswiftui.isEmpty {
                emptyCommentsView_blisslink
            } else {
                VStack(spacing: 12.h_baseswiftui) {
                    ForEach(post_baseswiftui.reviews_baseswiftui.indices, id: \.self) { index_blisslink in
                        let comment_blisslink = post_baseswiftui.reviews_baseswiftui[index_blisslink]
                        CommentCard_blisslink(
                            comment_blisslink: comment_blisslink,
                            post_blisslink: post_baseswiftui
                        )
                        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.5 + Double(index_blisslink) * 0.08)
                    }
                }
            }
        }
    }
    
    // MARK: - 空评论视图
    
    private var emptyCommentsView_blisslink: some View {
        VStack(spacing: 20.h_baseswiftui) {
            // 图标组
            ZStack {
                // 外层圆
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "667EEA").opacity(0.12),
                                Color(hex: "764BA2").opacity(0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100.w_baseswiftui, height: 100.h_baseswiftui)
                
                // 中层圆
                Circle()
                    .fill(Color.white)
                    .frame(width: 85.w_baseswiftui, height: 85.h_baseswiftui)
                
                // 内层图标
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70.w_baseswiftui, height: 70.h_baseswiftui)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 32.sp_baseswiftui))
                        .foregroundColor(.white)
                }
            }
            .floatingAnimation_blisslink()
            
            // 文字内容
            VStack(spacing: 8.h_baseswiftui) {
                Text("No comments yet")
                    .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Be the first to share your thoughts")
                    .font(.system(size: 14.sp_baseswiftui))
                    .foregroundColor(.secondary)
                
                // 装饰图标
                HStack(spacing: 8.w_baseswiftui) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 14.sp_baseswiftui, weight: .semibold))
                    
                    Text("Start commenting below")
                        .font(.system(size: 13.sp_baseswiftui, weight: .medium))
                }
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.top, 8.h_baseswiftui)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60.h_baseswiftui)
        .padding(.horizontal, 24.w_baseswiftui)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24.w_baseswiftui)
                    .fill(Color.white)
                
                // 虚线边框
                RoundedRectangle(cornerRadius: 24.w_baseswiftui)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "667EEA").opacity(0.3),
                                Color(hex: "764BA2").opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 2.w_baseswiftui, dash: [8, 4])
                    )
            }
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - 评论输入框
    
    private var commentInputBar_blisslink: some View {
        VStack(spacing: 0) {
            // 顶部装饰线
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "667EEA").opacity(0.2),
                    Color(hex: "764BA2").opacity(0.2)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1.h_baseswiftui)
            
            HStack(spacing: 12.w_baseswiftui) {
                // 输入框
                TextField("Write a comment...", text: $commentText_blisslink)
                    .font(.system(size: 15.sp_baseswiftui, weight: .medium))
                    .padding(.horizontal, 20.w_baseswiftui)
                    .padding(.vertical, 14.h_baseswiftui)
                    .focused($isCommentFocused_blisslink)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 26.w_baseswiftui)
                                .fill(Color.white)
                            
                            RoundedRectangle(cornerRadius: 26.w_baseswiftui)
                                .stroke(
                                    !commentText_blisslink.isEmpty ?
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "667EEA").opacity(0.4),
                                            Color(hex: "764BA2").opacity(0.4)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.clear, Color.clear]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2.w_baseswiftui
                                )
                        }
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                    )
                
                // 发送按钮
                Button(action: {
                    handleSendComment_blisslink()
                }) {
                    ZStack {
                        // 外层光晕
                        if !commentText_blisslink.isEmpty {
                            Circle()
                                .fill(Color(hex: "667EEA").opacity(0.25))
                                .frame(width: 52.w_baseswiftui, height: 52.h_baseswiftui)
                                .blur(radius: 8)
                        }
                        
                        Circle()
                            .fill(
                                !commentText_blisslink.isEmpty ?
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.25)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 46.w_baseswiftui, height: 46.h_baseswiftui)
                        
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 19.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(45))
                            .offset(x: 1.w_baseswiftui, y: -1.h_baseswiftui)
                    }
                    .shadow(
                        color: !commentText_blisslink.isEmpty ? Color(hex: "667EEA").opacity(0.4) : Color.clear,
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .disabled(commentText_blisslink.isEmpty)
                .scaleEffect(!commentText_blisslink.isEmpty ? 1.0 : 0.93)
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: commentText_blisslink.isEmpty)
            }
            .padding(.horizontal, 20.w_baseswiftui)
            .padding(.top, 14.h_baseswiftui)
            .padding(.bottom, 0.h_baseswiftui)
        }
        .background(
            ZStack {
                Color.white.opacity(0.90)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
                
                // 顶部渐变光晕
                VStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "667EEA").opacity(0.08),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 30.h_baseswiftui)
                    
                    Spacer()
                }
            }
        )
        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: -5)
    }
    
    // MARK: - 计算属性
    
    /// 判断是否是自己的帖子
    private var isMyPost_blisslink: Bool {
        return userVM_baseswiftui.isCurrentUser_baseswiftui(userId_baseswiftui: post_baseswiftui.titleUserId_baseswiftui)
    }
    
    // MARK: - 辅助方法
    
    /// 获取帖子作者头像路径
    /// 核心作用：根据用户ID获取头像，优先检查是否为登录用户
    private func getUserAvatarPath_blisslink() -> String? {
        // 1. 先检查是否是登录用户的帖子
        if isMyPost_blisslink {
            return userVM_baseswiftui.getCurrentUser_baseswiftui().userHead_baseswiftui
        }
        
        // 2. 从预制用户列表中查找
        if let user_blisslink = localData_baseswiftui.userList_baseswiftui.first(where: { 
            $0.userId_baseswiftui == post_baseswiftui.titleUserId_baseswiftui 
        }) {
            return user_blisslink.userHead_baseswiftui
        }
        
        return nil
    }
    
    // MARK: - 事件处理
    
    /// 初始化数据
    private func initializeData_blisslink() {
        isLiked_blisslink = titleVM_baseswiftui.isLikedPost_baseswiftui(post_baseswiftui: post_baseswiftui)
    }
    
    /// 处理点赞
    private func handleLike_blisslink() {
        // 检查是否登录
        if !userVM_baseswiftui.isLoggedIn_baseswiftui {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
                Router_baseswiftui.shared_baseswiftui.toLogin_baseswiftui()
            }
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            isLiked_blisslink.toggle()
        }
        
        titleVM_baseswiftui.likePost_baseswiftui(post_baseswiftui: post_baseswiftui)
    }
    
    /// 发送评论
    private func handleSendComment_blisslink() {
        guard !commentText_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        let comment_blisslink = commentText_blisslink
        commentText_blisslink = ""
        isCommentFocused_blisslink = false
        
        // 发布评论
        titleVM_baseswiftui.releaseComment_baseswiftui(
            post_baseswiftui: post_baseswiftui,
            content_baseswiftui: comment_blisslink
        )
    }
    
    /// 执行删除帖子操作
    /// 核心作用：用户确认后执行实际的删除逻辑
    private func deletePost_blisslink() {
        Utils_baseswiftui.showLoading_baseswiftui(message_baseswiftui: "Deleting...")
        
        ReportHelper_blisslink.deletePost_blisslink(post_blisslink: post_baseswiftui) {
            Utils_baseswiftui.dismissLoading_baseswiftui()
            // 返回上一页
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router_baseswiftui.pop_baseswiftui()
            }
        }
    }
    
    /// 处理举报或删除
    /// 核心作用：从举报ActionSheet确认后的回调处理
    private func handleReportOrDelete_blisslink() {
        if isMyPost_blisslink {
            // 已经通过alert确认，直接删除
            deletePost_blisslink()
        } else {
            // 举报别人的帖子
            ReportHelper_blisslink.reportPost_blisslink(post_blisslink: post_baseswiftui) {
                // 返回上一页
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    router_baseswiftui.pop_baseswiftui()
                }
            }
        }
    }
    
    /// 处理帖子作者头像点击
    /// 核心作用：点击头像跳转到用户中心，区分登录用户和其他用户
    private func handlePostUserTap_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 如果是自己的帖子，返回到个人中心
        if isMyPost_blisslink {
            return
        }
        
        // 查找预制用户信息，跳转到串门页面
        if let user_blisslink = localData_baseswiftui.userList_baseswiftui.first(where: { 
            $0.userId_baseswiftui == post_baseswiftui.titleUserId_baseswiftui 
        }) {
            router_baseswiftui.pop_baseswiftui()
            // 跳转到用户中心页面
            router_baseswiftui.toUserInfo_baseswiftui(user_baseswiftui: user_blisslink)
        }
    }
}

// MARK: - 评论卡片组件

/// 评论卡片
struct CommentCard_blisslink: View {
    
    let comment_blisslink: Comment_baseswiftui
    let post_blisslink: TitleModel_baseswiftui
    
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    @ObservedObject var localData_baseswiftui = LocalData_baseswiftui.shared_baseswiftui
    @State private var showReportSheet_blisslink: Bool = false
    @State private var showDeleteAlert_blisslink: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 14.w_baseswiftui) {
            // 评论者头像（添加光晕，可点击）
            ZStack {
                // 外层光晕
                Circle()
                    .fill(Color(hex: "667EEA").opacity(0.2))
                    .frame(width: 48.w_baseswiftui, height: 48.h_baseswiftui)
                    .blur(radius: 6)
                
                UserAvatarView_baseswiftui(
                    userId_baseswiftui: comment_blisslink.commentUserId_baseswiftui,
                    avatarPath_baseswiftui: getCommentUserAvatarPath_blisslink(),
                    userName_baseswiftui: comment_blisslink.commentUserName_baseswiftui,
                    size_baseswiftui: 44.w_baseswiftui,
                    isClickable_baseswiftui: false,
                    onTapped_baseswiftui: {}
                )
            }
            
            // 评论内容区域
            VStack(alignment: .leading, spacing: 10.h_baseswiftui) {
                // 用户名、徽章和举报按钮
                HStack(spacing: 6.w_baseswiftui) {
                    Text(comment_blisslink.commentUserName_baseswiftui)
                        .font(.system(size: 15.sp_baseswiftui, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // 验证标识（增强）
                    ZStack {
                        Circle()
                            .fill(Color(hex: "56CCF2").opacity(0.12))
                            .frame(width: 18.w_baseswiftui, height: 18.h_baseswiftui)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10.sp_baseswiftui, weight: .bold))
                            .foregroundColor(Color(hex: "56CCF2"))
                    }
                    
                    Spacer()
                    
                    // 删除/举报按钮
                    Button(action: {
                        handleCommentAction_blisslink()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 26.w_baseswiftui, height: 26.h_baseswiftui)
                            
                            Image(systemName: isMyComment_blisslink ? "trash.fill" : "ellipsis")
                                .font(.system(size: 12.sp_baseswiftui, weight: .bold))
                                .foregroundColor(isMyComment_blisslink ? .red : .secondary)
                                .rotationEffect(.degrees(isMyComment_blisslink ? 0 : 90))
                        }
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                }
                
                // 评论内容气泡（带装饰条）
                HStack(spacing: 0) {
                    // 左侧装饰条
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: 3.w_baseswiftui)
                    .cornerRadius(1.5.w_baseswiftui)
                    
                    // 评论内容
                    Text(comment_blisslink.commentContent_baseswiftui)
                        .font(.system(size: 15.sp_baseswiftui))
                        .foregroundColor(.primary)
                        .lineSpacing(5.h_baseswiftui)
                        .padding(.leading, 12.w_baseswiftui)
                        .padding(.trailing, 14.w_baseswiftui)
                        .padding(.vertical, 14.h_baseswiftui)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16.w_baseswiftui)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "F7FAFC"),
                                    Color(hex: "EDF2F7")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            
            Spacer()
        }
        .padding(18.w_baseswiftui)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18.w_baseswiftui)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                
                // 举报ActionSheet（仅用于举报别人的评论）
                if !isMyComment_blisslink {
                    ReportActionSheet_blisslink(
                        isShowing_blisslink: $showReportSheet_blisslink,
                        isBlockUser_blisslink: false,
                        onConfirm_blisslink: {
                            handleReportComment_blisslink()
                        }
                    )
                }
            }
        )
        .alert("Delete Comment", isPresented: $showDeleteAlert_blisslink) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                handleDeleteComment_blisslink()
            }
        } message: {
            Text("Are you sure you want to delete this comment? This action cannot be undone.")
        }
    }
    
    // MARK: - 计算属性
    
    /// 判断是否是自己的评论
    private var isMyComment_blisslink: Bool {
        return userVM_baseswiftui.isCurrentUser_baseswiftui(userId_baseswiftui: comment_blisslink.commentUserId_baseswiftui)
    }
    
    // MARK: - 辅助方法
    
    /// 获取评论者头像路径
    private func getCommentUserAvatarPath_blisslink() -> String? {
        // 从本地数据中查找评论者信息
        if let user_blisslink = localData_baseswiftui.userList_baseswiftui.first(where: { 
            $0.userId_baseswiftui == comment_blisslink.commentUserId_baseswiftui 
        }) {
            return user_blisslink.userHead_baseswiftui
        }
        return nil
    }
    
    // MARK: - 事件处理
    
    /// 处理评论操作（删除或举报）
    private func handleCommentAction_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        if isMyComment_blisslink {
            // 自己的评论：显示删除确认
            showDeleteAlert_blisslink = true
        } else {
            // 别人的评论：显示举报选项
            showReportSheet_blisslink = true
        }
    }
    
    /// 删除自己的评论
    private func handleDeleteComment_blisslink() {
        Utils_baseswiftui.showLoading_baseswiftui(message_baseswiftui: "Deleting...")
        
        ReportHelper_blisslink.deleteComment_blisslink(
            comment_blisslink: comment_blisslink,
            post_blisslink: post_blisslink
        ) {
            Utils_baseswiftui.dismissLoading_baseswiftui()
        }
    }
    
    /// 举报别人的评论
    private func handleReportComment_blisslink() {
        Utils_baseswiftui.showLoading_baseswiftui(message_baseswiftui: "Reporting...")
        
        ReportHelper_blisslink.reportComment_blisslink(
            comment_blisslink: comment_blisslink,
            post_blisslink: post_blisslink
        ) {
            Utils_baseswiftui.dismissLoading_baseswiftui()
        }
    }
}
