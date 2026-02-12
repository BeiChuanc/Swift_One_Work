import SwiftUI

// MARK: - 紧凑统计项组件
// 核心作用：展示紧凑的统计数据
// 设计思路：图标 + 数值 + 标签横向排列
// 关键功能：数据展示、渐变色主题

/// 紧凑统计项组件
struct StatItemCompact_platbell: View {
    
    /// 图标名称
    let icon_platbell: String
    
    /// 数值
    let value_platbell: String
    
    /// 标签
    let label_platbell: String
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    var body: some View {
        HStack(spacing: 8) {
            // 图标
            ZStack {
                Circle()
                    .fill(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                            .opacity(0.2)
                    )
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon_platbell)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value_platbell)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(label_platbell)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            StatItemCompact_platbell(
                icon_platbell: "tag.fill",
                value_platbell: "24",
                label_platbell: "Topics",
                gradientIndex_platbell: 1
            )
            
            StatItemCompact_platbell(
                icon_platbell: "person.2.fill",
                value_platbell: "156",
                label_platbell: "Creators",
                gradientIndex_platbell: 2
            )
            
            StatItemCompact_platbell(
                icon_platbell: "heart.fill",
                value_platbell: "2.5K",
                label_platbell: "Likes",
                gradientIndex_platbell: 3
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    .padding()
}
