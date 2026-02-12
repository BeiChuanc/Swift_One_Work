import SwiftUI

// MARK: - 视图修饰符集合
// 核心作用：提供梦幻神秘主题的视图样式修饰符
// 设计思路：封装常用的视觉效果，包括毛玻璃卡片、发光边框、渐变文本等
// 关键修饰符：dreamyCard（梦幻卡片）、glowBorder（发光边框）、gradientText（渐变文本）

// MARK: - 梦幻卡片样式

/// 梦幻卡片样式修饰符
/// 提供毛玻璃效果 + 渐变背景 + 柔和阴影的卡片样式
struct DreamyCardModifier_platbell: ViewModifier {
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 圆角半径
    let cornerRadius_platbell: CGFloat
    
    /// 是否显示阴影
    let hasShadow_platbell: Bool
    
    /// 毛玻璃透明度
    let blurOpacity_platbell: Double
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // 渐变背景
                    ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                        .opacity(0.15)
                    
                    // 毛玻璃效果
                    Color.white
                        .opacity(blurOpacity_platbell)
                        .background(.ultraThinMaterial)
                }
            )
            .cornerRadius(cornerRadius_platbell)
            .overlay(
                // 边框高光
                RoundedRectangle(cornerRadius: cornerRadius_platbell)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: hasShadow_platbell ? Color.black.opacity(0.1) : Color.clear,
                radius: 10,
                x: 0,
                y: 5
            )
    }
}

extension View {
    /// 应用梦幻卡片样式
    /// - Parameters:
    ///   - gradientIndex_platbell: 渐变色索引
    ///   - cornerRadius_platbell: 圆角半径
    ///   - hasShadow_platbell: 是否显示阴影
    ///   - blurOpacity_platbell: 毛玻璃透明度
    /// - Returns: 修饰后的视图
    func dreamyCard_platbell(
        gradientIndex_platbell: Int = 0,
        cornerRadius_platbell: CGFloat = 20,
        hasShadow_platbell: Bool = true,
        blurOpacity_platbell: Double = 0.7
    ) -> some View {
        self.modifier(DreamyCardModifier_platbell(
            gradientIndex_platbell: gradientIndex_platbell,
            cornerRadius_platbell: cornerRadius_platbell,
            hasShadow_platbell: hasShadow_platbell,
            blurOpacity_platbell: blurOpacity_platbell
        ))
    }
}

// MARK: - 发光边框样式

/// 发光边框修饰符
/// 为视图添加渐变色发光边框效果
struct GlowBorderModifier_platbell: ViewModifier {
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 圆角半径
    let cornerRadius_platbell: CGFloat
    
    /// 线宽
    let lineWidth_platbell: CGFloat
    
    /// 发光强度
    let glowIntensity_platbell: Double
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius_platbell)
                    .stroke(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell),
                        lineWidth: lineWidth_platbell
                    )
            )
            .shadow(
                color: ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                    .opacity(glowIntensity_platbell),
                radius: 8,
                x: 0,
                y: 0
            )
    }
}

extension View {
    /// 应用发光边框样式
    /// - Parameters:
    ///   - gradientIndex_platbell: 渐变色索引
    ///   - cornerRadius_platbell: 圆角半径
    ///   - lineWidth_platbell: 线宽
    ///   - glowIntensity_platbell: 发光强度
    /// - Returns: 修饰后的视图
    func glowBorder_platbell(
        gradientIndex_platbell: Int = 0,
        cornerRadius_platbell: CGFloat = 20,
        lineWidth_platbell: CGFloat = 2,
        glowIntensity_platbell: Double = 0.3
    ) -> some View {
        self.modifier(GlowBorderModifier_platbell(
            gradientIndex_platbell: gradientIndex_platbell,
            cornerRadius_platbell: cornerRadius_platbell,
            lineWidth_platbell: lineWidth_platbell,
            glowIntensity_platbell: glowIntensity_platbell
        ))
    }
}

