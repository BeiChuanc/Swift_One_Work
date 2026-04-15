import Foundation
import UIKit

// MARK: 动画配置

/// 动画配置类
/// 功能：集中管理应用的动画参数、时长和缓动曲线
/// 设计理念：流畅弹性、温暖细腻、富有生命力
struct AnimationConfig_Epoch {
    
    // MARK: - 动画时长
    
    /// 快速动画（如按钮点击反馈）
    static let durationFast_Epoch: TimeInterval = 0.2
    
    /// 标准动画（如视图切换）
    static let durationNormal_Epoch: TimeInterval = 0.3
    
    /// 慢速动画（如页面转场）
    static let durationSlow_Epoch: TimeInterval = 0.5
    
    /// 弹性动画（如弹出视图）
    static let durationSpring_Epoch: TimeInterval = 0.6
    
    // MARK: - 弹性动画参数
    
    /// 轻微弹性（适用于按钮、小元素）
    static let springDampingLight_Epoch: CGFloat = 0.8
    
    /// 标准弹性（适用于卡片、面板）
    static let springDampingNormal_Epoch: CGFloat = 0.7
    
    /// 强烈弹性（适用于大型弹出视图）
    static let springDampingHeavy_Epoch: CGFloat = 0.6
    
    /// 初始速度
    static let springVelocity_Epoch: CGFloat = 0.5
    
    // MARK: - 缩放参数
    
    /// 按压缩小比例
    static let scalePressDown_Epoch: CGFloat = 0.95
    
    /// 弹出放大比例
    static let scalePopUp_Epoch: CGFloat = 1.1
    
    /// 正常比例
    static let scaleNormal_Epoch: CGFloat = 1.0
    
    // MARK: - 透明度
    
    /// 完全不透明
    static let alphaVisible_Epoch: CGFloat = 1.0
    
    /// 半透明（背景遮罩）
    static let alphaOverlay_Epoch: CGFloat = 0.5
    
    /// 不可见
    static let alphaHidden_Epoch: CGFloat = 0.0
    
    // MARK: - 延迟参数
    
    /// 短延迟（用于级联动画）
    static let delayShort_Epoch: TimeInterval = 0.05
    
    /// 中等延迟
    static let delayMedium_Epoch: TimeInterval = 0.1
    
    /// 长延迟
    static let delayLong_Epoch: TimeInterval = 0.2
}

// MARK: - UIView动画扩展

extension UIView {
    
