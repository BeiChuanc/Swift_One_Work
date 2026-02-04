import SwiftUI

// MARK: - 通用导航栏组件

/// 通用导航栏组件
struct NavigationBar_lite<RightContent: View>: View {
    
    // MARK: - 属性
    
    let title_lite: String
    let showBackButton_lite: Bool
    let onBack_lite: (() -> Void)?
    let rightButton_lite: RightContent
    
    // MARK: - 初始化方法
    
    /// 初始化导航栏
    init(
        title_lite: String,
        showBackButton_lite: Bool = true,
        onBack_lite: (() -> Void)? = nil,
        @ViewBuilder rightButton_lite: () -> RightContent
    ) {
        self.title_lite = title_lite
        self.showBackButton_lite = showBackButton_lite
        self.onBack_lite = onBack_lite
        self.rightButton_lite = rightButton_lite()
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 背景
                Color.white
                    .ignoresSafeArea(edges: .top)
                
                // 标题（绝对居中）
                Text(title_lite)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                // 左右按钮
                HStack {
                    // 左侧：返回按钮
                    Group {
                        if showBackButton_lite, let onBack = onBack_lite {
                            BackButton_lite(onTapped_lite: onBack)
                        }
                    }
                    .frame(minWidth: 44, alignment: .leading)
                    
                    Spacer()
                    
                    // 右侧：自定义按钮
                    rightButton_lite
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

extension NavigationBar_lite where RightContent == EmptyView {
    
    /// 初始化导航栏（无右侧按钮）
    init(
        title_lite: String,
        showBackButton_lite: Bool = true,
        onBack_lite: (() -> Void)? = nil
    ) {
        self.title_lite = title_lite
        self.showBackButton_lite = showBackButton_lite
        self.onBack_lite = onBack_lite
        self.rightButton_lite = EmptyView()
    }
}

// MARK: - 导航栏按钮组件

/// 导航栏图标按钮
struct NavIconButton_lite: View {
    
    let iconName_lite: String
    let onTapped_lite: () -> Void
    var iconColor_lite: Color = .blue
    
    var body: some View {
        NavButton_lite(onTapped_lite: onTapped_lite) {
            Image(systemName: iconName_lite)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor_lite)
        }
    }
}

/// 导航栏文字按钮
/// 功能：显示文字的可点击按钮，带触觉反馈和动画
struct NavTextButton_lite: View {
    
    let text_lite: String
    let onTapped_lite: () -> Void
    var textColor_lite: Color = .blue
    
    var body: some View {
        NavButton_lite(onTapped_lite: onTapped_lite) {
            Text(text_lite)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textColor_lite)
        }
    }
}

/// 导航栏按钮基础组件
private struct NavButton_lite<Content: View>: View {
    
    let onTapped_lite: () -> Void
    let content_lite: Content
    
    @State private var isPressed_lite = false
    
    init(
        onTapped_lite: @escaping () -> Void,
        @ViewBuilder content_lite: () -> Content
    ) {
        self.onTapped_lite = onTapped_lite
        self.content_lite = content_lite()
    }
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTapped_lite()
        }) {
            content_lite
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .scaleEffect(isPressed_lite ? 0.88 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed_lite = true }
                .onEnded { _ in isPressed_lite = false }
        )
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed_lite)
    }
}

// MARK: - View 扩展

extension View {
    
    /// 添加自定义导航栏
    func customNavigationBar_lite<RightContent: View>(
        title_lite: String,
        showBackButton_lite: Bool = true,
        onBack_lite: (() -> Void)? = nil,
        @ViewBuilder rightButton_lite: () -> RightContent = { EmptyView() }
    ) -> some View {
        VStack(spacing: 0) {
            NavigationBar_lite(
                title_lite: title_lite,
                showBackButton_lite: showBackButton_lite,
                onBack_lite: onBack_lite,
                rightButton_lite: rightButton_lite
            )
            self
        }
        .navigationBarHidden(true)
    }
}
