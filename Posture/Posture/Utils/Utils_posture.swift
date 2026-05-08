import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Posture: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Posture: 字体大小，默认30
    static func setupHUDConfig_Posture(fontSize_Posture: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Posture = UIFont(name: "AvenirNext-Medium", size: fontSize_Posture) {
            ProgressHUD.fontStatus = roundedFont_Posture
        } else if let roundedFont_Posture = UIFont(name: "Helvetica Neue", size: fontSize_Posture) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Posture
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Posture, weight: .semibold)
        }
        
        // 设置文字颜色（深色，确保清晰可见）
        ProgressHUD.colorStatus = .label
        
        // 设置动画类型
        ProgressHUD.animationType = .circleStrokeSpin
        
        // 设置媒体大小（与字体大小成比例）
        ProgressHUD.mediaSize = 40
        
        // 设置HUD背景和边距，让文字有更好的展示空间
        ProgressHUD.colorBackground = .systemBackground.withAlphaComponent(0.95)
        ProgressHUD.colorHUD = .systemGray6.withAlphaComponent(0.98)
        ProgressHUD.marginSize = CGFloat(20)
    }
    
    // MARK: - 加载动画
    
    /// 显示加载动画
    static func showLoading_Posture(message_Posture: String? = nil) {
        if let message_Posture = message_Posture, !message_Posture.isEmpty {
            ProgressHUD.animate(message_Posture)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Posture(
        progress_Posture: CGFloat,
        message_Posture: String? = nil
    ) {
        if let message_Posture = message_Posture, !message_Posture.isEmpty {
            ProgressHUD.progress(message_Posture, progress_Posture)
        } else {
            ProgressHUD.progress(progress_Posture)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Posture() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Posture(delay_Posture: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Posture) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Posture(
        message_Posture: String = "Success",
        image_Posture: UIImage? = nil,
        delay_Posture: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Posture)
        dismissLoadingWithDelay_Posture(delay_Posture: delay_Posture)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Posture(
        message_Posture: String = "Error",
        image_Posture: UIImage? = nil,
        delay_Posture: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Posture)
        dismissLoadingWithDelay_Posture(delay_Posture: delay_Posture)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Posture(
        message_Posture: String,
        delay_Posture: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Posture, delay: delay_Posture)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Posture(
        message_Posture: String,
        image_Posture: UIImage,
        delay_Posture: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Posture, delay: delay_Posture)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Posture(
        message_Posture: String,
        symbolName_Posture: String,
        delay_Posture: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Posture, name: symbolName_Posture)
        dismissLoadingWithDelay_Posture(delay_Posture: delay_Posture)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Posture(
        message_Posture: String,
        delay_Posture: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Posture(
            message_Posture: message_Posture,
            symbolName_Posture: "exclamationmark.triangle.fill",
            delay_Posture: delay_Posture
        )
    }
    
    /// 显示信息提示
    static func showInfo_Posture(
        message_Posture: String,
        delay_Posture: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Posture(
            message_Posture: message_Posture,
            symbolName_Posture: "info.circle.fill",
            delay_Posture: delay_Posture
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Posture(
        title_Posture: String = "",
        message_Posture: String,
        delay_Posture: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Posture, message_Posture, delay: delay_Posture)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Posture() {
        ProgressHUD.remove()
    }
}