// MARK: - 渐变文本样式

/// 渐变文本修饰符
/// 为文本添加渐变色效果
struct GradientTextModifier_platbell: ViewModifier {
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(
                ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
            )
    }
}

extension View {
    /// 应用渐变文本样式
    /// - Parameter gradientIndex_platbell: 渐变色索引
    /// - Returns: 修饰后的视图
    func gradientText_platbell(gradientIndex_platbell: Int = 0) -> some View {
        self.modifier(GradientTextModifier_platbell(gradientIndex_platbell: gradientIndex_platbell))
    }
}

// MARK: - 渐变背景样式

/// 渐变背景修饰符
/// 为视图添加渐变色背景
struct GradientBackgroundModifier_platbell: ViewModifier {
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 不透明度
    let opacity_platbell: Double
    
    func body(content: Content) -> some View {
        content
            .background(
                ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                    .opacity(opacity_platbell)
            )
    }
}

extension View {
    /// 应用渐变背景样式
    /// - Parameters:
    ///   - gradientIndex_platbell: 渐变色索引
    ///   - opacity_platbell: 不透明度
    /// - Returns: 修饰后的视图
    func gradientBackground_platbell(
        gradientIndex_platbell: Int = 0,
        opacity_platbell: Double = 1.0
    ) -> some View {
        self.modifier(GradientBackgroundModifier_platbell(
            gradientIndex_platbell: gradientIndex_platbell,
            opacity_platbell: opacity_platbell
        ))
    }
}

// MARK: - 自定义按钮样式

/// 梦幻按钮样式
/// 提供渐变色背景的按钮样式
struct DreamyButtonStyle_platbell: ButtonStyle {
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 圆角半径
    let cornerRadius_platbell: CGFloat
    
    /// 是否紧凑模式
    let isCompact_platbell: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: isCompact_platbell ? 14 : 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, isCompact_platbell ? 16 : 24)
            .padding(.vertical, isCompact_platbell ? 8 : 12)
            .background(
                ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
            .cornerRadius(cornerRadius_platbell)
            .shadow(
                color: ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                    .opacity(0.3),
                radius: configuration.isPressed ? 5 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 5
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension View {
    /// 应用梦幻按钮样式
    /// - Parameters:
    ///   - gradientIndex_platbell: 渐变色索引
    ///   - cornerRadius_platbell: 圆角半径
    ///   - isCompact_platbell: 是否紧凑模式
    /// - Returns: 修饰后的视图
    func dreamyButtonStyle_platbell(
        gradientIndex_platbell: Int = 0,
        cornerRadius_platbell: CGFloat = 25,
        isCompact_platbell: Bool = false
    ) -> some View {
        self.buttonStyle(DreamyButtonStyle_platbell(
            gradientIndex_platbell: gradientIndex_platbell,
            cornerRadius_platbell: cornerRadius_platbell,
            isCompact_platbell: isCompact_platbell
        ))
    }
}

// MARK: - 卡片出现动画修饰符

/// 卡片出现动画修饰符
/// 为视图添加从下方滑入并渐显的动画效果
struct CardAppearModifier_platbell: ViewModifier {
    
    /// 是否已显示
    let isVisible_platbell: Bool
    
    /// 延迟时间
    let delay_platbell: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible_platbell ? 1 : 0)
            .offset(y: isVisible_platbell ? 0 : 30)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(delay_platbell),
                value: isVisible_platbell
            )
    }
}

extension View {
    /// 应用卡片出现动画
    /// - Parameters:
    ///   - isVisible_platbell: 是否已显示
    ///   - delay_platbell: 延迟时间
    /// - Returns: 修饰后的视图
    func cardAppear_platbell(
        isVisible_platbell: Bool,
        delay_platbell: Double = 0
    ) -> some View {
        self.modifier(CardAppearModifier_platbell(
            isVisible_platbell: isVisible_platbell,
            delay_platbell: delay_platbell
        ))
    }
}