    /// 弹性缩放动画（从小到大）
    /// 功能：视图从0.8缩放到1.0，带弹性效果
    /// 参数：
    /// - delay_Epoch: 延迟时间
    /// - completion_Epoch: 完成回调
    func animateSpringScaleIn_Epoch(delay_Epoch: TimeInterval = 0, completion_Epoch: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Epoch.durationSpring_Epoch,
            delay: delay_Epoch,
            usingSpringWithDamping: AnimationConfig_Epoch.springDampingNormal_Epoch,
            initialSpringVelocity: AnimationConfig_Epoch.springVelocity_Epoch,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Epoch?()
            }
        )
    }
    
    /// 按压动画（缩小）
    /// 功能：视图缩小到0.95，模拟按压效果
    /// 参数：
    /// - completion_Epoch: 完成回调
    func animatePressDown_Epoch(completion_Epoch: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Epoch.durationFast_Epoch,
            animations: {
                self.transform = CGAffineTransform(scaleX: AnimationConfig_Epoch.scalePressDown_Epoch, 
                                                   y: AnimationConfig_Epoch.scalePressDown_Epoch)
            },
            completion: { _ in
                completion_Epoch?()
            }
        )
    }
    
    /// 释放动画（恢复）
    /// 功能：视图恢复到原始大小
    /// 参数：
    /// - completion_Epoch: 完成回调
    func animatePressUp_Epoch(completion_Epoch: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Epoch.durationFast_Epoch,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Epoch.springDampingLight_Epoch,
            initialSpringVelocity: AnimationConfig_Epoch.springVelocity_Epoch,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
            },
            completion: { _ in
                completion_Epoch?()
            }
        )
    }
    
    /// 脉冲动画
    /// 功能：视图快速放大再缩小，产生脉冲效果
    /// 参数：
    /// - completion_Epoch: 完成回调
    func animatePulse_Epoch(completion_Epoch: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationConfig_Epoch.durationFast_Epoch,
            animations: {
                self.transform = CGAffineTransform(scaleX: AnimationConfig_Epoch.scalePopUp_Epoch, 
                                                   y: AnimationConfig_Epoch.scalePopUp_Epoch)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: AnimationConfig_Epoch.durationFast_Epoch,
                    animations: {
                        self.transform = .identity
                    },
                    completion: { _ in
                        completion_Epoch?()
                    }
                )
            }
        )
    }
    
    /// 从下方滑入动画
    /// 功能：视图从底部滑入，带弹性效果
    /// 参数：
    /// - offset_Epoch: 偏移距离
    /// - delay_Epoch: 延迟时间
    /// - completion_Epoch: 完成回调
    func animateSlideInFromBottom_Epoch(offset_Epoch: CGFloat = 50, delay_Epoch: TimeInterval = 0, completion_Epoch: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(translationX: 0, y: offset_Epoch)
        self.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Epoch.durationSpring_Epoch,
            delay: delay_Epoch,
            usingSpringWithDamping: AnimationConfig_Epoch.springDampingNormal_Epoch,
            initialSpringVelocity: AnimationConfig_Epoch.springVelocity_Epoch,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Epoch?()
            }
        )
    }
    
    /// 淡入动画
    /// 功能：视图从透明到不透明
    /// 参数：
    /// - duration_Epoch: 动画时长
    /// - delay_Epoch: 延迟时间
    /// - completion_Epoch: 完成回调
    func animateFadeIn_Epoch(duration_Epoch: TimeInterval? = nil, delay_Epoch: TimeInterval = 0, completion_Epoch: (() -> Void)? = nil) {
        self.alpha = 0
        
        UIView.animate(
            withDuration: duration_Epoch ?? AnimationConfig_Epoch.durationNormal_Epoch,
            delay: delay_Epoch,
            options: [.curveEaseOut],
            animations: {
                self.alpha = 1.0
            },
            completion: { _ in
                completion_Epoch?()
            }
        )
    }
    
    /// 淡出动画
    /// 功能：视图从不透明到透明
    /// 参数：
    /// - duration_Epoch: 动画时长
    /// - delay_Epoch: 延迟时间
    /// - completion_Epoch: 完成回调
    func animateFadeOut_Epoch(duration_Epoch: TimeInterval? = nil, delay_Epoch: TimeInterval = 0, completion_Epoch: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration_Epoch ?? AnimationConfig_Epoch.durationNormal_Epoch,
            delay: delay_Epoch,
            options: [.curveEaseIn],
            animations: {
                self.alpha = 0
            },
            completion: { _ in
                completion_Epoch?()
            }
        )
    }
    
    /// 旋转动画
    /// 功能：视图旋转指定角度
    /// 参数：
    /// - angle_Epoch: 旋转角度（弧度）
    /// - duration_Epoch: 动画时长
    /// - completion_Epoch: 完成回调
    func animateRotate_Epoch(angle_Epoch: CGFloat, duration_Epoch: TimeInterval? = nil, completion_Epoch: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration_Epoch ?? AnimationConfig_Epoch.durationNormal_Epoch,
            animations: {
                self.transform = CGAffineTransform(rotationAngle: angle_Epoch)
            },
            completion: { _ in
                completion_Epoch?()
            }
        )
    }
    
    /// 震动动画
    /// 功能：视图左右震动
    func animateShake_Epoch() {
        let animation_Epoch = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation_Epoch.timingFunction = CAMediaTimingFunction(name: .linear)
        animation_Epoch.duration = 0.6
        animation_Epoch.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
        self.layer.add(animation_Epoch, forKey: "shake")
    }
}

// MARK: - CALayer动画扩展

extension CALayer {
    
    /// 添加光晕效果
    /// 功能：为图层添加发光阴影
    /// 参数：
    /// - color_Epoch: 光晕颜色
    /// - radius_Epoch: 光晕半径
    func addGlowEffect_Epoch(color_Epoch: UIColor, radius_Epoch: CGFloat = 10) {
        self.shadowColor = color_Epoch.cgColor
        self.shadowOffset = .zero
        self.shadowRadius = radius_Epoch
        self.shadowOpacity = 0.6
    }
    
    /// 移除光晕效果
    func removeGlowEffect_Epoch() {
        self.shadowOpacity = 0
    }
}
