import SwiftUI

// MARK: - 通用导航栏组件

/// 通用导航栏组件
struct NavigationBar_blisslink<RightContent: View>: View {
    
    // MARK: - 属性
    
    let title_blisslink: String
    let showBackButton_blisslink: Bool
    let onBack_blisslink: (() -> Void)?
    let rightButton_blisslink: RightContent
    
    // MARK: - 初始化方法
    
    /// 初始化导航栏
    init(
        title_blisslink: String,
        showBackButton_blisslink: Bool = true,
        onBack_blisslink: (() -> Void)? = nil,
        @ViewBuilder rightButton_blisslink: () -> RightContent
    ) {
        self.title_blisslink = title_blisslink
        self.showBackButton_blisslink = showBackButton_blisslink
        self.onBack_blisslink = onBack_blisslink
        self.rightButton_blisslink = rightButton_blisslink()
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 背景
                Color.white
                    .ignoresSafeArea(edges: .top)
                
                // 标题（绝对居中）
                Text(title_blisslink)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                // 左右按钮
                HStack {
                    // 左侧：返回按钮
                    Group {
                        if showBackButton_blisslink, let onBack = onBack_blisslink {
                            BackButton_blisslink(onTapped_blisslink: onBack)
                        }
                    }
                    .frame(minWidth: 44, alignment: .leading)
                    
                    Spacer()
                    
                    // 右侧：自定义按钮
                    rightButton_blisslink
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

extension NavigationBar_blisslink where RightContent == EmptyView {
    
    /// 初始化导航栏（无右侧按钮）
    init(
        title_blisslink: String,
        showBackButton_blisslink: Bool = true,
        onBack_blisslink: (() -> Void)? = nil
    ) {
        self.title_blisslink = title_blisslink
        self.showBackButton_blisslink = showBackButton_blisslink
        self.onBack_blisslink = onBack_blisslink
        self.rightButton_blisslink = EmptyView()
    }
}

// MARK: - 导航栏按钮组件

/// 导航栏图标按钮
struct NavIconButton_blisslink: View {
    
    let iconName_blisslink: String
    let onTapped_blisslink: () -> Void
    var iconColor_blisslink: Color = .blue
    
    var body: some View {
        NavButton_blisslink(onTapped_blisslink: onTapped_blisslink) {
            Image(systemName: iconName_blisslink)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor_blisslink)
        }
    }
}

/// 导航栏文字按钮
/// 功能：显示文字的可点击按钮，带触觉反馈和动画
struct NavTextButton_blisslink: View {
    
    let text_blisslink: String
    let onTapped_blisslink: () -> Void
    var textColor_blisslink: Color = .blue
    
    var body: some View {
        NavButton_blisslink(onTapped_blisslink: onTapped_blisslink) {
            Text(text_blisslink)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textColor_blisslink)
        }
    }
}

/// 导航栏按钮基础组件
private struct NavButton_blisslink<Content: View>: View {
    
    let onTapped_blisslink: () -> Void
    let content_blisslink: Content
    
    @State private var isPressed_blisslink = false
    
    init(
        onTapped_blisslink: @escaping () -> Void,
        @ViewBuilder content_blisslink: () -> Content
    ) {
        self.onTapped_blisslink = onTapped_blisslink
        self.content_blisslink = content_blisslink()
    }
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTapped_blisslink()
        }) {
            content_blisslink
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .scaleEffect(isPressed_blisslink ? 0.88 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed_blisslink = true }
                .onEnded { _ in isPressed_blisslink = false }
        )
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed_blisslink)
    }
}

// MARK: - View 扩展

extension View {
    
    /// 添加自定义导航栏
    func customNavigationBar_blisslink<RightContent: View>(
        title_blisslink: String,
        showBackButton_blisslink: Bool = true,
        onBack_blisslink: (() -> Void)? = nil,
        @ViewBuilder rightButton_blisslink: () -> RightContent = { EmptyView() }
    ) -> some View {
        VStack(spacing: 0) {
            NavigationBar_blisslink(
                title_blisslink: title_blisslink,
                showBackButton_blisslink: showBackButton_blisslink,
                onBack_blisslink: onBack_blisslink,
                rightButton_blisslink: rightButton_blisslink
            )
            self
        }
        .navigationBarHidden(true)
    }
}
