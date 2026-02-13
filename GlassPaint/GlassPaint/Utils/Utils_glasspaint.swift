import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Glasspaint: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Glasspaint: 字体大小，默认30
    static func setupHUDConfig_Glasspaint(fontSize_Glasspaint: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Glasspaint = UIFont(name: "AvenirNext-Medium", size: fontSize_Glasspaint) {
            ProgressHUD.fontStatus = roundedFont_Glasspaint
        } else if let roundedFont_Glasspaint = UIFont(name: "Helvetica Neue", size: fontSize_Glasspaint) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Glasspaint
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Glasspaint, weight: .semibold)
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
    static func showLoading_Glasspaint(message_Glasspaint: String? = nil) {
        if let message_Glasspaint = message_Glasspaint, !message_Glasspaint.isEmpty {
            ProgressHUD.animate(message_Glasspaint)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Glasspaint(
        progress_Glasspaint: CGFloat,
        message_Glasspaint: String? = nil
    ) {
        if let message_Glasspaint = message_Glasspaint, !message_Glasspaint.isEmpty {
            ProgressHUD.progress(message_Glasspaint, progress_Glasspaint)
        } else {
            ProgressHUD.progress(progress_Glasspaint)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Glasspaint() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Glasspaint(delay_Glasspaint: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Glasspaint) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Glasspaint(
        message_Glasspaint: String = "Success",
        image_Glasspaint: UIImage? = nil,
        delay_Glasspaint: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Glasspaint)
        dismissLoadingWithDelay_Glasspaint(delay_Glasspaint: delay_Glasspaint)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Glasspaint(
        message_Glasspaint: String = "Error",
        image_Glasspaint: UIImage? = nil,
        delay_Glasspaint: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Glasspaint)
        dismissLoadingWithDelay_Glasspaint(delay_Glasspaint: delay_Glasspaint)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Glasspaint(
        message_Glasspaint: String,
        delay_Glasspaint: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Glasspaint, delay: delay_Glasspaint)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Glasspaint(
        message_Glasspaint: String,
        image_Glasspaint: UIImage,
        delay_Glasspaint: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Glasspaint, delay: delay_Glasspaint)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Glasspaint(
        message_Glasspaint: String,
        symbolName_Glasspaint: String,
        delay_Glasspaint: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Glasspaint, name: symbolName_Glasspaint)
        dismissLoadingWithDelay_Glasspaint(delay_Glasspaint: delay_Glasspaint)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Glasspaint(
        message_Glasspaint: String,
        delay_Glasspaint: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Glasspaint(
            message_Glasspaint: message_Glasspaint,
            symbolName_Glasspaint: "exclamationmark.triangle.fill",
            delay_Glasspaint: delay_Glasspaint
        )
    }
    
    /// 显示信息提示
    static func showInfo_Glasspaint(
        message_Glasspaint: String,
        delay_Glasspaint: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Glasspaint(
            message_Glasspaint: message_Glasspaint,
            symbolName_Glasspaint: "info.circle.fill",
            delay_Glasspaint: delay_Glasspaint
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Glasspaint(
        title_Glasspaint: String = "",
        message_Glasspaint: String,
        delay_Glasspaint: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Glasspaint, message_Glasspaint, delay: delay_Glasspaint)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Glasspaint() {
        ProgressHUD.remove()
    }
}
