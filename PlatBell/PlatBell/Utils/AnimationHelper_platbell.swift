import SwiftUI

// MARK: - 动画工具类
// 核心作用：提供各种动画效果的封装和工具方法
// 设计思路：封装常用的动画类型，包括心跳、弹簧、渐变流动等
// 关键方法：heartBeat（心跳动画）、spring（弹簧动画）、gradientFlow（渐变流动）

// MARK: - 动画预设常量

/// 动画预设常量
enum AnimationPresets_platbell {
    
    /// 快速弹簧动画
    static let quickSpring_platbell = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    /// 标准弹簧动画
    static let standardSpring_platbell = Animation.spring(response: 0.5, dampingFraction: 0.8)
    
    /// 柔和弹簧动画
    static let gentleSpring_platbell = Animation.spring(response: 0.7, dampingFraction: 0.9)
    
    /// 快速缓动动画
    static let quickEase_platbell = Animation.easeInOut(duration: 0.2)
    
    /// 标准缓动动画
    static let standardEase_platbell = Animation.easeInOut(duration: 0.3)
    
    /// 柔和缓动动画
    static let gentleEase_platbell = Animation.easeInOut(duration: 0.5)
    
    /// 线性动画
    static let linear_platbell = Animation.linear(duration: 0.3)
}

// MARK: - 心跳动画

/// 心跳动画状态
struct HeartBeatAnimation_platbell: ViewModifier {
    
    /// 是否触发动画
    @Binding var isAnimating_platbell: Bool
    
    /// 缩放比例
    @State private var scale_platbell: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale_platbell)
            .onChange(of: isAnimating_platbell) { newValue_platbell in
                if newValue_platbell {
                    performHeartBeat_platbell()
                }
            }
    }
    
    /// 执行心跳动画
    private func performHeartBeat_platbell() {
        // 第一次放大
        withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
            scale_platbell = 1.3
        }
        
        // 回弹
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
                scale_platbell = 0.9
            }
        }
        
        // 恢复
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
                scale_platbell = 1.0
                isAnimating_platbell = false
            }
        }
    }
}

extension View {
    /// 应用心跳动画
    /// - Parameter isAnimating_platbell: 是否触发动画
    /// - Returns: 修饰后的视图
    func heartBeat_platbell(isAnimating_platbell: Binding<Bool>) -> some View {
        self.modifier(HeartBeatAnimation_platbell(isAnimating_platbell: isAnimating_platbell))
    }
}

// MARK: - 持续心跳动画

/// 持续心跳动画修饰符
/// 用于实现持续的心跳效果
struct ContinuousHeartBeatModifier_platbell: ViewModifier {
    
    /// 动画状态
    @State private var isAnimating_platbell = false
    
    /// 是否启用
    let isEnabled_platbell: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating_platbell ? 1.1 : 1.0)
            .animation(
                isEnabled_platbell
                    ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                    : .default,
                value: isAnimating_platbell
            )
            .onAppear {
                if isEnabled_platbell {
                    isAnimating_platbell = true
                }
            }
            .onChange(of: isEnabled_platbell) { newValue_platbell in
                isAnimating_platbell = newValue_platbell
            }
    }
}

extension View {
    /// 应用持续心跳动画
    /// - Parameter isEnabled_platbell: 是否启用
    /// - Returns: 修饰后的视图
    func continuousHeartBeat_platbell(isEnabled_platbell: Bool = true) -> some View {
        self.modifier(ContinuousHeartBeatModifier_platbell(isEnabled_platbell: isEnabled_platbell))
    }
}

// MARK: - 渐变流动动画

/// 渐变流动动画修饰符
/// 实现渐变色的流动效果
struct GradientFlowModifier_platbell: ViewModifier {
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 动画状态
    @State private var animationPhase_platbell: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count],
                        ThemeColors_platbell.allEndColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allEndColors_platbell.count],
                        ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .hueRotation(.degrees(animationPhase_platbell))
                .onAppear {
                    withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                        animationPhase_platbell = 360
                    }
                }
            )
    }
}

extension View {
    /// 应用渐变流动动画
    /// - Parameter gradientIndex_platbell: 渐变色索引
    /// - Returns: 修饰后的视图
    func gradientFlow_platbell(gradientIndex_platbell: Int = 0) -> some View {
        self.modifier(GradientFlowModifier_platbell(gradientIndex_platbell: gradientIndex_platbell))
    }
}

// MARK: - 旋转动画

/// 持续旋转动画修饰符
struct ContinuousRotationModifier_platbell: ViewModifier {
    
    /// 旋转角度
    @State private var rotation_platbell: Double = 0
    
    /// 动画时长
    let duration_platbell: Double
    
    /// 是否启用
    let isEnabled_platbell: Bool
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation_platbell))
            .onAppear {
                if isEnabled_platbell {
                    withAnimation(Animation.linear(duration: duration_platbell).repeatForever(autoreverses: false)) {
                        rotation_platbell = 360
                    }
                }
            }
            .onChange(of: isEnabled_platbell) { newValue_platbell in
                if newValue_platbell {
                    withAnimation(Animation.linear(duration: duration_platbell).repeatForever(autoreverses: false)) {
                        rotation_platbell = 360
                    }
                } else {
                    rotation_platbell = 0
                }
            }
    }
}

