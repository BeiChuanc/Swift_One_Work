import SwiftUI

// MARK: - 悬浮底部导航栏
// 核心作用：底部导航栏，支持5个标签页切换
// 设计思路：使用Assets图标，滑条动画指示选中项，发布按钮旋转动画
// 关键功能：滑条跟随动画、发布按钮旋转、触觉反馈

/// 悬浮底部导航栏视图
struct FloatingTabBar_baseswiftui: View {
    
    // MARK: - 属性
    
    /// 当前选中的标签索引
    @Binding var selectedTab_baseswiftui: Int
    
    /// 标签选中回调
    var onTabSelected_baseswiftui: (Int) -> Void
    
    /// 中间按钮的旋转角度
    @State private var centerButtonRotation_baseswiftui: Double = 0
    
    /// 滑条位置（用于动画）
    @Namespace private var indicatorNamespace_blisslink
    
    // MARK: - 视图主体
    
    var body: some View {
        HStack(spacing: 0) {
            // Home 按钮
            tabButton_blisslink(
                iconName_blisslink: "home",
                index_blisslink: 0
            )
            
            Spacer()
            
            // Discover 按钮
            tabButton_blisslink(
                iconName_blisslink: "discover",
                index_blisslink: 1
            )
            
            Spacer()
            
            // Release 按钮（中间突出）
            centerButton_blisslink
            
            Spacer()
            
            // Messages 按钮
            tabButton_blisslink(
                iconName_blisslink: "message",
                index_blisslink: 3
            )
            
            Spacer()
            
            // Profile 按钮
            tabButton_blisslink(
                iconName_blisslink: "me",
                index_blisslink: 4
            )
        }
        .padding(.horizontal, 20.w_baseswiftui)
        .padding(.top, 12.h_baseswiftui)
        .padding(.bottom, 8.h_baseswiftui)
        .background(
            RoundedRectangle(cornerRadius: 25.w_baseswiftui)
                .fill(Color(hex: "005A64"))
                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal, 20.w_baseswiftui)
        .padding(.bottom, 0)
    }
    
    // MARK: - 普通标签按钮
    
    /// 创建单个标签按钮（使用Assets图标）
    /// 核心作用：展示导航图标，选中时在下方显示滑条
    @ViewBuilder
    private func tabButton_blisslink(
        iconName_blisslink: String,
        index_blisslink: Int
    ) -> some View {
        let isSelected_blisslink = selectedTab_baseswiftui == index_blisslink
        
        Button(action: {
            handleTabTap_blisslink(index_blisslink: index_blisslink)
        }) {
            VStack(spacing: 6.h_baseswiftui) {
                // Assets图标
                Image(iconName_blisslink)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26.w_baseswiftui, height: 26.h_baseswiftui)
                
                // 滑条指示器
                if isSelected_blisslink {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 26.w_baseswiftui, height: 3.h_baseswiftui)
                        .matchedGeometryEffect(id: "indicator", in: indicatorNamespace_blisslink)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 26.w_baseswiftui, height: 3.h_baseswiftui)
                }
            }
            .frame(width: 60.w_baseswiftui, height: 50.h_baseswiftui)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 中间发布按钮
    
    /// 中间的发布按钮（使用Assets图标）
    /// 核心作用：发布按钮，选中时旋转90度，不显示滑条
    private var centerButton_blisslink: some View {
        let isSelected_blisslink = selectedTab_baseswiftui == 2
        
        return Button(action: {
            handleCenterButtonTap_blisslink()
        }) {
            VStack(spacing: 6.h_baseswiftui) {
                // 发布图标（选中时旋转90度）
                Image("publish")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28.w_baseswiftui, height: 28.h_baseswiftui)
                    .rotationEffect(.degrees(isSelected_blisslink ? 90 : 0))
                
                // 占位空间（不显示滑条，但保持高度一致）
                Spacer()
                    .frame(height: 3.h_baseswiftui)
            }
            .frame(width: 60.w_baseswiftui, height: 50.h_baseswiftui)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isSelected_blisslink)
    }
    
    // MARK: - 事件处理方法
    
    /// 处理标签点击事件
    /// 核心作用：处理普通标签的点击，更新选中状态并触发回调
    private func handleTabTap_blisslink(index_blisslink: Int) {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        // 触发选中回调
        onTabSelected_baseswiftui(index_blisslink)
        
        print("📱 导航栏：切换到标签 \(index_blisslink)")
    }
    
    /// 处理中间发布按钮点击事件
    /// 核心作用：处理发布按钮点击，带旋转动画
    private func handleCenterButtonTap_blisslink() {
        // 强烈触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .heavy)
        generator_blisslink.impactOccurred()
        
        // 触发选中回调
        onTabSelected_baseswiftui(2)
        
        print("📱 导航栏：点击发布按钮")
    }
}
