import SwiftUI

// MARK: - 徽章展示组件
// 核心作用：展示冥想徽章的视图
// 设计思路：使用渐变色、锁定/解锁状态、点击查看详情
// 关键功能：徽章展示、解锁动画

/// 徽章视图
struct BadgeView_blisslink: View {
    
    // MARK: - 属性
    
    /// 徽章数据
    let badge_blisslink: MeditationBadge_blisslink
    
    /// 尺寸
    var size_blisslink: CGFloat = 70.w_baseswiftui
    
    /// 是否显示名称
    var showName_blisslink: Bool = true
    
    /// 点击回调
    var onTap_blisslink: (() -> Void)?
    
    // MARK: - 视图主体
    
    var body: some View {
        Button(action: {
            onTap_blisslink?()
        }) {
            VStack(spacing: 8.h_baseswiftui) {
                // 徽章图标
                ZStack {
                    if badge_blisslink.isUnlocked_blisslink {
                        // 已解锁：渐变背景
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: badgeColors_blisslink),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: size_blisslink, height: size_blisslink)
                            .shadow(color: badgeColors_blisslink[0].opacity(0.4), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: badge_blisslink.badgeIcon_blisslink)
                            .font(.system(size: size_blisslink * 0.5, weight: .semibold))
                            .foregroundColor(.white)
                    } else {
                        // 未解锁：灰色
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: size_blisslink, height: size_blisslink)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: size_blisslink * 0.4, weight: .medium))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                
                // 徽章名称
                if showName_blisslink {
                    Text(badge_blisslink.badgeName_blisslink)
                        .font(.system(size: 11.sp_baseswiftui, weight: badge_blisslink.isUnlocked_blisslink ? .bold : .medium))
                        .foregroundColor(badge_blisslink.isUnlocked_blisslink ? .primary : .secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(width: size_blisslink + 10.w_baseswiftui)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 计算属性
    
    /// 徽章颜色
    private var badgeColors_blisslink: [Color] {
        return badge_blisslink.badgeColor_blisslink.map { Color(hex: $0) }
    }
}

// MARK: - 徽章详情弹窗

/// 徽章详情视图
struct BadgeDetailView_blisslink: View {
    
    /// 徽章数据
    let badge_blisslink: MeditationBadge_blisslink
    
    /// 关闭回调
    var onDismiss_blisslink: (() -> Void)?
    
    var body: some View {
        GeometryReader { geometry_blisslink in
            ZStack {
                // 半透明背景 - 立即铺满整个屏幕
                Color.black.opacity(0.01)
                    .frame(
                        width: geometry_blisslink.size.width,
                        height: geometry_blisslink.size.height
                    )
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        onDismiss_blisslink?()
                    }
                
                // 卡片内容
                VStack(spacing: 24.h_baseswiftui) {
                    // 徽章大图
                    ZStack {
                        if badge_blisslink.isUnlocked_blisslink {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: badge_blisslink.badgeColor_blisslink.map { Color(hex: $0) }),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120.w_baseswiftui, height: 120.h_baseswiftui)
                                .shadow(color: Color(hex: badge_blisslink.badgeColor_blisslink[0]).opacity(0.5), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: badge_blisslink.badgeIcon_blisslink)
                                .font(.system(size: 60.sp_baseswiftui, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120.w_baseswiftui, height: 120.h_baseswiftui)
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 50.sp_baseswiftui))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // 徽章信息
                    VStack(spacing: 12.h_baseswiftui) {
                        Text(badge_blisslink.badgeName_blisslink)
                            .font(.system(size: 24.sp_baseswiftui, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(badge_blisslink.badgeDescription_blisslink)
                            .font(.system(size: 15.sp_baseswiftui))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                        
                        // 解锁条件
                        HStack(spacing: 6.w_baseswiftui) {
                            Image(systemName: badge_blisslink.isUnlocked_blisslink ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 14.sp_baseswiftui))
                            Text(badge_blisslink.unlockCondition_blisslink)
                                .font(.system(size: 13.sp_baseswiftui, weight: .medium))
                        }
                        .foregroundColor(badge_blisslink.isUnlocked_blisslink ? .green : .gray)
                        .padding(.horizontal, 16.w_baseswiftui)
                        .padding(.vertical, 8.h_baseswiftui)
                        .background(
                            Capsule()
                                .fill(badge_blisslink.isUnlocked_blisslink ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                        
                        // 解锁日期
                        if badge_blisslink.isUnlocked_blisslink, let unlockDate_blisslink = badge_blisslink.unlockDate_blisslink {
                            Text("Unlocked on \(formattedDate_blisslink(unlockDate_blisslink))")
                                .font(.system(size: 12.sp_baseswiftui))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 30.w_baseswiftui)
                }
                .padding(30.w_baseswiftui)
                .background(
                    RoundedRectangle(cornerRadius: 24.w_baseswiftui)
                        .fill(Color.white)
                )
                .padding(.horizontal, 40.w_baseswiftui)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(
                width: geometry_blisslink.size.width,
                height: geometry_blisslink.size.height
            )
        }
    }
    
    // MARK: - 辅助方法
    
    /// 格式化日期
    private func formattedDate_blisslink(_ date_blisslink: Date) -> String {
        let formatter_blisslink = DateFormatter()
        formatter_blisslink.dateFormat = "MMM dd, yyyy"
        return formatter_blisslink.string(from: date_blisslink)
    }
}
