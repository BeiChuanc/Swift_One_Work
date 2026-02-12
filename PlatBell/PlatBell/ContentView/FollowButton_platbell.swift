import SwiftUI

// MARK: - 关注按钮组件
// 核心作用：提供关注/取消关注功能，带状态切换动画
// 设计思路：渐变背景 + 状态切换 + 平滑动画
// 关键功能：关注状态管理、动画反馈

/// 关注按钮组件
struct FollowButton_platbell: View {
    
    /// 用户数据
    let user_platbell: PrewUserModel_platbell
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 是否紧凑模式
    let isCompact_platbell: Bool
    
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    
    /// 是否已关注
    private var isFollowing_platbell: Bool {
        userVM_platbell.isFollowing_platbell(user_platbell: user_platbell)
    }
    
    /// 按压状态
    @State private var isPressed_platbell = false
    
    init(user_platbell: PrewUserModel_platbell, gradientIndex_platbell: Int, isCompact_platbell: Bool = false) {
        self.user_platbell = user_platbell
        self.gradientIndex_platbell = gradientIndex_platbell
        self.isCompact_platbell = isCompact_platbell
    }
    
    var body: some View {
        Button(action: handleTap_platbell) {
            HStack(spacing: 6) {
                Image(systemName: isFollowing_platbell ? "checkmark" : "plus")
                    .font(.system(size: isCompact_platbell ? 12 : 14, weight: .semibold))
                
                Text(isFollowing_platbell ? "Followed" : "Follow")
                    .font(.system(size: isCompact_platbell ? 14 : 16, weight: .semibold))
            }
            .foregroundColor(isFollowing_platbell ? ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count] : .white)
            .padding(.horizontal, isCompact_platbell ? 16 : 24)
            .padding(.vertical, isCompact_platbell ? 8 : 12)
            .background(
                Group {
                    if isFollowing_platbell {
                        // 取消关注状态：边框样式
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell),
                                lineWidth: 2
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(.systemBackground))
                            )
                    } else {
                        // 关注状态：渐变填充
                        RoundedRectangle(cornerRadius: 25)
                            .fill(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
                    }
                }
            )
            .shadow(
                color: isFollowing_platbell
                    ? Color.clear
                    : ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(isPressed_platbell ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback_platbell.impactOccurred()
        
        // 切换关注状态
        userVM_platbell.followUser_platbell(user_platbell: user_platbell)
    }
}
