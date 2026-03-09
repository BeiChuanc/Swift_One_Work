import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Moode: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Moode: 字体大小，默认30
    static func setupHUDConfig_Moode(fontSize_Moode: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Moode = UIFont(name: "AvenirNext-Medium", size: fontSize_Moode) {
            ProgressHUD.fontStatus = roundedFont_Moode
        } else if let roundedFont_Moode = UIFont(name: "Helvetica Neue", size: fontSize_Moode) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Moode
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Moode, weight: .semibold)
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
    static func showLoading_Moode(message_Moode: String? = nil) {
        if let message_Moode = message_Moode, !message_Moode.isEmpty {
            ProgressHUD.animate(message_Moode)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Moode(
        progress_Moode: CGFloat,
        message_Moode: String? = nil
    ) {
        if let message_Moode = message_Moode, !message_Moode.isEmpty {
            ProgressHUD.progress(message_Moode, progress_Moode)
        } else {
            ProgressHUD.progress(progress_Moode)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Moode() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Moode(delay_Moode: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Moode) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Moode(
        message_Moode: String = "Success",
        image_Moode: UIImage? = nil,
        delay_Moode: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Moode)
        dismissLoadingWithDelay_Moode(delay_Moode: delay_Moode)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Moode(
        message_Moode: String = "Error",
        image_Moode: UIImage? = nil,
        delay_Moode: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Moode)
        dismissLoadingWithDelay_Moode(delay_Moode: delay_Moode)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Moode(
        message_Moode: String,
        delay_Moode: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Moode, delay: delay_Moode)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Moode(
        message_Moode: String,
        image_Moode: UIImage,
        delay_Moode: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Moode, delay: delay_Moode)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Moode(
        message_Moode: String,
        symbolName_Moode: String,
        delay_Moode: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Moode, name: symbolName_Moode)
        dismissLoadingWithDelay_Moode(delay_Moode: delay_Moode)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Moode(
        message_Moode: String,
        delay_Moode: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Moode(
            message_Moode: message_Moode,
            symbolName_Moode: "exclamationmark.triangle.fill",
            delay_Moode: delay_Moode
        )
    }
    
    /// 显示信息提示
    static func showInfo_Moode(
        message_Moode: String,
        delay_Moode: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Moode(
            message_Moode: message_Moode,
            symbolName_Moode: "info.circle.fill",
            delay_Moode: delay_Moode
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Moode(
        title_Moode: String = "",
        message_Moode: String,
        delay_Moode: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Moode, message_Moode, delay: delay_Moode)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Moode() {
        ProgressHUD.remove()
    }
}
