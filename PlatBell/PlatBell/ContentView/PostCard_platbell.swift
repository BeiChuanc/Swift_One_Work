import SwiftUI

// MARK: - 帖子卡片组件
// 核心作用：展示帖子的完整信息，包括用户、媒体、内容、互动数据
// 设计思路：毛玻璃卡片 + 渐变色底纹 + 快速操作按钮
// 关键功能：双击点赞、点击查看详情、用户头像跳转

/// 帖子卡片组件
struct PostCard_platbell: View {
    
    /// 帖子数据
    let post_platbell: TitleModel_platbell
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 是否可见（用于动画）
    let isVisible_platbell: Bool
    
    /// 动画延迟
    let animationDelay_platbell: Double
    
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 双击点赞状态
    @State private var isDoubleTapLike_platbell = false
    
    /// 爆炸效果状态
    @State private var showExplosion_platbell = false
    
    /// 是否显示举报菜单
    @State private var showReportSheet_platbell = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 用户信息栏
            userInfoBar_platbell
                .padding(.horizontal, 16)
                .padding(.top, 12)
            
            // 帖子媒体
            postMediaView_platbell
                .padding(.top, 12)
            
            // 帖子内容
            postContentView_platbell
                .padding(.horizontal, 16)
                .padding(.top, 12)
            
            // 快速操作栏
            QuickActionBar_platbell(
                post_platbell: post_platbell,
                gradientIndex_platbell: gradientIndex_platbell
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .dreamyCard_platbell(
            gradientIndex_platbell: gradientIndex_platbell,
            cornerRadius_platbell: 20,
            hasShadow_platbell: true,
            blurOpacity_platbell: 0.7
        )
        .padding(.horizontal, 16)
        .cardAppear_platbell(
            isVisible_platbell: isVisible_platbell,
            delay_platbell: animationDelay_platbell
        )
        .onTapGesture(count: 2) {
            handleDoubleTap_platbell()
        }
        .onTapGesture {
            router_platbell.toPostDetail_platbellui(post_platbell: post_platbell)
        }
        .explosion_platbell(isExploding_platbell: $showExplosion_platbell)
        .background(
            ReportActionSheet_platbell(
                isShowing_platbell: $showReportSheet_platbell,
                isBlockUser_platbell: false,
                onConfirm_platbell: {
                    ReportHelper_platbell.reportPost_platbell(post_platbell: post_platbell)
                }
            )
        )
    }
    
    // MARK: - 用户信息栏
    
    /// 用户信息栏
    private var userInfoBar_platbell: some View {
        HStack(spacing: 12) {
            // 用户头像
            UserAvatarView_platbell(
                userId_platbell: post_platbell.titleUserId_platbell,
                size_platbell: 40,
                isClickable_platbell: true,
                onTapped_platbell: {
                    let user_platbell = userVM_platbell.getUserById_platbell(userId_platbell: post_platbell.titleUserId_platbell)
                    router_platbell.toUserInfo_platbell(user_platbell: user_platbell)
                }
            )
            .glowBorder_platbell(
                gradientIndex_platbell: gradientIndex_platbell,
                cornerRadius_platbell: 20,
                lineWidth_platbell: 2,
                glowIntensity_platbell: 0.2
            )
            
            // 用户名称
            Text(post_platbell.titleUserName_platbell)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // 举报按钮
            Button(action: {
                handleReport_platbell()
            }) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.orange)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                    )
            }
        }
    }
    
    // MARK: - 帖子媒体
    
    /// 帖子媒体视图
    private var postMediaView_platbell: some View {
        let mediaName_platbell = post_platbell.titleMeidas_platbell.first ?? ""
        
        return MediaDisplayView_platbell(
            mediaPath_platbell: mediaName_platbell,
            isVideo_platbell: mediaName_platbell.contains(".mp4"),
            cornerRadius_platbell: 15,
            isClickable_platbell: false
        )
        .frame(height: 200)
        .padding(.horizontal, 16)
        .clipped()
    }
    
    // MARK: - 帖子内容
    
    /// 帖子内容视图
    private var postContentView_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text(post_platbell.title_platbell)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.primary)
            
            // 内容
            Text(post_platbell.titleContent_platbell)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // 标签云（仅话题帖子显示）
            if !post_platbell.tags_platbell.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
                        
                        Text("Topics")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    
                    TagCloud_platbell(
                        tags_platbell: post_platbell.tags_platbell,
                        gradientIndex_platbell: gradientIndex_platbell,
                        isClickable_platbell: true,
                        onTagTapped_platbell: { tag_platbell in
                            Utils_platbell.showInfo_platbell(
                                message_platbell: "Tag: \(tag_platbell)",
                                delay_platbell: 1.0
                            )
                        },
                        showDecoration_platbell: false
                    )
                    .frame(height: calculateTagCloudHeight_platbell())
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                                .opacity(0.05)
                        )
                )
            }
        }
    }
    
    /// 计算标签云高度
    private func calculateTagCloudHeight_platbell() -> CGFloat {
        let tagCount_platbell = post_platbell.tags_platbell.count
        if tagCount_platbell <= 3 {
            return 35
        } else if tagCount_platbell <= 6 {
            return 70
        } else {
            return 105
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理双击事件
    private func handleDoubleTap_platbell() {
        // 如果未点赞，则点赞
        if !titleVM_platbell.isLikedPost_platbell(post_platbell: post_platbell) {
            titleVM_platbell.likePost_platbell(post_platbell: post_platbell)
        }
        
        // 触发爆炸动画
        showExplosion_platbell = true
        
        // 触发震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback_platbell.impactOccurred()
    }
    
    /// 处理举报
    private func handleReport_platbell() {
        // 震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback_platbell.impactOccurred()
        
        // 显示举报菜单
        showReportSheet_platbell = true
    }
}

// MARK: - 预览

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            let posts_platbell = Array(LocalData_platbell.shared_platbell.titleList_platbell.prefix(3))
            
            ForEach(posts_platbell.indices, id: \.self) { index_platbell in
                PostCard_platbell(
                    post_platbell: posts_platbell[index_platbell],
                    gradientIndex_platbell: index_platbell,
                    isVisible_platbell: true,
                    animationDelay_platbell: Double(index_platbell) * 0.1
                )
            }
        }
        .padding(.vertical, 16)
    }
    .background(Color(.systemBackground))
    .onAppear {
        LocalData_platbell.shared_platbell.initData_platbell()
        TitleViewModel_platbell.shared_platbell.initPosts_platbell()
        UserViewModel_platbell.shared_platbell.initUser_platbell()
    }
}
