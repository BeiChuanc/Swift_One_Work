import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Flick: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Flick: 字体大小，默认30
    static func setupHUDConfig_Flick(fontSize_Flick: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Flick = UIFont(name: "AvenirNext-Medium", size: fontSize_Flick) {
            ProgressHUD.fontStatus = roundedFont_Flick
        } else if let roundedFont_Flick = UIFont(name: "Helvetica Neue", size: fontSize_Flick) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Flick
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Flick, weight: .semibold)
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
    static func showLoading_Flick(message_Flick: String? = nil) {
        if let message_Flick = message_Flick, !message_Flick.isEmpty {
            ProgressHUD.animate(message_Flick)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Flick(
        progress_Flick: CGFloat,
        message_Flick: String? = nil
    ) {
        if let message_Flick = message_Flick, !message_Flick.isEmpty {
            ProgressHUD.progress(message_Flick, progress_Flick)
        } else {
            ProgressHUD.progress(progress_Flick)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Flick() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Flick(delay_Flick: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Flick) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Flick(
        message_Flick: String = "Success",
        image_Flick: UIImage? = nil,
        delay_Flick: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Flick)
        dismissLoadingWithDelay_Flick(delay_Flick: delay_Flick)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Flick(
        message_Flick: String = "Error",
        image_Flick: UIImage? = nil,
        delay_Flick: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Flick)
        dismissLoadingWithDelay_Flick(delay_Flick: delay_Flick)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Flick(
        message_Flick: String,
        delay_Flick: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Flick, delay: delay_Flick)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Flick(
        message_Flick: String,
        image_Flick: UIImage,
        delay_Flick: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Flick, delay: delay_Flick)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Flick(
        message_Flick: String,
        symbolName_Flick: String,
        delay_Flick: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Flick, name: symbolName_Flick)
        dismissLoadingWithDelay_Flick(delay_Flick: delay_Flick)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Flick(
        message_Flick: String,
        delay_Flick: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Flick(
            message_Flick: message_Flick,
            symbolName_Flick: "exclamationmark.triangle.fill",
            delay_Flick: delay_Flick
        )
    }
    
    /// 显示信息提示
    static func showInfo_Flick(
        message_Flick: String,
        delay_Flick: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Flick(
            message_Flick: message_Flick,
            symbolName_Flick: "info.circle.fill",
            delay_Flick: delay_Flick
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Flick(
        title_Flick: String = "",
        message_Flick: String,
        delay_Flick: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Flick, message_Flick, delay: delay_Flick)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Flick() {
        ProgressHUD.remove()
    }
}
