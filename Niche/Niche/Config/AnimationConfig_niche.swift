import Foundation
import UIKit

// MARK: 动画配置

/// 动画配置类
/// 功能：集中管理应用的动画参数、时长和缓动曲线
/// 设计理念：流畅弹性、温暖细腻、富有生命力
struct AnimationConfig_Niche {
    
    // MARK: - 动画时长
    
    /// 快速动画（如按钮点击反馈）
    static let durationFast_Niche: TimeInterval = 0.2
    
    /// 标准动画（如视图切换）
    static let durationNormal_Niche: TimeInterval = 0.3
    
    /// 慢速动画（如页面转场）
    static let durationSlow_Niche: TimeInterval = 0.5
    
    /// 弹性动画（如弹出视图）
    static let durationSpring_Niche: TimeInterval = 0.6
    
    // MARK: - 弹性动画参数
    
    /// 轻微弹性（适用于按钮、小元素）
    static let springDampingLight_Niche: CGFloat = 0.8
    
    /// 标准弹性（适用于卡片、面板）
    static let springDampingNormal_Niche: CGFloat = 0.7
    
    /// 强烈弹性（适用于大型弹出视图）
    static let springDampingHeavy_Niche: CGFloat = 0.6
    
    /// 初始速度
    static let springVelocity_Niche: CGFloat = 0.5
    
    // MARK: - 缩放参数
    
    /// 按压缩小比例
    static let scalePressDown_Niche: CGFloat = 0.95
    
    /// 弹出放大比例
    static let scalePopUp_Niche: CGFloat = 1.1
    
    /// 正常比例
    static let scaleNormal_Niche: CGFloat = 1.0
    
    // MARK: - 透明度
    
    /// 完全不透明
    static let alphaVisible_Niche: CGFloat = 1.0
    
    /// 半透明（背景遮罩）
    static let alphaOverlay_Niche: CGFloat = 0.5
    
    /// 不可见
    static let alphaHidden_Niche: CGFloat = 0.0
    
    // MARK: - 延迟参数
    
    /// 短延迟（用于级联动画）
    static let delayShort_Niche: TimeInterval = 0.05
    
    /// 中等延迟
    static let delayMedium_Niche: TimeInterval = 0.1
    
    /// 长延迟
    static let delayLong_Niche: TimeInterval = 0.2
}

// MARK: - UIView动画扩展

extension UIView {
    
