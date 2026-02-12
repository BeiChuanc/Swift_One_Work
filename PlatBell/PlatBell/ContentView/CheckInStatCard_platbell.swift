import SwiftUI

// MARK: - 打卡数据卡片组件
// 核心作用：展示用户的打卡统计数据
// 设计思路：图标 + 数值 + 单位 + 渐变背景 + 主要/次要样式
// 关键功能：数据展示、视觉强调

/// 打卡数据卡片组件
struct CheckInStatCard_platbell: View {
    
    /// 图标名称
    let icon_platbell: String
    
    /// 标题
    let title_platbell: String
    
    /// 数值
    let value_platbell: String
    
    /// 单位
    let unit_platbell: String
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 是否为主要卡片（样式不同）
    let isPrimary_platbell: Bool
    
    /// 按压状态
    @State private var isPressed_platbell = false
    
    var body: some View {
        Button(action: {
            handleTap_platbell()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // 顶部：图标和标题
                HStack(spacing: 8) {
                    // 图标
                    ZStack {
                        Circle()
                            .fill(
                                isPrimary_platbell
                                    ? AnyShapeStyle(Color.white.opacity(0.3))
                                    : AnyShapeStyle(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell).opacity(0.2))
                            )
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: icon_platbell)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(
                                isPrimary_platbell
                                    ? .white
                                    : ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                            )
                    }
                    
                    Text(title_platbell)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(
                            isPrimary_platbell
                                ? .white.opacity(0.9)
                                : .secondary
                        )
                    
                    Spacer()
                }
                
                // 数值
                Text(value_platbell)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(
                        isPrimary_platbell
                            ? .white
                            : .primary
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // 单位
                Text(unit_platbell)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(
                        isPrimary_platbell
                            ? .white.opacity(0.8)
                            : .secondary
                    )
            }
            .padding(16)
            .frame(width: 140, height: 140)
            .background(
                Group {
                    if isPrimary_platbell {
                        // 主要卡片：渐变填充
                        RoundedRectangle(cornerRadius: 20)
                            .fill(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
                    } else {
                        // 次要卡片：白色背景 + 渐变边框
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.3),
                                                ThemeColors_platbell.allEndColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allEndColors_platbell.count].opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                    }
                }
            )
            .shadow(
                color: isPrimary_platbell
                    ? ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.4)
                    : Color.black.opacity(0.05),
                radius: isPrimary_platbell ? 12 : 6,
                x: 0,
                y: isPrimary_platbell ? 6 : 3
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
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
        
        // 显示详情提示
        Utils_platbell.showInfo_platbell(
            message_platbell: "\(title_platbell): \(value_platbell) \(unit_platbell)",
            delay_platbell: 1.5
        )
    }
}

// MARK: - 预览

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 12) {
            CheckInStatCard_platbell(
                icon_platbell: "flame.fill",
                title_platbell: "Streak",
                value_platbell: "7",
                unit_platbell: "days",
                gradientIndex_platbell: 4,
                isPrimary_platbell: true
            )
            
            CheckInStatCard_platbell(
                icon_platbell: "calendar.badge.checkmark",
                title_platbell: "This Week",
                value_platbell: "5",
                unit_platbell: "check-ins",
                gradientIndex_platbell: 0,
                isPrimary_platbell: false
            )
            
            CheckInStatCard_platbell(
                icon_platbell: "checkmark.seal.fill",
                title_platbell: "Total",
                value_platbell: "128",
                unit_platbell: "check-ins",
                gradientIndex_platbell: 2,
                isPrimary_platbell: false
            )
            
            CheckInStatCard_platbell(
                icon_platbell: "trophy.fill",
                title_platbell: "Ranking",
                value_platbell: "#12",
                unit_platbell: "this month",
                gradientIndex_platbell: 1,
                isPrimary_platbell: false
            )
            
            CheckInStatCard_platbell(
                icon_platbell: "star.fill",
                title_platbell: "Points",
                value_platbell: "980",
                unit_platbell: "total",
                gradientIndex_platbell: 3,
                isPrimary_platbell: false
            )
        }
        .padding()
    }
    .background(Color(.systemGray6))
}