extension View {
    /// 应用持续旋转动画
    /// - Parameters:
    ///   - duration_platbell: 动画时长
    ///   - isEnabled_platbell: 是否启用
    /// - Returns: 修饰后的视图
    func continuousRotation_platbell(
        duration_platbell: Double = 2.0,
        isEnabled_platbell: Bool = true
    ) -> some View {
        self.modifier(ContinuousRotationModifier_platbell(
            duration_platbell: duration_platbell,
            isEnabled_platbell: isEnabled_platbell
        ))
    }
}

// MARK: - 闪烁动画

/// 闪烁动画修饰符
struct BlinkModifier_platbell: ViewModifier {
    
    /// 不透明度
    @State private var opacity_platbell: Double = 1.0
    
    /// 是否启用
    let isEnabled_platbell: Bool
    
    /// 动画时长
    let duration_platbell: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity_platbell)
            .onAppear {
                if isEnabled_platbell {
                    withAnimation(Animation.easeInOut(duration: duration_platbell).repeatForever(autoreverses: true)) {
                        opacity_platbell = 0.3
                    }
                }
            }
            .onChange(of: isEnabled_platbell) { newValue_platbell in
                if newValue_platbell {
                    withAnimation(Animation.easeInOut(duration: duration_platbell).repeatForever(autoreverses: true)) {
                        opacity_platbell = 0.3
                    }
                } else {
                    opacity_platbell = 1.0
                }
            }
    }
}

extension View {
    /// 应用闪烁动画
    /// - Parameters:
    ///   - isEnabled_platbell: 是否启用
    ///   - duration_platbell: 动画时长
    /// - Returns: 修饰后的视图
    func blink_platbell(
        isEnabled_platbell: Bool = true,
        duration_platbell: Double = 0.8
    ) -> some View {
        self.modifier(BlinkModifier_platbell(
            isEnabled_platbell: isEnabled_platbell,
            duration_platbell: duration_platbell
        ))
    }
}

// MARK: - 弹跳动画

/// 弹跳动画修饰符
struct BounceModifier_platbell: ViewModifier {
    
    /// 是否触发动画
    @Binding var isAnimating_platbell: Bool
    
    /// Y轴偏移
    @State private var offsetY_platbell: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offsetY_platbell)
            .onChange(of: isAnimating_platbell) { newValue_platbell in
                if newValue_platbell {
                    performBounce_platbell()
                }
            }
    }
    
    /// 执行弹跳动画
    private func performBounce_platbell() {
        // 向上跳
        withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
            offsetY_platbell = -20
        }
        
        // 落下
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(AnimationPresets_platbell.standardSpring_platbell) {
                offsetY_platbell = 0
                isAnimating_platbell = false
            }
        }
    }
}

extension View {
    /// 应用弹跳动画
    /// - Parameter isAnimating_platbell: 是否触发动画
    /// - Returns: 修饰后的视图
    func bounce_platbell(isAnimating_platbell: Binding<Bool>) -> some View {
        self.modifier(BounceModifier_platbell(isAnimating_platbell: isAnimating_platbell))
    }
}

// MARK: - 摇晃动画

/// 摇晃动画修饰符
struct ShakeModifier_platbell: ViewModifier {
    
    /// 是否触发动画
    @Binding var isAnimating_platbell: Bool
    
    /// 旋转角度
    @State private var rotation_platbell: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation_platbell))
            .onChange(of: isAnimating_platbell) { newValue_platbell in
                if newValue_platbell {
                    performShake_platbell()
                }
            }
    }
    
    /// 执行摇晃动画
    private func performShake_platbell() {
        let shakeSequence_platbell: [Double] = [0, -5, 5, -5, 5, -3, 3, 0]
        
        for (index_platbell, angle_platbell) in shakeSequence_platbell.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index_platbell) * 0.05) {
                withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
                    rotation_platbell = angle_platbell
                }
                
                if index_platbell == shakeSequence_platbell.count - 1 {
                    isAnimating_platbell = false
                }
            }
        }
    }
}

extension View {
    /// 应用摇晃动画
    /// - Parameter isAnimating_platbell: 是否触发动画
    /// - Returns: 修饰后的视图
    func shake_platbell(isAnimating_platbell: Binding<Bool>) -> some View {
        self.modifier(ShakeModifier_platbell(isAnimating_platbell: isAnimating_platbell))
    }
}

// MARK: - 波浪效果

/// 波浪效果修饰符
/// 用于加载动画等场景
struct WaveModifier_platbell: ViewModifier {
    
    /// 动画阶段
    @State private var phase_platbell: CGFloat = 0
    
    /// 延迟时间
    let delay_platbell: Double
    
