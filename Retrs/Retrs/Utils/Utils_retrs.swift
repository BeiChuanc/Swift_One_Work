import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Retrs: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Retrs: 字体大小，默认30
    static func setupHUDConfig_Retrs(fontSize_Retrs: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Retrs = UIFont(name: "AvenirNext-Medium", size: fontSize_Retrs) {
            ProgressHUD.fontStatus = roundedFont_Retrs
        } else if let roundedFont_Retrs = UIFont(name: "Helvetica Neue", size: fontSize_Retrs) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Retrs
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Retrs, weight: .semibold)
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
    static func showLoading_Retrs(message_Retrs: String? = nil) {
        if let message_Retrs = message_Retrs, !message_Retrs.isEmpty {
            ProgressHUD.animate(message_Retrs)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Retrs(
        progress_Retrs: CGFloat,
        message_Retrs: String? = nil
    ) {
        if let message_Retrs = message_Retrs, !message_Retrs.isEmpty {
            ProgressHUD.progress(message_Retrs, progress_Retrs)
        } else {
            ProgressHUD.progress(progress_Retrs)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Retrs() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Retrs(delay_Retrs: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Retrs) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Retrs(
        message_Retrs: String = "Success",
        image_Retrs: UIImage? = nil,
        delay_Retrs: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Retrs)
        dismissLoadingWithDelay_Retrs(delay_Retrs: delay_Retrs)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Retrs(
        message_Retrs: String = "Error",
        image_Retrs: UIImage? = nil,
        delay_Retrs: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Retrs)
        dismissLoadingWithDelay_Retrs(delay_Retrs: delay_Retrs)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Retrs(
        message_Retrs: String,
        delay_Retrs: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Retrs, delay: delay_Retrs)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Retrs(
        message_Retrs: String,
        image_Retrs: UIImage,
        delay_Retrs: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Retrs, delay: delay_Retrs)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Retrs(
        message_Retrs: String,
        symbolName_Retrs: String,
        delay_Retrs: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Retrs, name: symbolName_Retrs)
        dismissLoadingWithDelay_Retrs(delay_Retrs: delay_Retrs)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Retrs(
        message_Retrs: String,
        delay_Retrs: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Retrs(
            message_Retrs: message_Retrs,
            symbolName_Retrs: "exclamationmark.triangle.fill",
            delay_Retrs: delay_Retrs
        )
    }
    
    /// 显示信息提示
    static func showInfo_Retrs(
        message_Retrs: String,
        delay_Retrs: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Retrs(
            message_Retrs: message_Retrs,
            symbolName_Retrs: "info.circle.fill",
            delay_Retrs: delay_Retrs
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Retrs(
        title_Retrs: String = "",
        message_Retrs: String,
        delay_Retrs: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Retrs, message_Retrs, delay: delay_Retrs)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Retrs() {
        ProgressHUD.remove()
    }
}
