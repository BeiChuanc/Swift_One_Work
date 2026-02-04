import SwiftUI

// MARK: - 发现页
// 核心作用：展示官方教学视频和社区动态
// 设计思路：简洁布局、教学视频推荐、帖子流展示
// 关键功能：官方视频、社区帖子展示、发布入口

/// 发现页
struct Discover_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var localData_blisslink = LocalData_blisslink.shared_blisslink
    @ObservedObject var titleVM_blisslink = TitleViewModel_blisslink.shared_blisslink
    @ObservedObject var router_blisslink = Router_blisslink.shared_blisslink
    
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
                .frame(height: 350.h_blisslink)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // 装饰圆圈
                Circle()
                    .fill(Color(hex: "667EEA").opacity(0.05))
                    .frame(width: 320.w_blisslink, height: 320.h_blisslink)
                    .offset(x: -160.w_blisslink, y: -220.h_blisslink)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color(hex: "2BD2FF").opacity(0.04))
                    .frame(width: 280.w_blisslink, height: 280.h_blisslink)
                    .offset(x: 140.w_blisslink, y: 150.h_blisslink)
                    .blur(radius: 45)
                
                Circle()
                    .fill(Color(hex: "FA8BFF").opacity(0.04))
                    .frame(width: 300.w_blisslink, height: 300.h_blisslink)
                    .offset(x: -100.w_blisslink, y: 500.h_blisslink)
                    .blur(radius: 55)
            }
            .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar_blisslink
                
                // 内容区域
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24.h_blisslink) {
                        // 官方教学视频区域
                        officialVideosSection_blisslink
                        
                        // 社区帖子列表
                        communityPostsSection_blisslink
                    }
                    .padding(.top, 20.h_blisslink)
                    .padding(.bottom, 100.h_blisslink)
                }
            }
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar_blisslink: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4.h_blisslink) {
                Text("Discover")
                    .font(.system(size: 28.sp_blisslink, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Explore yoga community")
                    .font(.system(size: 14.sp_blisslink, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20.w_blisslink)
        .padding(.top, 16.h_blisslink)
        .padding(.bottom, 12.h_blisslink)
    }
    
    // MARK: - 官方教学视频区域
    
    private var officialVideosSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_blisslink) {
            // 标题
            HStack {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 16.sp_blisslink))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Official Tutorials")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20.w_blisslink)
            
            // 视频列表（横向滚动）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16.w_blisslink) {
                    ForEach(officialVideos_blisslink.indices, id: \.self) { index_blisslink in
                        let video_blisslink = officialVideos_blisslink[index_blisslink]
                        officialVideoCard_blisslink(
                            title_blisslink: video_blisslink.0,
                            coverImage_blisslink: video_blisslink.1
                        )
                        .bounceIn_blisslink(delay_blisslink: Double(index_blisslink) * 0.08)
                    }
                }
                .padding(.horizontal, 20.w_blisslink)
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
            router_blisslink.toMediaPlayer_blisslink(
                mediaUrl_blisslink: coverImage_blisslink,
                isVideo_blisslink: true
            )
        }) {
            VStack(spacing: 8.h_blisslink) {
                // 视频封面
                ZStack {
                    MediaDisplayView_blisslink(
                        mediaPath_blisslink: coverImage_blisslink,
                        isVideo_blisslink: true,
                        cornerRadius_blisslink: 20.w_blisslink
                    )
                    .frame(width: 100.w_blisslink, height: 100.h_blisslink)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20.w_blisslink))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                // 标题
                Text(title_blisslink)
                    .font(.system(size: 12.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(width: 100.w_blisslink)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 社区帖子列表
    
    private var communityPostsSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_blisslink) {
            // 标题
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16.sp_blisslink))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Community Posts")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20.w_blisslink)
            
            // 帖子列表
            LazyVStack(spacing: 16.h_blisslink) {
                ForEach(titleVM_blisslink.getPosts_blisslink()) { post_blisslink in
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
            .padding(.horizontal, 20.w_blisslink)
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理帖子点击
    private func handlePostTap_blisslink(_ post_blisslink: TitleModel_blisslink) {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 跳转到帖子详情
        router_blisslink.toPostDetail_blisslink(post_blisslink: post_blisslink)
    }
    
    /// 处理评论
    private func handleComment_blisslink(_ post_blisslink: TitleModel_blisslink) {
        // 跳转到帖子详情的评论区
        router_blisslink.toPostDetail_blisslink(post_blisslink: post_blisslink)
    }
    
    /// 处理创建帖子
    private func handleCreatePost_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        // 跳转到发布页面
        router_blisslink.toRelease_blisslink()
    }
}
