import Foundation
import UIKit

// MARK: 动画配置

/// 动画配置类
/// 功能：集中管理应用的动画参数、时长和缓动曲线
/// 设计理念：流畅弹性、温暖细腻、富有生命力
struct AnimationConfig_Hush {
    
    // MARK: - 动画时长
    
    /// 快速动画（如按钮点击反馈）
    static let durationFast_Hush: TimeInterval = 0.2
    
    /// 标准动画（如视图切换）
    static let durationNormal_Hush: TimeInterval = 0.3
    
    /// 慢速动画（如页面转场）
    static let durationSlow_Hush: TimeInterval = 0.5
    
    /// 弹性动画（如弹出视图）
    static let durationSpring_Hush: TimeInterval = 0.6
    
    // MARK: - 弹性动画参数
    
    /// 轻微弹性（适用于按钮、小元素）
    static let springDampingLight_Hush: CGFloat = 0.8
    
    /// 标准弹性（适用于卡片、面板）
    static let springDampingNormal_Hush: CGFloat = 0.7
    
    /// 强烈弹性（适用于大型弹出视图）
    static let springDampingHeavy_Hush: CGFloat = 0.6
    
    /// 初始速度
    static let springVelocity_Hush: CGFloat = 0.5
    
    // MARK: - 缩放参数
    
    /// 按压缩小比例
    static let scalePressDown_Hush: CGFloat = 0.95
    
    /// 弹出放大比例
    static let scalePopUp_Hush: CGFloat = 1.1
    
    /// 正常比例
    static let scaleNormal_Hush: CGFloat = 1.0
    
    // MARK: - 透明度
    
    /// 完全不透明
    static let alphaVisible_Hush: CGFloat = 1.0
    
    /// 半透明（背景遮罩）
    static let alphaOverlay_Hush: CGFloat = 0.5
    
    /// 不可见
    static let alphaHidden_Hush: CGFloat = 0.0
    
    // MARK: - 延迟参数
    
    /// 短延迟（用于级联动画）
    static let delayShort_Hush: TimeInterval = 0.05
    
    /// 中等延迟
    static let delayMedium_Hush: TimeInterval = 0.1
    
    /// 长延迟
    static let delayLong_Hush: TimeInterval = 0.2
}

// MARK: - UIView动画扩展

extension UIView {
    
