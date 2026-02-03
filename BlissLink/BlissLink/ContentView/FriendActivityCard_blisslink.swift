import SwiftUI

// MARK: - 好友动态卡片组件
// 核心作用：展示好友的瑜伽垫活动动态
// 设计思路：简洁卡片样式，支持点击串门，使用UserAvatarView展示头像
// 关键功能：动态展示、串门跳转、响应式更新（用户被举报时自动更新）

/// 好友动态卡片视图
struct FriendActivityCard_blisslink: View {
    
    // MARK: - 属性
    
    /// 好友动态数据
    let activity_blisslink: FriendActivity_blisslink
    
    /// 点击回调（串门）
    var onTap_blisslink: (() -> Void)?
    
    /// 动画状态
    @State private var isPressed_blisslink: Bool = false
    
    /// 本地数据（响应式）
    @ObservedObject var localData_baseswiftui = LocalData_baseswiftui.shared_baseswiftui
    
    // MARK: - 视图主体
    
    var body: some View {
        Button(action: {
            handleTap_blisslink()
        }) {
            HStack(spacing: 12.w_baseswiftui) {
                // 好友头像（使用 UserAvatarView 组件）
                UserAvatarView_baseswiftui(
                    userId_baseswiftui: activity_blisslink.friendUserId_blisslink,
                    avatarPath_baseswiftui: getFriendAvatarPath_blisslink(),
                    userName_baseswiftui: activity_blisslink.friendName_blisslink,
                    size_baseswiftui: 50.w_baseswiftui,
                    isClickable_baseswiftui: false
                )
                
                // 动态内容
                VStack(alignment: .leading, spacing: 4.h_baseswiftui) {
                    // 好友名称
                    Text(activity_blisslink.friendName_blisslink)
                        .font(.system(size: 14.sp_baseswiftui, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // 动态描述
                    HStack(spacing: 6.w_baseswiftui) {
                        Image(systemName: activity_blisslink.activityType_blisslink.iconName_blisslink)
                            .font(.system(size: 12.sp_baseswiftui))
                            .foregroundColor(activityColor_blisslink)
                        
                        Text(activity_blisslink.activityContent_blisslink)
                            .font(.system(size: 13.sp_baseswiftui))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    // 时间
                    Text(timeAgo_blisslink)
                        .font(.system(size: 11.sp_baseswiftui))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                Spacer()
                
                // 串门图标
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 22.sp_baseswiftui))
                    .foregroundColor(Color(hex: "667EEA"))
            }
            .padding(14.w_baseswiftui)
            .background(
                RoundedRectangle(cornerRadius: 14.w_baseswiftui)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed_blisslink ? 0.97 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0), value: isPressed_blisslink)
    }
    
    // MARK: - 计算属性
    
    /// 获取好友头像路径
    /// 核心作用：从本地数据中查找好友的头像路径，支持响应式更新
    /// - Returns: 头像路径或nil
    private func getFriendAvatarPath_blisslink() -> String? {
        // 从本地数据中查找好友信息
        if let friend_blisslink = localData_baseswiftui.userList_baseswiftui.first(where: { 
            $0.userId_baseswiftui == activity_blisslink.friendUserId_blisslink 
        }) {
            return friend_blisslink.userHead_baseswiftui
        }
        
        // 如果未找到，返回activity中的头像字段（可能是系统图标）
        return activity_blisslink.friendAvatar_blisslink
    }
    
    /// 活动类型颜色
    private var activityColor_blisslink: Color {
        switch activity_blisslink.activityType_blisslink {
        case .changedBackground_blisslink:
            return Color(hex: "F2994A")
        case .unlockedBadge_blisslink:
            return Color(hex: "F2C94C")
        case .completedChallenge_blisslink:
            return Color(hex: "667EEA")
        case .addedMemory_blisslink:
            return Color(hex: "56CCF2")
        }
    }
    
    /// 时间差文本
    private var timeAgo_blisslink: String {
        let timeInterval_blisslink = Date().timeIntervalSince(activity_blisslink.activityTime_blisslink)
        let hours_blisslink = Int(timeInterval_blisslink / 3600)
        
        if hours_blisslink < 1 {
            return "Just now"
        } else if hours_blisslink < 24 {
            return "\(hours_blisslink)h ago"
        } else {
            let days_blisslink = hours_blisslink / 24
            return "\(days_blisslink)d ago"
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理点击（串门）
    private func handleTap_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        // 动画
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0)) {
            isPressed_blisslink = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                isPressed_blisslink = false
            }
        }
        
        // 执行回调
        onTap_blisslink?()
    }
}
