import SwiftUI

// MARK: - 热门内容卡片组件
// 核心作用：展示热门帖子，突出显示热度和互动数据
// 设计思路：大媒体预览 + 热度标识 + 互动数据 + 吸引眼球的设计
// 关键功能：查看详情、快速操作

/// 热门内容卡片
struct HotPostCard_platbell: View {
    
    /// 帖子数据
    let post_platbell: TitleModel_platbell
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 是否可见（用于动画）
    let isVisible_platbell: Bool
    
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 热度标识横幅
            hotBadge_platbell
                .padding(.horizontal, 16)
                .padding(.top, 12)
            
            // 大媒体预览
            postMediaView_platbell
                .padding(.top, 12)
            
            // 内容信息
            VStack(alignment: .leading, spacing: 12) {
                // 用户信息
                userInfoBar_platbell
                
                // 标题和内容
                VStack(alignment: .leading, spacing: 8) {
                    Text(post_platbell.title_platbell)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(post_platbell.titleContent_platbell)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
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
                
                // 互动数据
                engagementStats_platbell
            }
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
        .cardAppear_platbell(isVisible_platbell: isVisible_platbell, delay_platbell: 0.1)
        .onTapGesture {
            router_platbell.toPostDetail_platbellui(post_platbell: post_platbell)
        }
    }
    
    // MARK: - 子视图
    
    /// 热度标识
    private var hotBadge_platbell: some View {
        HStack(spacing: 8) {
            // 火焰图标
            Image(systemName: "flame.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(
                    ThemeColors_platbell.gradient_platbell(at: 4) // 使用暖色系
                )
            
            Text("Hot Post")
                .font(.system(size: 14, weight: .bold))
                .gradientText_platbell(gradientIndex_platbell: 4)
            
            Spacer()
            
            // 热度值
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(ThemeColors_platbell.warmStart_platbell)
                
                Text("\(post_platbell.likes_platbell)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeColors_platbell.warmStart_platbell)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    ThemeColors_platbell.gradient_platbell(at: 4)
                        .opacity(0.1)
                )
        )
    }
    
    /// 帖子媒体视图
    private var postMediaView_platbell: some View {
        let mediaName_platbell = post_platbell.titleMeidas_platbell.first ?? ""
        
        return ZStack {
            // 媒体内容
            MediaDisplayView_platbell(
                mediaPath_platbell: mediaName_platbell,
                isVideo_platbell: mediaName_platbell.contains(".mp4"),
                cornerRadius_platbell: 15,
                isClickable_platbell: false
            )
            
            // 左上角热度徽章
            VStack {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                        
                        Text("Hot")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(
                                ThemeColors_platbell.gradient_platbell(at: 4)
                            )
                    )
                    .padding(12)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .frame(height: 280)
        .padding(.horizontal, 16)
        .clipped()
    }
    
    /// 用户信息栏
    private var userInfoBar_platbell: some View {
        HStack(spacing: 10) {
            // 用户头像
            UserAvatarView_platbell(
                userId_platbell: post_platbell.titleUserId_platbell,
                size_platbell: 32,
                isClickable_platbell: true,
                onTapped_platbell: {
                    let user_platbell = userVM_platbell.getUserById_platbell(userId_platbell: post_platbell.titleUserId_platbell)
                    router_platbell.toUserInfo_platbell(user_platbell: user_platbell)
                }
            )
            .glowBorder_platbell(
                gradientIndex_platbell: gradientIndex_platbell,
                cornerRadius_platbell: 16,
                lineWidth_platbell: 1.5,
                glowIntensity_platbell: 0.2
            )
            
            // 用户名
            Text(post_platbell.titleUserName_platbell)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    /// 互动数据统计
    private var engagementStats_platbell: some View {
        HStack(spacing: 20) {
            // 点赞数
            StatBadge_platbell(
                icon_platbell: "heart.fill",
                count_platbell: post_platbell.likes_platbell,
                gradientIndex_platbell: 1
            )
            
            // 评论数
            StatBadge_platbell(
                icon_platbell: "bubble.left.fill",
                count_platbell: post_platbell.reviews_platbell.count,
                gradientIndex_platbell: 2
            )
            
            Spacer()
            
            // 查看详情按钮
                Text("View Details")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count])
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
}

// MARK: - 统计徽章组件

/// 统计徽章组件
struct StatBadge_platbell: View {
    
    let icon_platbell: String
    let count_platbell: Int
    let gradientIndex_platbell: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon_platbell)
                .font(.system(size: 14))
                .foregroundColor(ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count])
            
            Text("\(count_platbell)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 预览

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            let posts_platbell = Array(LocalData_platbell.shared_platbell.titleList_platbell.prefix(3))
            
            ForEach(posts_platbell.indices, id: \.self) { index_platbell in
                HotPostCard_platbell(
                    post_platbell: posts_platbell[index_platbell],
                    gradientIndex_platbell: index_platbell,
                    isVisible_platbell: true
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
