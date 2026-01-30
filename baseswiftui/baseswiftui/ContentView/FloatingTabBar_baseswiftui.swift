import SwiftUI

// MARK: - 悬浮底部导航栏

/// 悬浮底部导航栏视图
struct FloatingTabBar_baseswiftui: View {
    
    // MARK: - 属性
    
    /// 当前选中的标签索引
    @Binding var selectedTab_baseswiftui: Int
    
    /// 标签选中回调
    var onTabSelected_baseswiftui: (Int) -> Void
    
    /// 动画状态：记录每个按钮的点击状态
    @State private var tappedIndex_baseswiftui: Int? = nil
    
    /// 中间按钮的旋转角度
    @State private var centerButtonRotation_baseswiftui: Double = 0
    
    // MARK: - 视图主体
    
    var body: some View {
        HStack(spacing: 0) {
            // Home 按钮
            tabButton_baseswiftui(
                icon_baseswiftui: "house",
                filledIcon_baseswiftui: "house.fill",
                label_baseswiftui: "Home",
                index_baseswiftui: 0
            )
            
            Spacer()
            
            // Discover 按钮
            tabButton_baseswiftui(
                icon_baseswiftui: "safari",
                filledIcon_baseswiftui: "safari.fill",
                label_baseswiftui: "Discover",
                index_baseswiftui: 1
            )
            
            Spacer()
            
            // Release 按钮（中间突出）
            centerButton_baseswiftui
            
            Spacer()
            
            // Messages 按钮
            tabButton_baseswiftui(
                icon_baseswiftui: "message",
                filledIcon_baseswiftui: "message.fill",
                label_baseswiftui: "Messages",
                index_baseswiftui: 3
            )
            
            Spacer()
            
            // Profile 按钮
            tabButton_baseswiftui(
                icon_baseswiftui: "person",
                filledIcon_baseswiftui: "person.fill",
                label_baseswiftui: "Profile",
                index_baseswiftui: 4
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                .shadow(color: Color.blue.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 0)
    }
    
    // MARK: - 普通标签按钮
    
    /// 创建单个标签按钮
    @ViewBuilder
    private func tabButton_baseswiftui(
        icon_baseswiftui: String,
        filledIcon_baseswiftui: String,
        label_baseswiftui: String,
        index_baseswiftui: Int
    ) -> some View {
        let isSelected_baseswiftui = selectedTab_baseswiftui == index_baseswiftui
        let isTapped_baseswiftui = tappedIndex_baseswiftui == index_baseswiftui
        
        Button(action: {
            handleTabTap_baseswiftui(index_baseswiftui: index_baseswiftui)
        }) {
            VStack(spacing: 4) {
                // 图标
                Image(systemName: isSelected_baseswiftui ? filledIcon_baseswiftui : icon_baseswiftui)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected_baseswiftui ? .blue : .gray)
                    .scaleEffect(isTapped_baseswiftui ? 1.3 : (isSelected_baseswiftui ? 1.1 : 1.0))
                    .rotationEffect(.degrees(isTapped_baseswiftui ? 360 : 0))
                
                // 标签文本
                Text(label_baseswiftui)
                    .font(.system(size: 10, weight: isSelected_baseswiftui ? .semibold : .regular))
                    .foregroundColor(isSelected_baseswiftui ? .blue : .gray)
                    .scaleEffect(isSelected_baseswiftui ? 1.05 : 1.0)
            }
            .frame(width: 60, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected_baseswiftui ? Color.blue.opacity(0.1) : Color.clear)
                    .scaleEffect(isTapped_baseswiftui ? 1.2 : 1.0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: isSelected_baseswiftui)
        .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0), value: isTapped_baseswiftui)
    }
    
    // MARK: - 中间发布按钮
    
    /// 中间的发布按钮（突出显示）
    private var centerButton_baseswiftui: some View {
        let isTapped_baseswiftui = tappedIndex_baseswiftui == 2
        
        return Button(action: {
            handleCenterButtonTap_baseswiftui()
        }) {
            ZStack {
                // 外层光晕效果
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .scaleEffect(isTapped_baseswiftui ? 1.3 : 1.0)
                    .opacity(isTapped_baseswiftui ? 0 : 0.5)
                
                // 主按钮
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.purple
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                
                // 加号图标
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(centerButtonRotation_baseswiftui))
            }
            .scaleEffect(isTapped_baseswiftui ? 0.85 : 1.0)
            .offset(y: -10) // 向上偏移，突出显示
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: isTapped_baseswiftui)
        .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0), value: centerButtonRotation_baseswiftui)
    }
    
    // MARK: - 事件处理方法
    
    /// 处理标签点击事件
    private func handleTabTap_baseswiftui(index_baseswiftui: Int) {
        // 触发点击动画
        tappedIndex_baseswiftui = index_baseswiftui
        
        // 触觉反馈
        let generator_baseswiftui = UIImpactFeedbackGenerator(style: .medium)
        generator_baseswiftui.impactOccurred()
        
        // 延迟后重置动画状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tappedIndex_baseswiftui = nil
        }
        
        // 触发选中回调
        onTabSelected_baseswiftui(index_baseswiftui)
        
        print("📱 导航栏：切换到标签 \(index_baseswiftui)")
    }
    
    /// 处理中间按钮点击事件
    private func handleCenterButtonTap_baseswiftui() {
        // 触发点击动画
        tappedIndex_baseswiftui = 2
        
        // 旋转动画
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
            centerButtonRotation_baseswiftui += 135
        }
        
        // 强烈触觉反馈
        let generator_baseswiftui = UIImpactFeedbackGenerator(style: .heavy)
        generator_baseswiftui.impactOccurred()
        
        // 延迟后重置动画状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tappedIndex_baseswiftui = nil
        }
        
        // 触发选中回调
        onTabSelected_baseswiftui(2)
        
        print("📱 导航栏：点击发布按钮")
    }
}
