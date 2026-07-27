import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Load_Maki: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Maki: 字体大小，默认30
    static func setupHUDConfig_Maki(fontSize_Maki: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Maki = UIFont(name: "AvenirNext-Medium", size: fontSize_Maki) {
            ProgressHUD.fontStatus = roundedFont_Maki
        } else if let roundedFont_Maki = UIFont(name: "Helvetica Neue", size: fontSize_Maki) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Maki
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Maki, weight: .semibold)
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
    static func showLoading_Maki(message_Maki: String? = nil) {
        if let message_Maki = message_Maki, !message_Maki.isEmpty {
            ProgressHUD.animate(message_Maki)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Maki(
        progress_Maki: CGFloat,
        message_Maki: String? = nil
    ) {
        if let message_Maki = message_Maki, !message_Maki.isEmpty {
            ProgressHUD.progress(message_Maki, progress_Maki)
        } else {
            ProgressHUD.progress(progress_Maki)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Maki() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Maki(delay_Maki: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Maki) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Maki(
        message_Maki: String = "Success",
        image_Maki: UIImage? = nil,
        delay_Maki: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Maki)
        dismissLoadingWithDelay_Maki(delay_Maki: delay_Maki)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Maki(
        message_Maki: String = "Error",
        image_Maki: UIImage? = nil,
        delay_Maki: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Maki)
        dismissLoadingWithDelay_Maki(delay_Maki: delay_Maki)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Maki(
        message_Maki: String,
        delay_Maki: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Maki, delay: delay_Maki)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Maki(
        message_Maki: String,
        image_Maki: UIImage,
        delay_Maki: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Maki, delay: delay_Maki)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Maki(
        message_Maki: String,
        symbolName_Maki: String,
        delay_Maki: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Maki, name: symbolName_Maki)
        dismissLoadingWithDelay_Maki(delay_Maki: delay_Maki)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Maki(
        message_Maki: String,
        delay_Maki: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Maki(
            message_Maki: message_Maki,
            symbolName_Maki: "exclamationmark.triangle.fill",
            delay_Maki: delay_Maki
        )
    }
    
    /// 显示信息提示
    static func showInfo_Maki(
        message_Maki: String,
        delay_Maki: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Maki(
            message_Maki: message_Maki,
            symbolName_Maki: "info.circle.fill",
            delay_Maki: delay_Maki
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Maki(
        title_Maki: String = "",
        message_Maki: String,
        delay_Maki: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Maki, message_Maki, delay: delay_Maki)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Maki() {
        ProgressHUD.remove()
    }
}
