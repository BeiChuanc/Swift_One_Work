import SwiftUI

// MARK: - 悬浮底部导航栏

/// 悬浮底部导航栏视图
struct FloatingTabBar_platbell: View {
    
    // MARK: - 属性
    
    /// 当前选中的标签索引
    @Binding var selectedTab_platbell: Int
    
    /// 标签选中回调
    var onTabSelected_platbell: (Int) -> Void
    
    // MARK: - 视图主体
    
    var body: some View {
        GeometryReader { geometry_platbell in
            let tabWidth_platbell = (geometry_platbell.size.width - 40) / 5 // 减去左右padding
            
            ZStack(alignment: .bottom) {
                // 白色背景栏
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                    .shadow(color: Color.blue.opacity(0.05), radius: 8, x: 0, y: 2)
                
                // 滑动的圆形背景（大小25，颜色ADA4F9）
                Circle()
                    .fill(Color(hex: "ADA4F9"))
                    .frame(width: 25, height: 25)
                    .offset(
                        x: tabWidth_platbell * CGFloat(selectedTab_platbell) + tabWidth_platbell / 2 - geometry_platbell.size.width / 2 + 20,
                        y: -25
                    )
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selectedTab_platbell)
                
                HStack(spacing: 0) {
                    // Home 按钮
                    tabButton_platbell(
                        iconName_platbell: "home",
                        index_platbell: 0
                    )
                    .frame(width: tabWidth_platbell)
                    
                    // Discover 按钮
                    tabButton_platbell(
                        iconName_platbell: "discover",
                        index_platbell: 1
                    )
                    .frame(width: tabWidth_platbell)
                    
                    // Publish 按钮（中间按钮）
                    tabButton_platbell(
                        iconName_platbell: "publish",
                        index_platbell: 2
                    )
                    .frame(width: tabWidth_platbell)
                    
                    // Messages 按钮
                    tabButton_platbell(
                        iconName_platbell: "message",
                        index_platbell: 3
                    )
                    .frame(width: tabWidth_platbell)
                    
                    // Me 按钮
                    tabButton_platbell(
                        iconName_platbell: "me",
                        index_platbell: 4
                    )
                    .frame(width: tabWidth_platbell)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .frame(height: 70)
        .padding(.horizontal, 20)
        .padding(.bottom, 0)
    }
    
    // MARK: - 标签按钮
    
    /// 创建单个标签按钮
    /// 参数：iconName_platbell - Assets中的图标名称，index_platbell - 按钮索引
    @ViewBuilder
    private func tabButton_platbell(
        iconName_platbell: String,
        index_platbell: Int
    ) -> some View {
        Button(action: {
            handleTabTap_platbell(index_platbell: index_platbell)
        }) {
            // 图标
            Image(iconName_platbell)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 50)
    }
    
    // MARK: - 事件处理方法
    
    /// 处理标签点击事件
    /// 功能：触发滑动动画和触觉反馈
    private func handleTabTap_platbell(index_platbell: Int) {
        // 触觉反馈
        let generator_platbell = UIImpactFeedbackGenerator(style: .medium)
        generator_platbell.impactOccurred()
        
        // 触发选中回调
        onTabSelected_platbell(index_platbell)
        
        print("📱 导航栏：切换到标签 \(index_platbell)")
    }
}
