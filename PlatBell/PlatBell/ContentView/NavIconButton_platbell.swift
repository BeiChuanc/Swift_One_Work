import SwiftUI

// MARK: - 导航图标按钮组件
// 核心作用：提供通用的导航栏图标按钮
// 设计思路：支持自定义图标和点击事件，适配梦幻神秘主题
// 关键功能：触觉反馈、按压动画、渐变色支持

/// 导航图标按钮组件
struct NavIconButton_platbell: View {
    
    /// 图标名称
    let iconName_platbell: String
    
    /// 点击回调
    let onTapped_platbell: () -> Void
    
    /// 按钮尺寸
    var buttonSize_platbell: CGFloat = 44
    
    /// 图标大小
    var iconSize_platbell: CGFloat = 18
    
    /// 是否显示阴影
    var showShadow_platbell: Bool = true
    
    /// 是否使用渐变色
    var useGradient_platbell: Bool = false
    
    /// 渐变色索引
    var gradientIndex_platbell: Int = 0
    
    /// 自定义前景色
    var foregroundColor_platbell: Color? = nil
    
    /// 自定义背景色
    var backgroundColor_platbell: Color? = nil
    
    @State private var isPressed_platbell: Bool = false
    
    var body: some View {
        Button(action: {
            // 触觉反馈
            let impact_platbell = UIImpactFeedbackGenerator(style: .light)
            impact_platbell.impactOccurred()
            
            // 调用回调
            onTapped_platbell()
        }) {
            ZStack {
                // 背景
                Circle()
                    .fill(backgroundColor_platbell ?? Color(.systemGray6))
                    .frame(width: buttonSize_platbell, height: buttonSize_platbell)
                
                // 图标
                Image(systemName: iconName_platbell)
                    .font(.system(size: iconSize_platbell, weight: .semibold))
                    .foregroundStyle(
                        useGradient_platbell
                            ? AnyShapeStyle(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
                            : AnyShapeStyle(foregroundColor_platbell ?? Color.primary)
                    )
            }
            .shadow(
                color: showShadow_platbell ? Color.black.opacity(0.1) : Color.clear,
                radius: showShadow_platbell ? 6 : 0,
                x: 0,
                y: 3
            )
            .scaleEffect(isPressed_platbell ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed_platbell)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed_platbell = true
                }
                .onEnded { _ in
                    isPressed_platbell = false
                }
        )
    }
}

// MARK: - 梦幻导航按钮

/// 梦幻样式导航按钮（带渐变边框）
struct DreamyNavButton_platbell: View {
    
    /// 图标名称
    let iconName_platbell: String
    
    /// 点击回调
    let onTapped_platbell: () -> Void
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 按钮尺寸
    var buttonSize_platbell: CGFloat = 44
    
    /// 图标大小
    var iconSize_platbell: CGFloat = 18
    
    @State private var isPressed_platbell: Bool = false
    
    var body: some View {
        Button(action: {
            // 触觉反馈
            let impact_platbell = UIImpactFeedbackGenerator(style: .medium)
            impact_platbell.impactOccurred()
            
            onTapped_platbell()
        }) {
            ZStack {
                // 渐变背景
                Circle()
                    .fill(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                            .opacity(0.15)
                    )
                    .frame(width: buttonSize_platbell, height: buttonSize_platbell)
                
                // 图标
                Image(systemName: iconName_platbell)
                    .font(.system(size: iconSize_platbell, weight: .bold))
                    .foregroundStyle(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                    )
            }
            .overlay(
                Circle()
                    .stroke(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell),
                        lineWidth: 1.5
                    )
                    .frame(width: buttonSize_platbell, height: buttonSize_platbell)
            )
            .shadow(
                color: ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                    .opacity(0.2),
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(isPressed_platbell ? 0.9 : 1.0)
            .animation(AnimationPresets_platbell.quickSpring_platbell, value: isPressed_platbell)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed_platbell = true
                }
                .onEnded { _ in
                    isPressed_platbell = false
                }
        )
    }
}

// MARK: - 简洁导航按钮

/// 简洁样式导航按钮
struct SimpleNavButton_platbell: View {
    
    /// 图标名称
    let iconName_platbell: String
    
    /// 点击回调
    let onTapped_platbell: () -> Void
    
    /// 图标大小
    var iconSize_platbell: CGFloat = 20
    
    /// 前景色
    var foregroundColor_platbell: Color = .primary
    
    @State private var isPressed_platbell: Bool = false
    
    var body: some View {
        Button(action: {
            // 触觉反馈
            let impact_platbell = UIImpactFeedbackGenerator(style: .light)
            impact_platbell.impactOccurred()
            
            onTapped_platbell()
        }) {
            Image(systemName: iconName_platbell)
                .font(.system(size: iconSize_platbell, weight: .semibold))
                .foregroundColor(foregroundColor_platbell)
                .frame(width: 44, height: 44)
                .scaleEffect(isPressed_platbell ? 0.85 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed_platbell)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed_platbell = true
                }
                .onEnded { _ in
                    isPressed_platbell = false
                }
        )
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 30) {
        Text("Standard Nav Button")
            .font(.headline)
        
        HStack(spacing: 20) {
            NavIconButton_platbell(
                iconName_platbell: "xmark",
                onTapped_platbell: {}
            )
            
            NavIconButton_platbell(
                iconName_platbell: "ellipsis",
                onTapped_platbell: {}
            )
            
            NavIconButton_platbell(
                iconName_platbell: "heart",
                onTapped_platbell: {}
            )
        }
        
        Divider()
        
        Text("Dreamy Nav Button")
            .font(.headline)
        
        HStack(spacing: 20) {
            DreamyNavButton_platbell(
                iconName_platbell: "xmark",
                onTapped_platbell: {},
                gradientIndex_platbell: 0
            )
            
            DreamyNavButton_platbell(
                iconName_platbell: "ellipsis",
                onTapped_platbell: {},
                gradientIndex_platbell: 1
            )
            
            DreamyNavButton_platbell(
                iconName_platbell: "heart.fill",
                onTapped_platbell: {},
                gradientIndex_platbell: 2
            )
        }
        
        Divider()
        
        Text("Simple Nav Button")
            .font(.headline)
        
        HStack(spacing: 20) {
            SimpleNavButton_platbell(
                iconName_platbell: "xmark",
                onTapped_platbell: {}
            )
            
            SimpleNavButton_platbell(
                iconName_platbell: "ellipsis",
                onTapped_platbell: {}
            )
            
            SimpleNavButton_platbell(
                iconName_platbell: "heart",
                onTapped_platbell: {},
                foregroundColor_platbell: .red
            )
        }
    }
    .padding()
}
