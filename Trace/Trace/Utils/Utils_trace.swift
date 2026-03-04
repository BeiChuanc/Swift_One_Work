import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Trace: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Trace: 字体大小，默认30
    static func setupHUDConfig_Trace(fontSize_Trace: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Trace = UIFont(name: "AvenirNext-Medium", size: fontSize_Trace) {
            ProgressHUD.fontStatus = roundedFont_Trace
        } else if let roundedFont_Trace = UIFont(name: "Helvetica Neue", size: fontSize_Trace) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Trace
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Trace, weight: .semibold)
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
    static func showLoading_Trace(message_Trace: String? = nil) {
        if let message_Trace = message_Trace, !message_Trace.isEmpty {
            ProgressHUD.animate(message_Trace)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Trace(
        progress_Trace: CGFloat,
        message_Trace: String? = nil
    ) {
        if let message_Trace = message_Trace, !message_Trace.isEmpty {
            ProgressHUD.progress(message_Trace, progress_Trace)
        } else {
            ProgressHUD.progress(progress_Trace)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Trace() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Trace(delay_Trace: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Trace) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Trace(
        message_Trace: String = "Success",
        image_Trace: UIImage? = nil,
        delay_Trace: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Trace)
        dismissLoadingWithDelay_Trace(delay_Trace: delay_Trace)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Trace(
        message_Trace: String = "Error",
        image_Trace: UIImage? = nil,
        delay_Trace: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Trace)
        dismissLoadingWithDelay_Trace(delay_Trace: delay_Trace)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Trace(
        message_Trace: String,
        delay_Trace: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Trace, delay: delay_Trace)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Trace(
        message_Trace: String,
        image_Trace: UIImage,
        delay_Trace: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Trace, delay: delay_Trace)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Trace(
        message_Trace: String,
        symbolName_Trace: String,
        delay_Trace: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Trace, name: symbolName_Trace)
        dismissLoadingWithDelay_Trace(delay_Trace: delay_Trace)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Trace(
        message_Trace: String,
        delay_Trace: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Trace(
            message_Trace: message_Trace,
            symbolName_Trace: "exclamationmark.triangle.fill",
            delay_Trace: delay_Trace
        )
    }
    
    /// 显示信息提示
    static func showInfo_Trace(
        message_Trace: String,
        delay_Trace: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Trace(
            message_Trace: message_Trace,
            symbolName_Trace: "info.circle.fill",
            delay_Trace: delay_Trace
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Trace(
        title_Trace: String = "",
        message_Trace: String,
        delay_Trace: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Trace, message_Trace, delay: delay_Trace)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Trace() {
        ProgressHUD.remove()
    }
}
