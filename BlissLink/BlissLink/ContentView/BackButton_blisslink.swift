import SwiftUI

// MARK: - 返回按钮组件

/// 返回按钮组件
struct BackButton_blisslink: View {
    
    /// 点击回调
    let onTapped_blisslink: () -> Void
    
    /// 按钮尺寸
    var buttonSize_blisslink: CGFloat = 44
    
    /// 图标大小
    var iconSize_blisslink: CGFloat = 18
    
    /// 是否显示阴影
    var showShadow_blisslink: Bool = true
    
    @State private var isPressed_blisslink: Bool = false
    
    var body: some View {
        Button(action: {
            // 触觉反馈
            let impact_blisslink = UIImpactFeedbackGenerator(style: .light)
            impact_blisslink.impactOccurred()
            
            // 调用回调
            onTapped_blisslink()
        }) {
            ZStack {
                // 外层渐变圆环
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
                    .frame(width: 36, height: 36)
                
                // 内层白色圆形
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                
                // 返回图标
                Image(systemName: "chevron.left")
                    .font(.system(size: iconSize_blisslink, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .frame(width: buttonSize_blisslink, height: buttonSize_blisslink)
            .background(
                Color.white.opacity(0.95)
            )
            .clipShape(Circle())
            .shadow(
                color: showShadow_blisslink ? Color.black.opacity(0.15) : Color.clear,
                radius: showShadow_blisslink ? 8 : 0,
                x: 0,
                y: 3
            )
            .scaleEffect(isPressed_blisslink ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed_blisslink)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed_blisslink = true
                }
                .onEnded { _ in
                    isPressed_blisslink = false
                }
        )
    }
}

// MARK: - 简化版返回按钮

/// 简化版返回按钮
struct SimpleBackButton_blisslink: View {
    
    /// 点击回调
    let onTapped_blisslink: () -> Void
    
    @State private var isPressed_blisslink: Bool = false
    
    var body: some View {
        Button(action: {
            // 触觉反馈
            let impact_blisslink = UIImpactFeedbackGenerator(style: .light)
            impact_blisslink.impactOccurred()
            
            onTapped_blisslink()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("Back")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.95))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(isPressed_blisslink ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed_blisslink)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed_blisslink = true
                }
                .onEnded { _ in
                    isPressed_blisslink = false
                }
        )
    }
}

// MARK: - 自定义样式返回按钮

/// 自定义样式返回按钮
struct CustomBackButton_blisslink: View {
    
    /// 点击回调
    let onTapped_blisslink: () -> Void
    
    /// 图标名称
    var iconName_blisslink: String = "chevron.left"
    
    /// 显示文字
    var title_blisslink: String? = nil
    
    /// 前景色
    var foregroundColor_blisslink: Color = .blue
    
    /// 背景色
    var backgroundColor_blisslink: Color = .white
    
    /// 是否显示边框
    var showBorder_blisslink: Bool = false
    
    @State private var isPressed_blisslink: Bool = false
    
    var body: some View {
        Button(action: {
            // 触觉反馈
            let impact_blisslink = UIImpactFeedbackGenerator(style: .light)
            impact_blisslink.impactOccurred()
            
            onTapped_blisslink()
        }) {
            HStack(spacing: 6) {
                Image(systemName: iconName_blisslink)
                    .font(.system(size: 16, weight: .semibold))
                
                if let title = title_blisslink {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                }
            }
            .foregroundColor(foregroundColor_blisslink)
            .padding(.horizontal, title_blisslink == nil ? 12 : 16)
            .padding(.vertical, 10)
            .background(backgroundColor_blisslink)
            .cornerRadius(22)
            .overlay(
                showBorder_blisslink ? 
                RoundedRectangle(cornerRadius: 22)
                    .stroke(foregroundColor_blisslink.opacity(0.3), lineWidth: 1)
                : nil
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .scaleEffect(isPressed_blisslink ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed_blisslink)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed_blisslink = true
                }
                .onEnded { _ in
                    isPressed_blisslink = false
                }
        )
    }
}

// MARK: - View 扩展

extension View {
    
    /// 添加自定义返回按钮到导航栏
    func customBackButton_blisslink(action_blisslink: @escaping () -> Void) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton_blisslink(onTapped_blisslink: action_blisslink)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    /// 添加简化版返回按钮到导航栏
    func simpleBackButton_blisslink(action_blisslink: @escaping () -> Void) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                SimpleBackButton_blisslink(onTapped_blisslink: action_blisslink)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
