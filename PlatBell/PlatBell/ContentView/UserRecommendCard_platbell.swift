import SwiftUI

// MARK: - 用户推荐卡片组件
// 核心作用：展示推荐用户的详细信息和快速关注功能
// 设计思路：大头像 + 渐变背景 + 用户信息 + 关注按钮 + 精选内容预览
// 关键功能：关注用户、查看用户详情、预览用户内容

/// 用户推荐卡片
struct UserRecommendCard_platbell: View {
    
    /// 用户数据
    let user_platbell: PrewUserModel_platbell
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 是否可见（用于动画）
    let isVisible_platbell: Bool
    
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 用户的帖子列表
    private var userPosts_platbell: [TitleModel_platbell] {
        titleVM_platbell.posts_platbell.filter { $0.titleUserId_platbell == user_platbell.userId_platbell ?? 0 }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 渐变背景头部区域
            ZStack(alignment: .bottom) {
                // 渐变背景
                ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                    .frame(height: 120)
                
                // 用户头像（突出显示）
                userAvatarView_platbell
                    .offset(y: 40)
            }
            
            // 用户信息区域
            VStack(spacing: 12) {
                Spacer()
                    .frame(height: 50) // 为突出的头像留空间
                
                // 用户名
                Text(user_platbell.userName_platbell ?? "User")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                // 用户简介
                Text(user_platbell.userIntroduce_platbell ?? "No introduction yet")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 20)
                
                // 统计信息
                HStack(spacing: 24) {
                    StatItem_platbell(
                        label_platbell: "Following",
                        value_platbell: user_platbell.userFollow_platbell ?? 0
                    )
                    
                    StatItem_platbell(
                        label_platbell: "Followers",
                        value_platbell: user_platbell.userFans_platbell ?? 0
                    )
                }
                .padding(.top, 8)
                
                // 关注按钮
                FollowButton_platbell(
                    user_platbell: user_platbell,
                    gradientIndex_platbell: gradientIndex_platbell
                )
                .padding(.top, 12)
                
                // 用户精选内容预览（3宫格）
                if !userPosts_platbell.isEmpty {
                    userContentPreview_platbell
                        .padding(.top, 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .dreamyCard_platbell(
            gradientIndex_platbell: gradientIndex_platbell,
            cornerRadius_platbell: 20,
            hasShadow_platbell: true,
            blurOpacity_platbell: 0.5
        )
        .padding(.horizontal, 16)
        .cardAppear_platbell(isVisible_platbell: isVisible_platbell, delay_platbell: 0.2)
        .onTapGesture {
            router_platbell.toUserInfo_platbell(user_platbell: user_platbell)
        }
    }
    
    // MARK: - 子视图
    
    /// 用户头像视图
    @ViewBuilder
    private var userAvatarView_platbell: some View {
        ZStack {
            // 白色底圈
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 88, height: 88)
            
            // 用户头像
            UserAvatarView_platbell(
                userId_platbell: user_platbell.userId_platbell ?? 0,
                size_platbell: 80,
                isClickable_platbell: false
            )
            
            // 渐变边框
            Circle()
                .stroke(
                    ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell),
                    lineWidth: 3
                )
                .frame(width: 88, height: 88)
        }
        .shadow(
            color: ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                .opacity(0.3),
            radius: 10,
            x: 0,
            y: 5
        )
    }
    
    /// 用户内容预览（3宫格）
    private var userContentPreview_platbell: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Posts")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                ForEach(userPosts_platbell.prefix(3), id: \.id) { post_platbell in
                    previewMediaThumbnail_platbell(post_platbell: post_platbell)
                }
            }
        }
    }
    
    /// 预览媒体缩略图
    @ViewBuilder
    private func previewMediaThumbnail_platbell(post_platbell: TitleModel_platbell) -> some View {
        let mediaName_platbell = post_platbell.titleMeidas_platbell.first ?? ""
        
        MediaDisplayView_platbell(
            mediaPath_platbell: mediaName_platbell,
            isVideo_platbell: mediaName_platbell.contains(".mp4"),
            cornerRadius_platbell: 8,
            isClickable_platbell: true,
            onTapped_platbell: {
                router_platbell.toPostDetail_platbellui(post_platbell: post_platbell)
            }
        )
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            router_platbell.toPostDetail_platbellui(post_platbell: post_platbell)
        }
    }
}

// MARK: - 统计项组件

/// 统计项组件
struct StatItem_platbell: View {
    
    let label_platbell: String
    let value_platbell: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value_platbell)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label_platbell)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}
