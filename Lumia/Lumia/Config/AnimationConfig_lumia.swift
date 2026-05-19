import Foundation
import UIKit

// MARK: 动画配置

/// 动画配置类
/// 功能：集中管理应用的动画参数、时长和缓动曲线
/// 设计理念：流畅弹性、温暖细腻、富有生命力
struct AnimationConfig_Lumia {
    
    // MARK: - 动画时长
    
    /// 快速动画（如按钮点击反馈）
    static let durationFast_Lumia: TimeInterval = 0.2
    
    /// 标准动画（如视图切换）
    static let durationNormal_Lumia: TimeInterval = 0.3
    
    /// 慢速动画（如页面转场）
    static let durationSlow_Lumia: TimeInterval = 0.5
    
    /// 弹性动画（如弹出视图）
    static let durationSpring_Lumia: TimeInterval = 0.6
    
    // MARK: - 弹性动画参数
    
    /// 轻微弹性（适用于按钮、小元素）
    static let springDampingLight_Lumia: CGFloat = 0.8
    
    /// 标准弹性（适用于卡片、面板）
    static let springDampingNormal_Lumia: CGFloat = 0.7
    
    /// 强烈弹性（适用于大型弹出视图）
    static let springDampingHeavy_Lumia: CGFloat = 0.6
    
    /// 初始速度
    static let springVelocity_Lumia: CGFloat = 0.5
    
    // MARK: - 缩放参数
    
    /// 按压缩小比例
    static let scalePressDown_Lumia: CGFloat = 0.95
    
    /// 弹出放大比例
    static let scalePopUp_Lumia: CGFloat = 1.1
    
    /// 正常比例
    static let scaleNormal_Lumia: CGFloat = 1.0
    
    // MARK: - 透明度
    
    /// 完全不透明
    static let alphaVisible_Lumia: CGFloat = 1.0
    
    /// 半透明（背景遮罩）
    static let alphaOverlay_Lumia: CGFloat = 0.5
    
    /// 不可见
    static let alphaHidden_Lumia: CGFloat = 0.0
    
    // MARK: - 延迟参数
    
    /// 短延迟（用于级联动画）
    static let delayShort_Lumia: TimeInterval = 0.05
    
    /// 中等延迟
    static let delayMedium_Lumia: TimeInterval = 0.1
    
    /// 长延迟
    static let delayLong_Lumia: TimeInterval = 0.2
}

// MARK: - UIView动画扩展

extension UIView {
    