    /// 弹性缩放动画（从小到大）
    /// 功能：视图从0.8缩放到1.0，带弹性效果
    /// 参数：
    /// - delay_Hush: 延迟时间
    /// - completion_Hush: 完成回调
    func animateSpringScaleIn_Hush(delay_Hush: TimeInterval = 0, completion_Hush: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Hush.durationSpring_Hush,
            delay: delay_Hush,
            usingSpringWithDamping: AnimationConfig_Hush.springDampingNormal_Hush,
            initialSpringVelocity: AnimationConfig_Hush.springVelocity_Hush,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Hush?()
            }
        )
    }
    
    /// 按压动画（缩小）
    /// 功能：视图缩小到0.95，模拟按压效果
    /// 参数：
    /// - completion_Hush: 完成回调
    func animatePressDown_Hush(completion_Hush: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Hush.durationFast_Hush,
            animations: {
                self.transform = CGAffineTransform(scaleX: AnimationConfig_Hush.scalePressDown_Hush, 
                                                   y: AnimationConfig_Hush.scalePressDown_Hush)
            },
            completion: { _ in
                completion_Hush?()
            }
        )
    }
    
    /// 释放动画（恢复）
    /// 功能：视图恢复到原始大小
    /// 参数：
    /// - completion_Hush: 完成回调
    func animatePressUp_Hush(completion_Hush: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Hush.durationFast_Hush,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Hush.springDampingLight_Hush,
            initialSpringVelocity: AnimationConfig_Hush.springVelocity_Hush,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
            },
            completion: { _ in
                completion_Hush?()
            }
        )
    }
    
    /// 脉冲动画
    /// 功能：视图快速放大再缩小，产生脉冲效果
    /// 参数：
    /// - completion_Hush: 完成回调
    func animatePulse_Hush(completion_Hush: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Hush.durationFast_Hush,
            animations: {
                self.transform = CGAffineTransform(scaleX: AnimationConfig_Hush.scalePopUp_Hush, 
                                                   y: AnimationConfig_Hush.scalePopUp_Hush)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: AnimationConfig_Hush.durationFast_Hush,
                    animations: {
                        self.transform = .identity
                    },
                    completion: { _ in
                        completion_Hush?()
                    }
                )
            }
        )
    }
    
    /// 从下方滑入动画
    /// 功能：视图从底部滑入，带弹性效果
    /// 参数：
    /// - offset_Hush: 偏移距离
    /// - delay_Hush: 延迟时间
    /// - completion_Hush: 完成回调
    func animateSlideInFromBottom_Hush(offset_Hush: CGFloat = 50, delay_Hush: TimeInterval = 0, completion_Hush: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(translationX: 0, y: offset_Hush)
        self.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Hush.durationSpring_Hush,
            delay: delay_Hush,
            usingSpringWithDamping: AnimationConfig_Hush.springDampingNormal_Hush,
            initialSpringVelocity: AnimationConfig_Hush.springVelocity_Hush,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Hush?()
            }
        )
    }
    
    /// 淡入动画
    /// 功能：视图从透明到不透明
    /// 参数：
    /// - duration_Hush: 动画时长
    /// - delay_Hush: 延迟时间
    /// - completion_Hush: 完成回调
    func animateFadeIn_Hush(duration_Hush: TimeInterval? = nil, delay_Hush: TimeInterval = 0, completion_Hush: (() -> Void)? = nil) {
        self.alpha = 0
        
        UIView.animate(
            withDuration: duration_Hush ?? AnimationConfig_Hush.durationNormal_Hush,
            delay: delay_Hush,
            options: [.curveEaseOut],
            animations: {
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Hush?()
            }
        )
    }
    
    /// 淡出动画
    /// 功能：视图从不透明到透明
    /// 参数：
    /// - duration_Hush: 动画时长
    /// - delay_Hush: 延迟时间
    /// - completion_Hush: 完成回调
    func animateFadeOut_Hush(duration_Hush: TimeInterval? = nil, delay_Hush: TimeInterval = 0, completion_Hush: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration_Hush ?? AnimationConfig_Hush.durationNormal_Hush,
            delay: delay_Hush,
            options: [.curveEaseIn],
            animations: {
                self.alpha = 0
            },
            completion: { _ in
                completion_Hush?()
            }
        )
    }
    
    /// 旋转动画
    /// 功能：视图旋转指定角度
    /// 参数：
    /// - angle_Hush: 旋转角度（弧度）
    /// - duration_Hush: 动画时长
    /// - completion_Hush: 完成回调
    func animateRotate_Hush(angle_Hush: CGFloat, duration_Hush: TimeInterval? = nil, completion_Hush: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration_Hush ?? AnimationConfig_Hush.durationNormal_Hush,
            animations: {
                self.transform = CGAffineTransform(rotationAngle: angle_Hush)
            },
            completion: { _ in
                completion_Hush?()
            }
        )
    }
    
    /// 震动动画
    /// 功能：视图左右震动
    func animateShake_Hush() {
        let animation_Hush = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation_Hush.timingFunction = CAMediaTimingFunction(name: .linear)
        animation_Hush.duration = 0.6
        animation_Hush.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
        self.layer.add(animation_Hush, forKey: "shake")
    }
    
    /// 弹性缩放点击反馈动画（按压缩小再弹回）
    /// 功能：组合 press down + press up 提供交互反馈
    func springScaleAnimate_Hush() {
        UIView.animate(
            withDuration: AnimationConfig_Hush.durationFast_Hush,
            animations: {
                self.transform = CGAffineTransform(
                    scaleX: AnimationConfig_Hush.scalePressDown_Hush,
                    y: AnimationConfig_Hush.scalePressDown_Hush
                )
            },
            completion: { _ in
                UIView.animate(
                    withDuration: AnimationConfig_Hush.durationFast_Hush,
                    delay: 0,
                    usingSpringWithDamping: AnimationConfig_Hush.springDampingLight_Hush,
                    initialSpringVelocity: AnimationConfig_Hush.springVelocity_Hush,
                    options: [.curveEaseOut],
                    animations: { self.transform = .identity }
                )
            }
        )
    }
    
    /// 从指定方向滑入动画（带弹性）
    /// 功能：视图从右侧滑入并淡入，用于卡片依次出现场景
    /// - Parameter direction_Hush: 入场方向（.left 从左，.right 从右）
    func slideInAnimate_Hush(direction_Hush: UIRectEdge = .right) {
        let offsetX_hush: CGFloat = direction_Hush == .left ? -40 : 40
        self.transform = CGAffineTransform(translationX: offsetX_hush, y: 0)
        self.alpha = 0
        UIView.animate(
            withDuration: AnimationConfig_Hush.durationSpring_Hush,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Hush.springDampingNormal_Hush,
            initialSpringVelocity: AnimationConfig_Hush.springVelocity_Hush,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1
            }
        )
    }
}

// MARK: - CALayer动画扩展

extension CALayer {
    
    /// 添加光晕效果
    /// 功能：为图层添加发光阴影
    /// 参数：
    /// - color_Hush: 光晕颜色
    /// - radius_Hush: 光晕半径
    func addGlowEffect_Hush(color_Hush: UIColor, radius_Hush: CGFloat = 10) {
        self.shadowColor = color_Hush.cgColor
        self.shadowOffset = .zero
        self.shadowRadius = radius_Hush
        self.shadowOpacity = 0.6
    }
    
    /// 移除光晕效果
    func removeGlowEffect_Hush() {
        self.shadowOpacity = 0
    }
}
