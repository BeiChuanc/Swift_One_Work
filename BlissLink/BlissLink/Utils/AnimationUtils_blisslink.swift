import SwiftUI

// MARK: - 动画工具类
// 核心作用：提供统一的动画配置和高级动画效果
// 设计思路：集中管理动画参数，确保全局动画风格一致
// 关键方法：预设动画曲线、视差效果、序列动画

/// 动画配置工具
struct AnimationConfig_blisslink {
    
    // MARK: - 标准动画曲线
    
    /// 快速响应动画（按钮点击等）
    static let quick_blisslink = Animation.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0)
    
    /// 标准流畅动画（卡片展开、Tab切换等）
    static let smooth_blisslink = Animation.spring(response: 0.45, dampingFraction: 0.85, blendDuration: 0)
    
    /// 柔和缓慢动画（背景变化、渐变等）
    static let gentle_blisslink = Animation.spring(response: 0.6, dampingFraction: 0.9, blendDuration: 0)
    
    /// 弹性动画（点赞、收藏等）
    static let bouncy_blisslink = Animation.interpolatingSpring(stiffness: 300, damping: 15)
    
    /// 线性动画（进度条等）
    static let linear_blisslink = Animation.linear(duration: 1.0)
    
    /// 淡入淡出动画
    static let fade_blisslink = Animation.easeInOut(duration: 0.3)
    
    // MARK: - 缓动函数
    
    /// 缓入缓出
    static func easeInOut_blisslink(duration_blisslink: Double) -> Animation {
        return .easeInOut(duration: duration_blisslink)
    }
    
    /// 缓入
    static func easeIn_blisslink(duration_blisslink: Double) -> Animation {
        return .easeIn(duration: duration_blisslink)
    }
    
    /// 缓出
    static func easeOut_blisslink(duration_blisslink: Double) -> Animation {
        return .easeOut(duration: duration_blisslink)
    }
}

// MARK: - 视图修饰符扩展

extension View {
    
    /// 添加弹跳进入动画
    /// - Parameter delay_blisslink: 延迟时间
    func bounceIn_blisslink(delay_blisslink: Double = 0) -> some View {
        self.modifier(BounceInModifier_blisslink(delay_blisslink: delay_blisslink))
    }
    
    /// 添加滑入动画
    /// - Parameters:
    ///   - edge_blisslink: 滑入边缘
    ///   - delay_blisslink: 延迟时间
    func slideIn_blisslink(from edge_blisslink: Edge = .bottom, delay_blisslink: Double = 0) -> some View {
        self.modifier(SlideInModifier_blisslink(edge_blisslink: edge_blisslink, delay_blisslink: delay_blisslink))
    }
    
    /// 添加视差滚动效果
    /// - Parameter magnitude_blisslink: 视差强度
    func parallaxEffect_blisslink(magnitude_blisslink: CGFloat = 20) -> some View {
        self.modifier(ParallaxModifier_blisslink(magnitude_blisslink: magnitude_blisslink))
    }
    
    /// 添加浮动动画（上下浮动）
    func floatingAnimation_blisslink() -> some View {
        self.modifier(FloatingModifier_blisslink())
    }
}

// MARK: - 弹跳进入修饰符

/// 弹跳进入动画修饰符
struct BounceInModifier_blisslink: ViewModifier {
    
    let delay_blisslink: Double
    
    @State private var scale_blisslink: CGFloat = 0.5
    @State private var opacity_blisslink: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale_blisslink)
            .opacity(opacity_blisslink)
            .onAppear {
                withAnimation(
                    AnimationConfig_blisslink.bouncy_blisslink
                        .delay(delay_blisslink)
                ) {
                    scale_blisslink = 1.0
                    opacity_blisslink = 1.0
                }
            }
    }
}

// MARK: - 滑入修饰符

/// 滑入动画修饰符
struct SlideInModifier_blisslink: ViewModifier {
    
    let edge_blisslink: Edge
    let delay_blisslink: Double
    
    @State private var offset_blisslink: CGFloat = 50
    @State private var opacity_blisslink: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: edge_blisslink == .bottom ? offset_blisslink : -offset_blisslink)
            .opacity(opacity_blisslink)
            .onAppear {
                withAnimation(
                    AnimationConfig_blisslink.smooth_blisslink
                        .delay(delay_blisslink)
                ) {
                    offset_blisslink = 0
                    opacity_blisslink = 1.0
                }
            }
    }
}

// MARK: - 视差修饰符

/// 视差效果修饰符
struct ParallaxModifier_blisslink: ViewModifier {
    
    let magnitude_blisslink: CGFloat
    
    func body(content: Content) -> some View {
        GeometryReader { geometry_blisslink in
            content
                .offset(y: parallaxOffset_blisslink(geometry_blisslink))
        }
    }
    
    /// 计算视差偏移量
    private func parallaxOffset_blisslink(_ geometry_blisslink: GeometryProxy) -> CGFloat {
        let frame_blisslink = geometry_blisslink.frame(in: .global)
        let screenHeight_blisslink = UIScreen.main.bounds.height
        let midY_blisslink = frame_blisslink.midY
        let offset_blisslink = (midY_blisslink - screenHeight_blisslink / 2) / screenHeight_blisslink
        return offset_blisslink * magnitude_blisslink
    }
}

// MARK: - 浮动修饰符

/// 浮动动画修饰符
struct FloatingModifier_blisslink: ViewModifier {
    
    @State private var offset_blisslink: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset_blisslink)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true)
                ) {
                    offset_blisslink = -10
                }
            }
    }
}

// MARK: - 脉冲动画修饰符

extension View {
    
    /// 添加脉冲动画（用于强调元素）
    func pulseAnimation_blisslink() -> some View {
        self.modifier(PulseModifier_blisslink())
    }
}

/// 脉冲动画修饰符
struct PulseModifier_blisslink: ViewModifier {
    
    @State private var scale_blisslink: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale_blisslink)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    scale_blisslink = 1.08
                }
            }
    }
}

// MARK: - 闪烁动画修饰符

extension View {
    
    /// 添加闪烁动画
    func shimmerAnimation_blisslink() -> some View {
        self.modifier(ShimmerModifier_blisslink())
    }
}

/// 闪烁动画修饰符
struct ShimmerModifier_blisslink: ViewModifier {
    
    @State private var opacity_blisslink: Double = 0.3
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity_blisslink)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
                ) {
                    opacity_blisslink = 1.0
                }
            }
    }
}
