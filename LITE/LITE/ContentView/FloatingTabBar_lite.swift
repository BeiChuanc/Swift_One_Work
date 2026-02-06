import SwiftUI

// MARK: - 悬浮底部导航栏

/// 悬浮底部导航栏视图
struct FloatingTabBar_lite: View {
    
    // MARK: - 属性
    
    /// 当前选中的标签索引
    @Binding var selectedTab_lite: Int
    
    /// 标签选中回调
    var onTabSelected_lite: (Int) -> Void
    
    /// 动画状态：记录每个按钮的点击状态
    @State private var tappedIndex_lite: Int? = nil
    
    /// 中间按钮的旋转角度
    @State private var centerButtonRotation_lite: Double = 0
    
    // MARK: - 视图主体
    
    var body: some View {
        HStack(spacing: 0) {
            // Home 按钮
            tabButton_lite(
                icon_lite: "home",
                label_lite: "Home",
                index_lite: 0
            )
            
            Spacer()
            
            // Discover 按钮
            tabButton_lite(
                icon_lite: "discover",
                label_lite: "Find",
                index_lite: 1
            )
            
            Spacer()
            
            // Release 按钮（中间突出）
            centerButton_lite
            
            Spacer()
            
            // Messages 按钮
            tabButton_lite(
                icon_lite: "message",
                label_lite: "Chat",
                index_lite: 3
            )
            
            Spacer()
            
            // Profile 按钮
            tabButton_lite(
                icon_lite: "me",
                label_lite: "Mine",
                index_lite: 4
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "8F9DF0"), Color(hex: "8559B3")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 0)
    }
    
    // MARK: - 普通标签按钮
    
    /// 创建单个标签按钮
    @ViewBuilder
    private func tabButton_lite(
        icon_lite: String,
        label_lite: String,
        index_lite: Int
    ) -> some View {
        let isSelected_lite = selectedTab_lite == index_lite
        let isTapped_lite = tappedIndex_lite == index_lite
        
        Button(action: {
            handleTabTap_lite(index_lite: index_lite)
        }) {
            VStack(spacing: 4) {
                // 图标 - 从 Assets 加载
                Image(icon_lite)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .scaleEffect(isTapped_lite ? 1.3 : (isSelected_lite ? 1.1 : 1.0))
                    .rotationEffect(.degrees(isTapped_lite ? 360 : 0))
                
                // 标签文本
                Text(label_lite)
                    .font(.system(size: 10, weight: isSelected_lite ? .semibold : .regular))
                    .foregroundColor(isSelected_lite ? .white : Color(hex: "B0B0B0"))
                    .scaleEffect(isSelected_lite ? 1.05 : 1.0)
            }
            .frame(width: 60, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected_lite ? Color.white.opacity(0.15) : Color.clear)
                    .scaleEffect(isTapped_lite ? 1.2 : 1.0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: isSelected_lite)
        .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0), value: isTapped_lite)
    }
    
    // MARK: - 中间发布按钮
    
    /// 中间的发布按钮（突出显示）
    private var centerButton_lite: some View {
        let isTapped_lite = tappedIndex_lite == 2
        
        return Button(action: {
            handleCenterButtonTap_lite()
        }) {
            // 发布图标 - 从 Assets 加载
            Image("publish")
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 40)
                .foregroundColor(Color(hex: "8559B3"))
                .scaleEffect(isTapped_lite ? 0.85 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: isTapped_lite)
        .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0), value: centerButtonRotation_lite)
    }
    
    // MARK: - 事件处理方法
    
    /// 处理标签点击事件
    private func handleTabTap_lite(index_lite: Int) {
        // 触发点击动画
        tappedIndex_lite = index_lite
        
        // 触觉反馈
        let generator_lite = UIImpactFeedbackGenerator(style: .medium)
        generator_lite.impactOccurred()
        
        // 延迟后重置动画状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tappedIndex_lite = nil
        }
        
        // 触发选中回调
        onTabSelected_lite(index_lite)
        
        print("📱 导航栏：切换到标签 \(index_lite)")
    }
    
    /// 处理中间按钮点击事件
    private func handleCenterButtonTap_lite() {
        // 触发点击动画
        tappedIndex_lite = 2
        
        // 旋转动画
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
            centerButtonRotation_lite += 135
        }
        
        // 强烈触觉反馈
        let generator_lite = UIImpactFeedbackGenerator(style: .heavy)
        generator_lite.impactOccurred()
        
        // 延迟后重置动画状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tappedIndex_lite = nil
        }
        
        // 触发选中回调
        onTabSelected_lite(2)
        
        print("📱 导航栏：点击发布按钮")
    }
}
