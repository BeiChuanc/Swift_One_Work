import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Doze: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Doze: 字体大小，默认30
    static func setupHUDConfig_Doze(fontSize_Doze: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Doze = UIFont(name: "AvenirNext-Medium", size: fontSize_Doze) {
            ProgressHUD.fontStatus = roundedFont_Doze
        } else if let roundedFont_Doze = UIFont(name: "Helvetica Neue", size: fontSize_Doze) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Doze
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Doze, weight: .semibold)
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
    static func showLoading_Doze(message_Doze: String? = nil) {
        if let message_Doze = message_Doze, !message_Doze.isEmpty {
            ProgressHUD.animate(message_Doze)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Doze(
        progress_Doze: CGFloat,
        message_Doze: String? = nil
    ) {
        if let message_Doze = message_Doze, !message_Doze.isEmpty {
            ProgressHUD.progress(message_Doze, progress_Doze)
        } else {
            ProgressHUD.progress(progress_Doze)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Doze() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Doze(delay_Doze: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Doze) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Doze(
        message_Doze: String = "Success",
        image_Doze: UIImage? = nil,
        delay_Doze: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Doze)
        dismissLoadingWithDelay_Doze(delay_Doze: delay_Doze)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Doze(
        message_Doze: String = "Error",
        image_Doze: UIImage? = nil,
        delay_Doze: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Doze)
        dismissLoadingWithDelay_Doze(delay_Doze: delay_Doze)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Doze(
        message_Doze: String,
        delay_Doze: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Doze, delay: delay_Doze)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Doze(
        message_Doze: String,
        image_Doze: UIImage,
        delay_Doze: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Doze, delay: delay_Doze)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Doze(
        message_Doze: String,
        symbolName_Doze: String,
        delay_Doze: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Doze, name: symbolName_Doze)
        dismissLoadingWithDelay_Doze(delay_Doze: delay_Doze)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Doze(
        message_Doze: String,
        delay_Doze: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Doze(
            message_Doze: message_Doze,
            symbolName_Doze: "exclamationmark.triangle.fill",
            delay_Doze: delay_Doze
        )
    }
    
    /// 显示信息提示
    static func showInfo_Doze(
        message_Doze: String,
        delay_Doze: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Doze(
            message_Doze: message_Doze,
            symbolName_Doze: "info.circle.fill",
            delay_Doze: delay_Doze
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Doze(
        title_Doze: String = "",
        message_Doze: String,
        delay_Doze: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Doze, message_Doze, delay: delay_Doze)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Doze() {
        ProgressHUD.remove()
    }
}