    /// 弹性缩放动画（从小到大）
    /// 功能：视图从0.8缩放到1.0，带弹性效果
    /// 参数：
    /// - delay_Lumia: 延迟时间
    /// - completion_Lumia: 完成回调
    func animateSpringScaleIn_Lumia(delay_Lumia: TimeInterval = 0, completion_Lumia: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Lumia.durationSpring_Lumia,
            delay: delay_Lumia,
            usingSpringWithDamping: AnimationConfig_Lumia.springDampingNormal_Lumia,
            initialSpringVelocity: AnimationConfig_Lumia.springVelocity_Lumia,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Lumia?()
            }
        )
    }
    
    /// 按压动画（缩小）
    /// 功能：视图缩小到0.95，模拟按压效果
    /// 参数：
    /// - completion_Lumia: 完成回调
    func animatePressDown_Lumia(completion_Lumia: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Lumia.durationFast_Lumia,
            animations: {
                self.transform = CGAffineTransform(scaleX: AnimationConfig_Lumia.scalePressDown_Lumia, 
                                                   y: AnimationConfig_Lumia.scalePressDown_Lumia)
            },
            completion: { _ in
                completion_Lumia?()
            }
        )
    }
    
    /// 释放动画（恢复）
    /// 功能：视图恢复到原始大小
    /// 参数：
    /// - completion_Lumia: 完成回调
    func animatePressUp_Lumia(completion_Lumia: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Lumia.durationFast_Lumia,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Lumia.springDampingLight_Lumia,
            initialSpringVelocity: AnimationConfig_Lumia.springVelocity_Lumia,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
            },
            completion: { _ in
                completion_Lumia?()
            }
        )
    }
    
    /// 脉冲动画
    /// 功能：视图快速放大再缩小，产生脉冲效果
    /// 参数：
    /// - completion_Lumia: 完成回调
    func animatePulse_Lumia(completion_Lumia: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Lumia.durationFast_Lumia,
            animations: {
                self.transform = CGAffineTransform(scaleX: AnimationConfig_Lumia.scalePopUp_Lumia, 
                                                   y: AnimationConfig_Lumia.scalePopUp_Lumia)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: AnimationConfig_Lumia.durationFast_Lumia,
                    animations: {
                        self.transform = .identity
                    },
                    completion: { _ in
                        completion_Lumia?()
                    }
                )
            }
        )
    }
    
    /// 从下方滑入动画
    /// 功能：视图从底部滑入，带弹性效果
    /// 参数：
    /// - offset_Lumia: 偏移距离
    /// - delay_Lumia: 延迟时间
    /// - completion_Lumia: 完成回调
    func animateSlideInFromBottom_Lumia(offset_Lumia: CGFloat = 50, delay_Lumia: TimeInterval = 0, completion_Lumia: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(translationX: 0, y: offset_Lumia)
        self.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Lumia.durationSpring_Lumia,
            delay: delay_Lumia,
            usingSpringWithDamping: AnimationConfig_Lumia.springDampingNormal_Lumia,
            initialSpringVelocity: AnimationConfig_Lumia.springVelocity_Lumia,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Lumia?()
            }
        )
    }
    
    /// 淡入动画
    /// 功能：视图从透明到不透明
    /// 参数：
    /// - duration_Lumia: 动画时长
    /// - delay_Lumia: 延迟时间
    /// - completion_Lumia: 完成回调
    func animateFadeIn_Lumia(duration_Lumia: TimeInterval? = nil, delay_Lumia: TimeInterval = 0, completion_Lumia: (() -> Void)? = nil) {
        self.alpha = 0
        
        UIView.animate(
            withDuration: duration_Lumia ?? AnimationConfig_Lumia.durationNormal_Lumia,
            delay: delay_Lumia,
            options: [.curveEaseOut],
            animations: {
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Lumia?()
            }
        )
    }
    
    /// 淡出动画
    /// 功能：视图从不透明到透明
    /// 参数：
    /// - duration_Lumia: 动画时长
    /// - delay_Lumia: 延迟时间
    /// - completion_Lumia: 完成回调
    func animateFadeOut_Lumia(duration_Lumia: TimeInterval? = nil, delay_Lumia: TimeInterval = 0, completion_Lumia: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration_Lumia ?? AnimationConfig_Lumia.durationNormal_Lumia,
            delay: delay_Lumia,
            options: [.curveEaseIn],
            animations: {
                self.alpha = 0
            },
            completion: { _ in
                completion_Lumia?()
            }
        )
    }
    
    /// 旋转动画
    /// 功能：视图旋转指定角度
    /// 参数：
    /// - angle_Lumia: 旋转角度（弧度）
    /// - duration_Lumia: 动画时长
    /// - completion_Lumia: 完成回调
    func animateRotate_Lumia(angle_Lumia: CGFloat, duration_Lumia: TimeInterval? = nil, completion_Lumia: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration_Lumia ?? AnimationConfig_Lumia.durationNormal_Lumia,
            animations: {
                self.transform = CGAffineTransform(rotationAngle: angle_Lumia)
            },
            completion: { _ in
                completion_Lumia?()
            }
        )
    }
    
    /// 震动动画
    /// 功能：视图左右震动
    func animateShake_Lumia() {
        let animation_Lumia = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation_Lumia.timingFunction = CAMediaTimingFunction(name: .linear)
        animation_Lumia.duration = 0.6
        animation_Lumia.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
        self.layer.add(animation_Lumia, forKey: "shake")
    }
}

// MARK: - CALayer动画扩展

extension CALayer {
    
    /// 添加光晕效果
    /// 功能：为图层添加发光阴影
    /// 参数：
    /// - color_Lumia: 光晕颜色
    /// - radius_Lumia: 光晕半径
    func addGlowEffect_Lumia(color_Lumia: UIColor, radius_Lumia: CGFloat = 10) {
        self.shadowColor = color_Lumia.cgColor
        self.shadowOffset = .zero
        self.shadowRadius = radius_Lumia
        self.shadowOpacity = 0.6
    }
    
    /// 移除光晕效果
    func removeGlowEffect_Lumia() {
        self.shadowOpacity = 0
    }
}
