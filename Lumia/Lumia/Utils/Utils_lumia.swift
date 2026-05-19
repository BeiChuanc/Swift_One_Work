import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Lumia: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Lumia: 字体大小，默认30
    static func setupHUDConfig_Lumia(fontSize_Lumia: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Lumia = UIFont(name: "AvenirNext-Medium", size: fontSize_Lumia) {
            ProgressHUD.fontStatus = roundedFont_Lumia
        } else if let roundedFont_Lumia = UIFont(name: "Helvetica Neue", size: fontSize_Lumia) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Lumia
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Lumia, weight: .semibold)
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
    static func showLoading_Lumia(message_Lumia: String? = nil) {
        if let message_Lumia = message_Lumia, !message_Lumia.isEmpty {
            ProgressHUD.animate(message_Lumia)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Lumia(
        progress_Lumia: CGFloat,
        message_Lumia: String? = nil
    ) {
        if let message_Lumia = message_Lumia, !message_Lumia.isEmpty {
            ProgressHUD.progress(message_Lumia, progress_Lumia)
        } else {
            ProgressHUD.progress(progress_Lumia)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Lumia() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Lumia(delay_Lumia: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Lumia) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Lumia(
        message_Lumia: String = "Success",
        image_Lumia: UIImage? = nil,
        delay_Lumia: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Lumia)
        dismissLoadingWithDelay_Lumia(delay_Lumia: delay_Lumia)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Lumia(
        message_Lumia: String = "Error",
        image_Lumia: UIImage? = nil,
        delay_Lumia: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Lumia)
        dismissLoadingWithDelay_Lumia(delay_Lumia: delay_Lumia)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Lumia(
        message_Lumia: String,
        delay_Lumia: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Lumia, delay: delay_Lumia)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Lumia(
        message_Lumia: String,
        image_Lumia: UIImage,
        delay_Lumia: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Lumia, delay: delay_Lumia)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Lumia(
        message_Lumia: String,
        symbolName_Lumia: String,
        delay_Lumia: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Lumia, name: symbolName_Lumia)
        dismissLoadingWithDelay_Lumia(delay_Lumia: delay_Lumia)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Lumia(
        message_Lumia: String,
        delay_Lumia: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Lumia(
            message_Lumia: message_Lumia,
            symbolName_Lumia: "exclamationmark.triangle.fill",
            delay_Lumia: delay_Lumia
        )
    }
    
    /// 显示信息提示
    static func showInfo_Lumia(
        message_Lumia: String,
        delay_Lumia: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Lumia(
            message_Lumia: message_Lumia,
            symbolName_Lumia: "info.circle.fill",
            delay_Lumia: delay_Lumia
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Lumia(
        title_Lumia: String = "",
        message_Lumia: String,
        delay_Lumia: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Lumia, message_Lumia, delay: delay_Lumia)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Lumia() {
        ProgressHUD.remove()
    }
}