    /// 是否启用
    let isEnabled_platbell: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(y: sin(phase_platbell) * 5)
            .onAppear {
                if isEnabled_platbell {
                    withAnimation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: false)
                            .delay(delay_platbell)
                    ) {
                        phase_platbell = .pi * 2
                    }
                }
            }
            .onChange(of: isEnabled_platbell) { newValue_platbell in
                if !newValue_platbell {
                    phase_platbell = 0
                }
            }
    }
}

extension View {
    /// 应用波浪效果
    /// - Parameters:
    ///   - delay_platbell: 延迟时间
    ///   - isEnabled_platbell: 是否启用
    /// - Returns: 修饰后的视图
    func wave_platbell(
        delay_platbell: Double = 0,
        isEnabled_platbell: Bool = true
    ) -> some View {
        self.modifier(WaveModifier_platbell(
            delay_platbell: delay_platbell,
            isEnabled_platbell: isEnabled_platbell
        ))
    }
}

// MARK: - 呼吸效果

/// 呼吸效果修饰符
/// 缓慢的放大缩小动画
struct BreathingModifier_platbell: ViewModifier {
    
    /// 缩放比例
    @State private var scale_platbell: CGFloat = 1.0
    
    /// 是否启用
    let isEnabled_platbell: Bool
    
    /// 动画时长
    let duration_platbell: Double
    
    /// 缩放范围
    let scaleRange_platbell: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale_platbell)
            .onAppear {
                if isEnabled_platbell {
                    withAnimation(
                        Animation.easeInOut(duration: duration_platbell)
                            .repeatForever(autoreverses: true)
                    ) {
                        scale_platbell = 1.0 + scaleRange_platbell
                    }
                }
            }
            .onChange(of: isEnabled_platbell) { newValue_platbell in
                if newValue_platbell {
                    withAnimation(
                        Animation.easeInOut(duration: duration_platbell)
                            .repeatForever(autoreverses: true)
                    ) {
                        scale_platbell = 1.0 + scaleRange_platbell
                    }
                } else {
                    scale_platbell = 1.0
                }
            }
    }
}

extension View {
    /// 应用呼吸效果
    /// - Parameters:
    ///   - isEnabled_platbell: 是否启用
    ///   - duration_platbell: 动画时长
    ///   - scaleRange_platbell: 缩放范围
    /// - Returns: 修饰后的视图
    func breathing_platbell(
        isEnabled_platbell: Bool = true,
        duration_platbell: Double = 2.0,
        scaleRange_platbell: CGFloat = 0.1
    ) -> some View {
        self.modifier(BreathingModifier_platbell(
            isEnabled_platbell: isEnabled_platbell,
            duration_platbell: duration_platbell,
            scaleRange_platbell: scaleRange_platbell
        ))
    }
}

// MARK: - 爆炸效果（用于双击点赞）

/// 爆炸粒子视图
struct ExplosionParticle_platbell: View {
    
    /// 角度
    let angle_platbell: Double
    
    /// 是否显示
    @Binding var isVisible_platbell: Bool
    
    /// 偏移距离
    @State private var offset_platbell: CGFloat = 0
    
    /// 不透明度
    @State private var opacity_platbell: Double = 1.0
    
    /// 缩放
    @State private var scale_platbell: CGFloat = 0.5
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 20))
            .foregroundColor(ThemeColors_platbell.secondaryStart_platbell)
            .opacity(opacity_platbell)
            .scaleEffect(scale_platbell)
            .offset(
                x: cos(angle_platbell * .pi / 180) * offset_platbell,
                y: sin(angle_platbell * .pi / 180) * offset_platbell
            )
            .onChange(of: isVisible_platbell) { newValue_platbell in
                if newValue_platbell {
                    performAnimation_platbell()
                }
            }
    }
    
    /// 执行动画
    private func performAnimation_platbell() {
        withAnimation(.easeOut(duration: 0.5)) {
            offset_platbell = 50
            opacity_platbell = 0
            scale_platbell = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            offset_platbell = 0
            opacity_platbell = 1.0
            scale_platbell = 0.5
        }
    }
}

/// 爆炸效果修饰符
struct ExplosionModifier_platbell: ViewModifier {
    
    /// 是否触发爆炸
    @Binding var isExploding_platbell: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isExploding_platbell {
                ForEach(0..<8, id: \.self) { index_platbell in
                    ExplosionParticle_platbell(
                        angle_platbell: Double(index_platbell) * 45,
                        isVisible_platbell: $isExploding_platbell
                    )
                }
            }
        }
        .onChange(of: isExploding_platbell) { newValue_platbell in
            if newValue_platbell {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isExploding_platbell = false
                }
            }
        }
    }
}

extension View {
    /// 应用爆炸效果
    /// - Parameter isExploding_platbell: 是否触发爆炸
    /// - Returns: 修饰后的视图
    func explosion_platbell(isExploding_platbell: Binding<Bool>) -> some View {
        self.modifier(ExplosionModifier_platbell(isExploding_platbell: isExploding_platbell))
    }
}
