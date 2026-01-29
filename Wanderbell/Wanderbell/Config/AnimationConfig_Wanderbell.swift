import Foundation
import UIKit

// MARK: 动画配置

/// 动画配置类
/// 功能：集中管理应用的动画参数、时长和缓动曲线
/// 设计理念：流畅弹性、温暖细腻、富有生命力
struct AnimationConfig_Wanderbell {
    
    // MARK: - 动画时长
    
    /// 快速动画（如按钮点击反馈）
    static let durationFast_Wanderbell: TimeInterval = 0.2
    
    /// 标准动画（如视图切换）
    static let durationNormal_Wanderbell: TimeInterval = 0.3
    
    /// 慢速动画（如页面转场）
    static let durationSlow_Wanderbell: TimeInterval = 0.5
    
    /// 弹性动画（如弹出视图）
    static let durationSpring_Wanderbell: TimeInterval = 0.6
    
    // MARK: - 弹性动画参数
    
    /// 轻微弹性（适用于按钮、小元素）
    static let springDampingLight_Wanderbell: CGFloat = 0.8
    
    /// 标准弹性（适用于卡片、面板）
    static let springDampingNormal_Wanderbell: CGFloat = 0.7
    
    /// 强烈弹性（适用于大型弹出视图）
    static let springDampingHeavy_Wanderbell: CGFloat = 0.6
    
    /// 初始速度
    static let springVelocity_Wanderbell: CGFloat = 0.5
    
    // MARK: - 缩放参数
    
    /// 按压缩小比例
    static let scalePressDown_Wanderbell: CGFloat = 0.95
    
    /// 弹出放大比例
    static let scalePopUp_Wanderbell: CGFloat = 1.1
    
    /// 正常比例
    static let scaleNormal_Wanderbell: CGFloat = 1.0
    
    // MARK: - 透明度
    
    /// 完全不透明
    static let alphaVisible_Wanderbell: CGFloat = 1.0
    
    /// 半透明（背景遮罩）
    static let alphaOverlay_Wanderbell: CGFloat = 0.5
    
    /// 不可见
    static let alphaHidden_Wanderbell: CGFloat = 0.0
    
    // MARK: - 延迟参数
    
    /// 短延迟（用于级联动画）
    static let delayShort_Wanderbell: TimeInterval = 0.05
    
    /// 中等延迟
    static let delayMedium_Wanderbell: TimeInterval = 0.1
    
    /// 长延迟
    static let delayLong_Wanderbell: TimeInterval = 0.2
}

// MARK: - UIView动画扩展

extension UIView {
    
