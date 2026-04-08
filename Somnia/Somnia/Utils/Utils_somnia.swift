import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Somnia: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Somnia: 字体大小，默认30
    static func setupHUDConfig_Somnia(fontSize_Somnia: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Somnia = UIFont(name: "AvenirNext-Medium", size: fontSize_Somnia) {
            ProgressHUD.fontStatus = roundedFont_Somnia
        } else if let roundedFont_Somnia = UIFont(name: "Helvetica Neue", size: fontSize_Somnia) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Somnia
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Somnia, weight: .semibold)
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
    static func showLoading_Somnia(message_Somnia: String? = nil) {
        if let message_Somnia = message_Somnia, !message_Somnia.isEmpty {
            ProgressHUD.animate(message_Somnia)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Somnia(
        progress_Somnia: CGFloat,
        message_Somnia: String? = nil
    ) {
        if let message_Somnia = message_Somnia, !message_Somnia.isEmpty {
            ProgressHUD.progress(message_Somnia, progress_Somnia)
        } else {
            ProgressHUD.progress(progress_Somnia)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Somnia() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Somnia(delay_Somnia: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Somnia) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Somnia(
        message_Somnia: String = "Success",
        image_Somnia: UIImage? = nil,
        delay_Somnia: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Somnia)
        dismissLoadingWithDelay_Somnia(delay_Somnia: delay_Somnia)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Somnia(
        message_Somnia: String = "Error",
        image_Somnia: UIImage? = nil,
        delay_Somnia: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Somnia)
        dismissLoadingWithDelay_Somnia(delay_Somnia: delay_Somnia)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Somnia(
        message_Somnia: String,
        delay_Somnia: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Somnia, delay: delay_Somnia)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Somnia(
        message_Somnia: String,
        image_Somnia: UIImage,
        delay_Somnia: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Somnia, delay: delay_Somnia)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Somnia(
        message_Somnia: String,
        symbolName_Somnia: String,
        delay_Somnia: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Somnia, name: symbolName_Somnia)
        dismissLoadingWithDelay_Somnia(delay_Somnia: delay_Somnia)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Somnia(
        message_Somnia: String,
        delay_Somnia: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Somnia(
            message_Somnia: message_Somnia,
            symbolName_Somnia: "exclamationmark.triangle.fill",
            delay_Somnia: delay_Somnia
        )
    }
    
    /// 显示信息提示
    static func showInfo_Somnia(
        message_Somnia: String,
        delay_Somnia: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Somnia(
            message_Somnia: message_Somnia,
            symbolName_Somnia: "info.circle.fill",
            delay_Somnia: delay_Somnia
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Somnia(
        title_Somnia: String = "",
        message_Somnia: String,
        delay_Somnia: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Somnia, message_Somnia, delay: delay_Somnia)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Somnia() {
        ProgressHUD.remove()
    }
}
