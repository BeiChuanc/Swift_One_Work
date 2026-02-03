import SwiftUI

// MARK: - 发现页
// 核心作用：展示官方教学视频和社区动态
// 设计思路：简洁布局、教学视频推荐、帖子流展示
// 关键功能：官方视频、社区帖子展示、发布入口

/// 发现页
struct Discover_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var localData_baseswiftui = LocalData_baseswiftui.shared_baseswiftui
    @ObservedObject var titleVM_baseswiftui = TitleViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    // 官方教学视频数据
    private let officialVideos_blisslink: [(String, String)] = [
        ("Morning Yoga", "media_one"),
        ("Meditation", "media_two"),
        ("Breathing", "media_three")
    ]
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层
            ZStack {
                // 主背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "EDF5FF"),
                        Color(hex: "F7FAFC"),
                        Color(hex: "E6F2FF")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 顶部装饰渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "667EEA").opacity(0.08),
                        Color(hex: "2BD2FF").opacity(0.06),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 350.h_baseswiftui)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // 装饰圆圈
                Circle()
                    .fill(Color(hex: "667EEA").opacity(0.05))
                    .frame(width: 320.w_baseswiftui, height: 320.h_baseswiftui)
                    .offset(x: -160.w_baseswiftui, y: -220.h_baseswiftui)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color(hex: "2BD2FF").opacity(0.04))
                    .frame(width: 280.w_baseswiftui, height: 280.h_baseswiftui)
                    .offset(x: 140.w_baseswiftui, y: 150.h_baseswiftui)
                    .blur(radius: 45)
                
                Circle()
                    .fill(Color(hex: "FA8BFF").opacity(0.04))
                    .frame(width: 300.w_baseswiftui, height: 300.h_baseswiftui)
                    .offset(x: -100.w_baseswiftui, y: 500.h_baseswiftui)
                    .blur(radius: 55)
            }
            .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar_blisslink
                
                // 内容区域
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24.h_baseswiftui) {
                        // 官方教学视频区域
                        officialVideosSection_blisslink
                        
                        // 社区帖子列表
                        communityPostsSection_blisslink
                    }
                    .padding(.top, 20.h_baseswiftui)
                    .padding(.bottom, 100.h_baseswiftui)
                }
            }
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar_blisslink: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4.h_baseswiftui) {
                Text("Discover")
                    .font(.system(size: 28.sp_baseswiftui, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Explore yoga community")
                    .font(.system(size: 14.sp_baseswiftui, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20.w_baseswiftui)
        .padding(.top, 16.h_baseswiftui)
        .padding(.bottom, 12.h_baseswiftui)
    }
    
    // MARK: - 官方教学视频区域
    
    private var officialVideosSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_baseswiftui) {
            // 标题
            HStack {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 16.sp_baseswiftui))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Official Tutorials")
                    .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20.w_baseswiftui)
            
            // 视频列表（横向滚动）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16.w_baseswiftui) {
                    ForEach(officialVideos_blisslink.indices, id: \.self) { index_blisslink in
                        let video_blisslink = officialVideos_blisslink[index_blisslink]
                        officialVideoCard_blisslink(
                            title_blisslink: video_blisslink.0,
                            coverImage_blisslink: video_blisslink.1
                        )
                        .bounceIn_blisslink(delay_blisslink: Double(index_blisslink) * 0.08)
                    }
                }
                .padding(.horizontal, 20.w_baseswiftui)
            }
        }
    }
    
    /// 官方视频卡片
    /// 核心作用：展示官方教学视频封面，点击进入全屏播放
    private func officialVideoCard_blisslink(title_blisslink: String, coverImage_blisslink: String) -> some View {
        Button(action: {
            // 触觉反馈
            let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
            generator_blisslink.impactOccurred()
            
            // 跳转到媒体播放器
            router_baseswiftui.toMediaPlayer_baseswiftui(
                mediaUrl_baseswiftui: coverImage_blisslink,
                isVideo_baseswiftui: true
            )
        }) {
            VStack(spacing: 8.h_baseswiftui) {
                // 视频封面
                ZStack {
                    MediaDisplayView_baseswiftui(
                        mediaPath_baseswiftui: coverImage_blisslink,
                        isVideo_baseswiftui: true,
                        cornerRadius_baseswiftui: 20.w_baseswiftui
                    )
                    .frame(width: 100.w_baseswiftui, height: 100.h_baseswiftui)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20.w_baseswiftui))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                // 标题
                Text(title_blisslink)
                    .font(.system(size: 12.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(width: 100.w_baseswiftui)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 社区帖子列表
    
    private var communityPostsSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_baseswiftui) {
            // 标题
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16.sp_baseswiftui))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Community Posts")
                    .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20.w_baseswiftui)
            
            // 帖子列表
            LazyVStack(spacing: 16.h_baseswiftui) {
                ForEach(titleVM_baseswiftui.getPosts_baseswiftui()) { post_blisslink in
                    PostCardView_blisslink(
                        post_blisslink: post_blisslink,
                        onTap_blisslink: {
                            handlePostTap_blisslink(post_blisslink)
                        },
                        onLike_blisslink: {},
                        onComment_blisslink: {
                            handleComment_blisslink(post_blisslink)
                        }
                    )
                }
            }
            .padding(.horizontal, 20.w_baseswiftui)
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理帖子点击
    private func handlePostTap_blisslink(_ post_blisslink: TitleModel_baseswiftui) {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 跳转到帖子详情
        router_baseswiftui.toPostDetail_baseswiftui(post_baseswiftui: post_blisslink)
    }
    
    /// 处理评论
    private func handleComment_blisslink(_ post_blisslink: TitleModel_baseswiftui) {
        // 跳转到帖子详情的评论区
        router_baseswiftui.toPostDetail_baseswiftui(post_baseswiftui: post_blisslink)
    }
    
    /// 处理创建帖子
    private func handleCreatePost_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        // 跳转到发布页面
        router_baseswiftui.toRelease_baseswiftui()
    }
}