    /// 弹性缩放动画（从小到大）
    /// 功能：视图从0.8缩放到1.0，带弹性效果
    /// 参数：
    /// - delay_wanderbell: 延迟时间
    /// - completion_wanderbell: 完成回调
    func animateSpringScaleIn_Wanderbell(delay_wanderbell: TimeInterval = 0, completion_wanderbell: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Wanderbell.durationSpring_Wanderbell,
            delay: delay_wanderbell,
            usingSpringWithDamping: AnimationConfig_Wanderbell.springDampingNormal_Wanderbell,
            initialSpringVelocity: AnimationConfig_Wanderbell.springVelocity_Wanderbell,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            },
            completion: { _ in
                completion_wanderbell?()
            }
        )
    }
    
    /// 按压动画（缩小）
    /// 功能：视图缩小到0.95，模拟按压效果
    /// 参数：
    /// - completion_wanderbell: 完成回调
    func animatePressDown_Wanderbell(completion_wanderbell: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Wanderbell.durationFast_Wanderbell,
            animations: {
                self.transform = CGAffineTransform(scaleX: AnimationConfig_Wanderbell.scalePressDown_Wanderbell, 
                                                   y: AnimationConfig_Wanderbell.scalePressDown_Wanderbell)
            },
            completion: { _ in
                completion_wanderbell?()
            }
        )
    }
    
    /// 释放动画（恢复）
    /// 功能：视图恢复到原始大小
    /// 参数：
    /// - completion_wanderbell: 完成回调
    func animatePressUp_Wanderbell(completion_wanderbell: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Wanderbell.durationFast_Wanderbell,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Wanderbell.springDampingLight_Wanderbell,
            initialSpringVelocity: AnimationConfig_Wanderbell.springVelocity_Wanderbell,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
            },
            completion: { _ in
                completion_wanderbell?()
            }
        )
    }
    
    /// 脉冲动画
    /// 功能：视图快速放大再缩小，产生脉冲效果
    /// 参数：
    /// - completion_wanderbell: 完成回调
    func animatePulse_Wanderbell(completion_wanderbell: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Wanderbell.durationFast_Wanderbell,
            animations: {
                self.transform = CGAffineTransform(scaleX: AnimationConfig_Wanderbell.scalePopUp_Wanderbell, 
                                                   y: AnimationConfig_Wanderbell.scalePopUp_Wanderbell)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: AnimationConfig_Wanderbell.durationFast_Wanderbell,
                    animations: {
                        self.transform = .identity
                    },
                    completion: { _ in
                        completion_wanderbell?()
                    }
                )
            }
        )
    }
    
    /// 从下方滑入动画
    /// 功能：视图从底部滑入，带弹性效果
    /// 参数：
    /// - offset_wanderbell: 偏移距离
    /// - delay_wanderbell: 延迟时间
    /// - completion_wanderbell: 完成回调
    func animateSlideInFromBottom_Wanderbell(offset_wanderbell: CGFloat = 50, delay_wanderbell: TimeInterval = 0, completion_wanderbell: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(translationX: 0, y: offset_wanderbell)
        self.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Wanderbell.durationSpring_Wanderbell,
            delay: delay_wanderbell,
            usingSpringWithDamping: AnimationConfig_Wanderbell.springDampingNormal_Wanderbell,
            initialSpringVelocity: AnimationConfig_Wanderbell.springVelocity_Wanderbell,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            },
            completion: { _ in
                completion_wanderbell?()
            }
        )
    }
    
    /// 淡入动画
    /// 功能：视图从透明到不透明
    /// 参数：
    /// - duration_wanderbell: 动画时长
    /// - delay_wanderbell: 延迟时间
    /// - completion_wanderbell: 完成回调
    func animateFadeIn_Wanderbell(duration_wanderbell: TimeInterval? = nil, delay_wanderbell: TimeInterval = 0, completion_wanderbell: (() -> Void)? = nil) {
        self.alpha = 0
        
        UIView.animate(
            withDuration: duration_wanderbell ?? AnimationConfig_Wanderbell.durationNormal_Wanderbell,
            delay: delay_wanderbell,
            options: [.curveEaseOut],
            animations: {
                self.alpha = 1.0
            },
            completion: { _ in
                completion_wanderbell?()
            }
        )
    }
    
    /// 淡出动画
    /// 功能：视图从不透明到透明
    /// 参数：
    /// - duration_wanderbell: 动画时长
    /// - delay_wanderbell: 延迟时间
    /// - completion_wanderbell: 完成回调
    func animateFadeOut_Wanderbell(duration_wanderbell: TimeInterval? = nil, delay_wanderbell: TimeInterval = 0, completion_wanderbell: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration_wanderbell ?? AnimationConfig_Wanderbell.durationNormal_Wanderbell,
            delay: delay_wanderbell,
            options: [.curveEaseIn],
            animations: {
                self.alpha = 0
            },
            completion: { _ in
                completion_wanderbell?()
            }
        )
    }
    
    /// 旋转动画
    /// 功能：视图旋转指定角度
    /// 参数：
    /// - angle_wanderbell: 旋转角度（弧度）
    /// - duration_wanderbell: 动画时长
    /// - completion_wanderbell: 完成回调
    func animateRotate_Wanderbell(angle_wanderbell: CGFloat, duration_wanderbell: TimeInterval? = nil, completion_wanderbell: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration_wanderbell ?? AnimationConfig_Wanderbell.durationNormal_Wanderbell,
            animations: {
                self.transform = CGAffineTransform(rotationAngle: angle_wanderbell)
            },
            completion: { _ in
                completion_wanderbell?()
            }
        )
    }
    
    /// 震动动画
    /// 功能：视图左右震动
    func animateShake_Wanderbell() {
        let animation_wanderbell = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation_wanderbell.timingFunction = CAMediaTimingFunction(name: .linear)
        animation_wanderbell.duration = 0.6
        animation_wanderbell.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
        self.layer.add(animation_wanderbell, forKey: "shake")
    }
}

// MARK: - CALayer动画扩展

extension CALayer {
    
    /// 添加光晕效果
    /// 功能：为图层添加发光阴影
    /// 参数：
    /// - color_wanderbell: 光晕颜色
    /// - radius_wanderbell: 光晕半径
    func addGlowEffect_Wanderbell(color_wanderbell: UIColor, radius_wanderbell: CGFloat = 10) {
        self.shadowColor = color_wanderbell.cgColor
        self.shadowOffset = .zero
        self.shadowRadius = radius_wanderbell
        self.shadowOpacity = 0.6
    }
    
    /// 移除光晕效果
    func removeGlowEffect_Wanderbell() {
        self.shadowOpacity = 0
    }
}
