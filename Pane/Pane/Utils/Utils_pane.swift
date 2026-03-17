import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Pane: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Pane: 字体大小，默认30
    static func setupHUDConfig_Pane(fontSize_Pane: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Pane = UIFont(name: "AvenirNext-Medium", size: fontSize_Pane) {
            ProgressHUD.fontStatus = roundedFont_Pane
        } else if let roundedFont_Pane = UIFont(name: "Helvetica Neue", size: fontSize_Pane) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Pane
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Pane, weight: .semibold)
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
    static func showLoading_Pane(message_Pane: String? = nil) {
        if let message_Pane = message_Pane, !message_Pane.isEmpty {
            ProgressHUD.animate(message_Pane)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Pane(
        progress_Pane: CGFloat,
        message_Pane: String? = nil
    ) {
        if let message_Pane = message_Pane, !message_Pane.isEmpty {
            ProgressHUD.progress(message_Pane, progress_Pane)
        } else {
            ProgressHUD.progress(progress_Pane)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Pane() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Pane(delay_Pane: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Pane) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Pane(
        message_Pane: String = "Success",
        image_Pane: UIImage? = nil,
        delay_Pane: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Pane)
        dismissLoadingWithDelay_Pane(delay_Pane: delay_Pane)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Pane(
        message_Pane: String = "Error",
        image_Pane: UIImage? = nil,
        delay_Pane: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Pane)
        dismissLoadingWithDelay_Pane(delay_Pane: delay_Pane)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Pane(
        message_Pane: String,
        delay_Pane: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Pane, delay: delay_Pane)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Pane(
        message_Pane: String,
        image_Pane: UIImage,
        delay_Pane: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Pane, delay: delay_Pane)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Pane(
        message_Pane: String,
        symbolName_Pane: String,
        delay_Pane: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Pane, name: symbolName_Pane)
        dismissLoadingWithDelay_Pane(delay_Pane: delay_Pane)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Pane(
        message_Pane: String,
        delay_Pane: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Pane(
            message_Pane: message_Pane,
            symbolName_Pane: "exclamationmark.triangle.fill",
            delay_Pane: delay_Pane
        )
    }
    
    /// 显示信息提示
    static func showInfo_Pane(
        message_Pane: String,
        delay_Pane: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Pane(
            message_Pane: message_Pane,
            symbolName_Pane: "info.circle.fill",
            delay_Pane: delay_Pane
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Pane(
        title_Pane: String = "",
        message_Pane: String,
        delay_Pane: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Pane, message_Pane, delay: delay_Pane)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Pane() {
        ProgressHUD.remove()
    }
}
