import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Hush: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Hush: 字体大小，默认30
    static func setupHUDConfig_Hush(fontSize_Hush: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Hush = UIFont(name: "AvenirNext-Medium", size: fontSize_Hush) {
            ProgressHUD.fontStatus = roundedFont_Hush
        } else if let roundedFont_Hush = UIFont(name: "Helvetica Neue", size: fontSize_Hush) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Hush
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Hush, weight: .semibold)
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
    static func showLoading_Hush(message_Hush: String? = nil) {
        if let message_Hush = message_Hush, !message_Hush.isEmpty {
            ProgressHUD.animate(message_Hush)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Hush(
        progress_Hush: CGFloat,
        message_Hush: String? = nil
    ) {
        if let message_Hush = message_Hush, !message_Hush.isEmpty {
            ProgressHUD.progress(message_Hush, progress_Hush)
        } else {
            ProgressHUD.progress(progress_Hush)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Hush() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Hush(delay_Hush: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Hush) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Hush(
        message_Hush: String = "Success",
        image_Hush: UIImage? = nil,
        delay_Hush: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Hush)
        dismissLoadingWithDelay_Hush(delay_Hush: delay_Hush)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Hush(
        message_Hush: String = "Error",
        image_Hush: UIImage? = nil,
        delay_Hush: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Hush)
        dismissLoadingWithDelay_Hush(delay_Hush: delay_Hush)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Hush(
        message_Hush: String,
        delay_Hush: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Hush, delay: delay_Hush)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Hush(
        message_Hush: String,
        image_Hush: UIImage,
        delay_Hush: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Hush, delay: delay_Hush)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Hush(
        message_Hush: String,
        symbolName_Hush: String,
        delay_Hush: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Hush, name: symbolName_Hush)
        dismissLoadingWithDelay_Hush(delay_Hush: delay_Hush)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Hush(
        message_Hush: String,
        delay_Hush: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Hush(
            message_Hush: message_Hush,
            symbolName_Hush: "exclamationmark.triangle.fill",
            delay_Hush: delay_Hush
        )
    }
    
    /// 显示信息提示
    static func showInfo_Hush(
        message_Hush: String,
        delay_Hush: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Hush(
            message_Hush: message_Hush,
            symbolName_Hush: "info.circle.fill",
            delay_Hush: delay_Hush
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Hush(
        title_Hush: String = "",
        message_Hush: String,
        delay_Hush: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Hush, message_Hush, delay: delay_Hush)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Hush() {
        ProgressHUD.remove()
    }
}
