import SwiftUI

// MARK: - 通用导航栏组件

/// 通用导航栏组件
struct NavigationBar_baseswiftui<RightContent: View>: View {
    
    // MARK: - 属性
    
    let title_baseswiftui: String
    let showBackButton_baseswiftui: Bool
    let onBack_baseswiftui: (() -> Void)?
    let rightButton_baseswiftui: RightContent
    
    // MARK: - 初始化方法
    
    /// 初始化导航栏
    init(
        title_baseswiftui: String,
        showBackButton_baseswiftui: Bool = true,
        onBack_baseswiftui: (() -> Void)? = nil,
        @ViewBuilder rightButton_baseswiftui: () -> RightContent
    ) {
        self.title_baseswiftui = title_baseswiftui
        self.showBackButton_baseswiftui = showBackButton_baseswiftui
        self.onBack_baseswiftui = onBack_baseswiftui
        self.rightButton_baseswiftui = rightButton_baseswiftui()
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 背景
                Color.white
                    .ignoresSafeArea(edges: .top)
                
                // 标题（绝对居中）
                Text(title_baseswiftui)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                // 左右按钮
                HStack {
                    // 左侧：返回按钮
                    Group {
                        if showBackButton_baseswiftui, let onBack = onBack_baseswiftui {
                            BackButton_baseswiftui(onTapped_baseswiftui: onBack)
                        }
                    }
                    .frame(minWidth: 44, alignment: .leading)
                    
                    Spacer()
                    
                    // 右侧：自定义按钮
                    rightButton_baseswiftui
                        .frame(minWidth: 44, alignment: .trailing)
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 56)
            
            Divider()
        }
    }
}

// MARK: - 无右侧按钮扩展

extension NavigationBar_baseswiftui where RightContent == EmptyView {
    
    /// 初始化导航栏（无右侧按钮）
    init(
        title_baseswiftui: String,
        showBackButton_baseswiftui: Bool = true,
        onBack_baseswiftui: (() -> Void)? = nil
    ) {
        self.title_baseswiftui = title_baseswiftui
        self.showBackButton_baseswiftui = showBackButton_baseswiftui
        self.onBack_baseswiftui = onBack_baseswiftui
        self.rightButton_baseswiftui = EmptyView()
    }
}

// MARK: - 导航栏按钮组件

/// 导航栏图标按钮
struct NavIconButton_baseswiftui: View {
    
    let iconName_baseswiftui: String
    let onTapped_baseswiftui: () -> Void
    var iconColor_baseswiftui: Color = .blue
    
    var body: some View {
        NavButton_baseswiftui(onTapped_baseswiftui: onTapped_baseswiftui) {
            Image(systemName: iconName_baseswiftui)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor_baseswiftui)
        }
    }
}

/// 导航栏文字按钮
/// 功能：显示文字的可点击按钮，带触觉反馈和动画
struct NavTextButton_baseswiftui: View {
    
    let text_baseswiftui: String
    let onTapped_baseswiftui: () -> Void
    var textColor_baseswiftui: Color = .blue
    
    var body: some View {
        NavButton_baseswiftui(onTapped_baseswiftui: onTapped_baseswiftui) {
            Text(text_baseswiftui)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textColor_baseswiftui)
        }
    }
}

/// 导航栏按钮基础组件
private struct NavButton_baseswiftui<Content: View>: View {
    
    let onTapped_baseswiftui: () -> Void
    let content_baseswiftui: Content
    
    @State private var isPressed_baseswiftui = false
    
    init(
        onTapped_baseswiftui: @escaping () -> Void,
        @ViewBuilder content_baseswiftui: () -> Content
    ) {
        self.onTapped_baseswiftui = onTapped_baseswiftui
        self.content_baseswiftui = content_baseswiftui()
    }
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTapped_baseswiftui()
        }) {
            content_baseswiftui
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .scaleEffect(isPressed_baseswiftui ? 0.88 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed_baseswiftui = true }
                .onEnded { _ in isPressed_baseswiftui = false }
        )
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed_baseswiftui)
    }
}

// MARK: - View 扩展

extension View {
    
    /// 添加自定义导航栏
    func customNavigationBar_baseswiftui<RightContent: View>(
        title_baseswiftui: String,
        showBackButton_baseswiftui: Bool = true,
        onBack_baseswiftui: (() -> Void)? = nil,
        @ViewBuilder rightButton_baseswiftui: () -> RightContent = { EmptyView() }
    ) -> some View {
        VStack(spacing: 0) {
            NavigationBar_baseswiftui(
                title_baseswiftui: title_baseswiftui,
                showBackButton_baseswiftui: showBackButton_baseswiftui,
                onBack_baseswiftui: onBack_baseswiftui,
                rightButton_baseswiftui: rightButton_baseswiftui
            )
            self
        }
        .navigationBarHidden(true)
    }
}
