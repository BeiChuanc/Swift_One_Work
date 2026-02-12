import SwiftUI

// MARK: - 快速操作栏组件
// 核心作用：提供帖子的快速操作按钮（点赞、评论、分享等）
// 设计思路：图标按钮 + 数字统计 + 动画反馈
// 关键功能：点赞动画、评论跳转、分享菜单

/// 快速操作栏组件
struct QuickActionBar_platbell: View {
    
    /// 帖子数据
    let post_platbell: TitleModel_platbell
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 点赞动画状态
    @State private var isLikeAnimating_platbell = false
    
    var body: some View {
        HStack(spacing: 24) {
            // 点赞按钮
            AnimatedLikeButton_platbell(
                post_platbell: post_platbell,
                gradientIndex_platbell: gradientIndex_platbell,
                isAnimating_platbell: $isLikeAnimating_platbell
            )
            
            // 评论按钮
            ActionButton_platbell(
                icon_platbell: "bubble.left",
                count_platbell: post_platbell.reviews_platbell.count,
                gradientIndex_platbell: gradientIndex_platbell,
                action_platbell: {
                    router_platbell.toPostDetail_platbellui(post_platbell: post_platbell)
                }
            )
            
            Spacer()
        }
    }
}

// MARK: - 动画点赞按钮

/// 动画点赞按钮
struct AnimatedLikeButton_platbell: View {
    
    /// 帖子数据
    let post_platbell: TitleModel_platbell
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 动画状态
    @Binding var isAnimating_platbell: Bool
    
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    
    /// 是否已点赞
    private var isLiked_platbell: Bool {
        titleVM_platbell.isLikedPost_platbell(post_platbell: post_platbell)
    }
    
    var body: some View {
        Button(action: {
            handleLike_platbell()
        }) {
            HStack(spacing: 6) {
                Image(systemName: isLiked_platbell ? "heart.fill" : "heart")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        isLiked_platbell
                            ? ThemeColors_platbell.gradient_platbell(at: 1) // 使用粉色渐变
                            : LinearGradient(
                                colors: [Color.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .heartBeat_platbell(isAnimating_platbell: $isAnimating_platbell)
                
                Text("\(post_platbell.likes_platbell)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isLiked_platbell ? ThemeColors_platbell.secondaryStart_platbell : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /// 处理点赞
    private func handleLike_platbell() {
        titleVM_platbell.likePost_platbell(post_platbell: post_platbell)
        
        // 触发动画
        isAnimating_platbell = true
        
        // 震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
    }
}

// MARK: - 通用操作按钮

/// 通用操作按钮
struct ActionButton_platbell: View {
    
    /// 图标名称
    let icon_platbell: String
    
    /// 数量（可选）
    let count_platbell: Int?
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 点击事件
    let action_platbell: () -> Void
    
    /// 按压状态
    @State private var isPressed_platbell = false
    
    var body: some View {
        Button(action: {
            handleTap_platbell()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon_platbell)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.secondary)
                
                if let count_platbell = count_platbell, count_platbell > 0 {
                    Text("\(count_platbell)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed_platbell ? 0.9 : 1.0)
    }
    
    /// 处理点击
    private func handleTap_platbell() {
        // 按压动画
        withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
            isPressed_platbell = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
                isPressed_platbell = false
            }
        }
        
        // 震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
        
        // 执行动作
        action_platbell()
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 20) {
        let posts_platbell = Array(LocalData_platbell.shared_platbell.titleList_platbell.prefix(3))
        
        ForEach(posts_platbell.indices, id: \.self) { index_platbell in
            QuickActionBar_platbell(
                post_platbell: posts_platbell[index_platbell],
                gradientIndex_platbell: index_platbell
            )
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    .padding()
    .onAppear {
        LocalData_platbell.shared_platbell.initData_platbell()
        TitleViewModel_platbell.shared_platbell.initPosts_platbell()
        UserViewModel_platbell.shared_platbell.initUser_platbell()
    }
}
