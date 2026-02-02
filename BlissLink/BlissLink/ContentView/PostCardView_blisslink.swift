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
    
    /// ViewModels
    @ObservedObject var titleVM_baseswiftui = TitleViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var practiceVM_blisslink = PracticeViewModel_blisslink.shared_blisslink
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.h_baseswiftui) {
            // 用户信息
            userHeader_blisslink
            
            // 帖子内容
            postContent_blisslink
            
            // 媒体展示（如果有）
            if !post_blisslink.titleMeidas_baseswiftui.isEmpty {
                mediaView_blisslink
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
        .onAppear {
            isLiked_blisslink = titleVM_baseswiftui.isLikedPost_baseswiftui(post_baseswiftui: post_blisslink)
        }
    }
    
    // MARK: - 用户头部
    
    private var userHeader_blisslink: some View {
        HStack(spacing: 10.w_baseswiftui) {
            // 用户头像
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 40.sp_baseswiftui))
                .foregroundColor(Color(hex: "667EEA"))
            
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
            
            // 更多按钮
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(90))
            }
        }
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
        // 使用系统图标模拟图片
        RoundedRectangle(cornerRadius: 12.w_baseswiftui)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "667EEA").opacity(0.3), Color(hex: "764BA2").opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 200.h_baseswiftui)
            .overlay(
                Image(systemName: "photo.fill")
                    .font(.system(size: 50.sp_baseswiftui))
                    .foregroundColor(.white.opacity(0.6))
            )
    }
    
    // MARK: - 练习标签
    
    private var practiceTag_blisslink: some View {
        HStack(spacing: 8.w_baseswiftui) {
            Image(systemName: "figure.yoga")
                .font(.system(size: 14.sp_baseswiftui))
            
            if let duration_blisslink = post_blisslink.practiceDuration_blisslink {
                Text("Practiced \(duration_blisslink) min")
                    .font(.system(size: 13.sp_baseswiftui, weight: .medium))
            } else {
                Text("Practice Achievement")
                    .font(.system(size: 13.sp_baseswiftui, weight: .medium))
            }
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
            
            // 分享按钮
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 4.h_baseswiftui)
    }
    
    // MARK: - 事件处理
    
    /// 处理点赞
    private func handleLike_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 切换点赞状态
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            isLiked_blisslink.toggle()
        }
        
        // 执行点赞逻辑
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
}
