import SwiftUI

// MARK: - 通用导航栏组件

/// 通用导航栏组件
struct NavigationBar_platbell<RightContent: View>: View {
    
    // MARK: - 属性
    
    let title_platbell: String
    let showBackButton_platbell: Bool
    let onBack_platbell: (() -> Void)?
    let rightButton_platbell: RightContent
    
    // MARK: - 初始化方法
    
    /// 初始化导航栏
    init(
        title_platbell: String,
        showBackButton_platbell: Bool = true,
        onBack_platbell: (() -> Void)? = nil,
        @ViewBuilder rightButton_platbell: () -> RightContent
    ) {
        self.title_platbell = title_platbell
        self.showBackButton_platbell = showBackButton_platbell
        self.onBack_platbell = onBack_platbell
        self.rightButton_platbell = rightButton_platbell()
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 背景
                Color.white
                    .ignoresSafeArea(edges: .top)
                
                // 标题（绝对居中）
                Text(title_platbell)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                // 左右按钮
                HStack {
                    // 左侧：返回按钮
                    Group {
                        if showBackButton_platbell, let onBack = onBack_platbell {
                            BackButton_platbell(onTapped_platbell: onBack)
                        }
                    }
                    .frame(minWidth: 44, alignment: .leading)
                    
                    Spacer()
                    
                    // 右侧：自定义按钮
                    rightButton_platbell
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

extension NavigationBar_platbell where RightContent == EmptyView {
    
    /// 初始化导航栏（无右侧按钮）
    init(
        title_platbell: String,
        showBackButton_platbell: Bool = true,
        onBack_platbell: (() -> Void)? = nil
    ) {
        self.title_platbell = title_platbell
        self.showBackButton_platbell = showBackButton_platbell
        self.onBack_platbell = onBack_platbell
        self.rightButton_platbell = EmptyView()
    }
}

/// 导航栏文字按钮
/// 功能：显示文字的可点击按钮，带触觉反馈和动画
struct NavTextButton_platbell: View {
    
    let text_platbell: String
    let onTapped_platbell: () -> Void
    var textColor_platbell: Color = .blue
    
    var body: some View {
        NavButton_platbell(onTapped_platbell: onTapped_platbell) {
            Text(text_platbell)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textColor_platbell)
        }
    }
}

/// 导航栏按钮基础组件
private struct NavButton_platbell<Content: View>: View {
    
    let onTapped_platbell: () -> Void
    let content_platbell: Content
    
    @State private var isPressed_platbell = false
    
    init(
        onTapped_platbell: @escaping () -> Void,
        @ViewBuilder content_platbell: () -> Content
    ) {
        self.onTapped_platbell = onTapped_platbell
        self.content_platbell = content_platbell()
    }
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTapped_platbell()
        }) {
            content_platbell
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .scaleEffect(isPressed_platbell ? 0.88 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed_platbell = true }
                .onEnded { _ in isPressed_platbell = false }
        )
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed_platbell)
    }
}

// MARK: - View 扩展

extension View {
    
    /// 添加自定义导航栏
    func customNavigationBar_platbell<RightContent: View>(
        title_platbell: String,
        showBackButton_platbell: Bool = true,
        onBack_platbell: (() -> Void)? = nil,
        @ViewBuilder rightButton_platbell: () -> RightContent = { EmptyView() }
    ) -> some View {
        VStack(spacing: 0) {
            NavigationBar_platbell(
                title_platbell: title_platbell,
                showBackButton_platbell: showBackButton_platbell,
                onBack_platbell: onBack_platbell,
                rightButton_platbell: rightButton_platbell
            )
            self
        }
        .navigationBarHidden(true)
    }
}