// MARK: - 轻微3D倾斜效果

/// 3D倾斜效果修饰符
/// 为视图添加轻微的3D旋转效果
struct Tilt3DModifier_platbell: ViewModifier {
    
    /// X轴旋转角度
    let rotationX_platbell: Double
    
    /// Y轴旋转角度
    let rotationY_platbell: Double
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(rotationX_platbell),
                axis: (x: 1, y: 0, z: 0)
            )
            .rotation3DEffect(
                .degrees(rotationY_platbell),
                axis: (x: 0, y: 1, z: 0)
            )
    }
}

extension View {
    /// 应用3D倾斜效果
    /// - Parameters:
    ///   - rotationX_platbell: X轴旋转角度
    ///   - rotationY_platbell: Y轴旋转角度
    /// - Returns: 修饰后的视图
    func tilt3D_platbell(
        rotationX_platbell: Double = 0,
        rotationY_platbell: Double = 0
    ) -> some View {
        self.modifier(Tilt3DModifier_platbell(
            rotationX_platbell: rotationX_platbell,
            rotationY_platbell: rotationY_platbell
        ))
    }
}

// MARK: - 毛玻璃圆形容器

/// 毛玻璃圆形容器
/// 用于头像等圆形元素的展示
struct GlassCircleContainer_platbell: View {
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 尺寸
    let size_platbell: CGFloat
    
    /// 线宽
    let lineWidth_platbell: CGFloat
    
    /// 内容视图
    let content_platbell: AnyView
    
    var body: some View {
        ZStack {
            // 背景圆形
            Circle()
                .fill(
                    ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                        .opacity(0.2)
                )
                .background(.ultraThinMaterial)
            
            // 内容
            content_platbell
                .clipShape(Circle())
            
            // 边框
            Circle()
                .stroke(
                    ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell),
                    lineWidth: lineWidth_platbell
                )
        }
        .frame(width: size_platbell, height: size_platbell)
        .shadow(
            color: ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                .opacity(0.3),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

extension View {
    /// 包装为毛玻璃圆形容器
    /// - Parameters:
    ///   - gradientIndex_platbell: 渐变色索引
    ///   - size_platbell: 尺寸
    ///   - lineWidth_platbell: 线宽
    /// - Returns: 圆形容器视图
    func glassCircle_platbell(
        gradientIndex_platbell: Int = 0,
        size_platbell: CGFloat = 60,
        lineWidth_platbell: CGFloat = 2
    ) -> some View {
        GlassCircleContainer_platbell(
            gradientIndex_platbell: gradientIndex_platbell,
            size_platbell: size_platbell,
            lineWidth_platbell: lineWidth_platbell,
            content_platbell: AnyView(self)
        )
    }
}

// MARK: - 标签胶囊样式

/// 标签胶囊样式修饰符
/// 为标签提供胶囊形状的渐变背景
struct TagCapsuleModifier_platbell: ViewModifier {
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 是否选中
    let isSelected_platbell: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected_platbell ? .white : ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count])
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        isSelected_platbell
                            ? ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                            : LinearGradient(
                                colors: [Color.white.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell),
                        lineWidth: isSelected_platbell ? 0 : 1.5
                    )
            )
            .shadow(
                color: isSelected_platbell
                    ? ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.4)
                    : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
    }
}

extension View {
    /// 应用标签胶囊样式
    /// - Parameters:
    ///   - gradientIndex_platbell: 渐变色索引
    ///   - isSelected_platbell: 是否选中
    /// - Returns: 修饰后的视图
    func tagCapsule_platbell(
        gradientIndex_platbell: Int = 0,
        isSelected_platbell: Bool = false
    ) -> some View {
        self.modifier(TagCapsuleModifier_platbell(
            gradientIndex_platbell: gradientIndex_platbell,
            isSelected_platbell: isSelected_platbell
        ))
    }
}