    /// 弹性缩放动画（从小到大）
    /// 功能：视图从0.8缩放到1.0，带弹性效果
    /// 参数：
    /// - delay_Niche: 延迟时间
    /// - completion_Niche: 完成回调
    func animateSpringScaleIn_Niche(delay_Niche: TimeInterval = 0, completion_Niche: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Niche.durationSpring_Niche,
            delay: delay_Niche,
            usingSpringWithDamping: AnimationConfig_Niche.springDampingNormal_Niche,
            initialSpringVelocity: AnimationConfig_Niche.springVelocity_Niche,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Niche?()
            }
        )
    }
    
    /// 按压动画（缩小）
    /// 功能：视图缩小到0.95，模拟按压效果
    /// 参数：
    /// - completion_Niche: 完成回调
    func animatePressDown_Niche(completion_Niche: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Niche.durationFast_Niche,
            animations: {
                self.transform = CGAffineTransform(scaleX: AnimationConfig_Niche.scalePressDown_Niche, 
                                                   y: AnimationConfig_Niche.scalePressDown_Niche)
            },
            completion: { _ in
                completion_Niche?()
            }
        )
    }
    
    /// 释放动画（恢复）
    /// 功能：视图恢复到原始大小
    /// 参数：
    /// - completion_Niche: 完成回调
    func animatePressUp_Niche(completion_Niche: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Niche.durationFast_Niche,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Niche.springDampingLight_Niche,
            initialSpringVelocity: AnimationConfig_Niche.springVelocity_Niche,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
            },
            completion: { _ in
                completion_Niche?()
            }
        )
    }
    
    /// 脉冲动画
    /// 功能：视图快速放大再缩小，产生脉冲效果
    /// 参数：
    /// - completion_Niche: 完成回调
    func animatePulse_Niche(completion_Niche: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Niche.durationFast_Niche,
            animations: {
                self.transform = CGAffineTransform(scaleX: AnimationConfig_Niche.scalePopUp_Niche, 
                                                   y: AnimationConfig_Niche.scalePopUp_Niche)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: AnimationConfig_Niche.durationFast_Niche,
                    animations: {
                        self.transform = .identity
                    },
                    completion: { _ in
                        completion_Niche?()
                    }
                )
            }
        )
    }
    
    /// 从下方滑入动画
    /// 功能：视图从底部滑入，带弹性效果
    /// 参数：
    /// - offset_Niche: 偏移距离
    /// - delay_Niche: 延迟时间
    /// - completion_Niche: 完成回调
    func animateSlideInFromBottom_Niche(offset_Niche: CGFloat = 50, delay_Niche: TimeInterval = 0, completion_Niche: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(translationX: 0, y: offset_Niche)
        self.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Niche.durationSpring_Niche,
            delay: delay_Niche,
            usingSpringWithDamping: AnimationConfig_Niche.springDampingNormal_Niche,
            initialSpringVelocity: AnimationConfig_Niche.springVelocity_Niche,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Niche?()
            }
        )
    }
    
    /// 淡入动画
    /// 功能：视图从透明到不透明
    /// 参数：
    /// - duration_Niche: 动画时长
    /// - delay_Niche: 延迟时间
    /// - completion_Niche: 完成回调
    func animateFadeIn_Niche(duration_Niche: TimeInterval? = nil, delay_Niche: TimeInterval = 0, completion_Niche: (() -> Void)? = nil) {
        self.alpha = 0
        
        UIView.animate(
            withDuration: duration_Niche ?? AnimationConfig_Niche.durationNormal_Niche,
            delay: delay_Niche,
            options: [.curveEaseOut],
            animations: {
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Niche?()
            }
        )
    }
    
    /// 淡出动画
    /// 功能：视图从不透明到透明
    /// 参数：
    /// - duration_Niche: 动画时长
    /// - delay_Niche: 延迟时间
    /// - completion_Niche: 完成回调
    func animateFadeOut_Niche(duration_Niche: TimeInterval? = nil, delay_Niche: TimeInterval = 0, completion_Niche: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration_Niche ?? AnimationConfig_Niche.durationNormal_Niche,
            delay: delay_Niche,
            options: [.curveEaseIn],
            animations: {
                self.alpha = 0
            },
            completion: { _ in
                completion_Niche?()
            }
        )
    }
    
    /// 旋转动画
    /// 功能：视图旋转指定角度
    /// 参数：
    /// - angle_Niche: 旋转角度（弧度）
    /// - duration_Niche: 动画时长
    /// - completion_Niche: 完成回调
    func animateRotate_Niche(angle_Niche: CGFloat, duration_Niche: TimeInterval? = nil, completion_Niche: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration_Niche ?? AnimationConfig_Niche.durationNormal_Niche,
            animations: {
                self.transform = CGAffineTransform(rotationAngle: angle_Niche)
            },
            completion: { _ in
                completion_Niche?()
            }
        )
    }
    
    /// 震动动画
    /// 功能：视图左右震动
    func animateShake_Niche() {
        let animation_Niche = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation_Niche.timingFunction = CAMediaTimingFunction(name: .linear)
        animation_Niche.duration = 0.6
        animation_Niche.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
        self.layer.add(animation_Niche, forKey: "shake")
    }
}

// MARK: - CALayer动画扩展

extension CALayer {
    
    /// 添加光晕效果
    /// 功能：为图层添加发光阴影
    /// 参数：
    /// - color_Niche: 光晕颜色
    /// - radius_Niche: 光晕半径
    func addGlowEffect_Niche(color_Niche: UIColor, radius_Niche: CGFloat = 10) {
        self.shadowColor = color_Niche.cgColor
        self.shadowOffset = .zero
        self.shadowRadius = radius_Niche
        self.shadowOpacity = 0.6
    }
    
    /// 移除光晕效果
    func removeGlowEffect_Niche() {
        self.shadowOpacity = 0
    }
}
