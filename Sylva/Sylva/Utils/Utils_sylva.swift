import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Sylva: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Sylva: 字体大小，默认30
    static func setupHUDConfig_Sylva(fontSize_Sylva: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Sylva = UIFont(name: "AvenirNext-Medium", size: fontSize_Sylva) {
            ProgressHUD.fontStatus = roundedFont_Sylva
        } else if let roundedFont_Sylva = UIFont(name: "Helvetica Neue", size: fontSize_Sylva) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Sylva
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Sylva, weight: .semibold)
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
    static func showLoading_Sylva(message_Sylva: String? = nil) {
        if let message_Sylva = message_Sylva, !message_Sylva.isEmpty {
            ProgressHUD.animate(message_Sylva)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Sylva(
        progress_Sylva: CGFloat,
        message_Sylva: String? = nil
    ) {
        if let message_Sylva = message_Sylva, !message_Sylva.isEmpty {
            ProgressHUD.progress(message_Sylva, progress_Sylva)
        } else {
            ProgressHUD.progress(progress_Sylva)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Sylva() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Sylva(delay_Sylva: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Sylva) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Sylva(
        message_Sylva: String = "Success",
        image_Sylva: UIImage? = nil,
        delay_Sylva: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Sylva)
        dismissLoadingWithDelay_Sylva(delay_Sylva: delay_Sylva)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Sylva(
        message_Sylva: String = "Error",
        image_Sylva: UIImage? = nil,
        delay_Sylva: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Sylva)
        dismissLoadingWithDelay_Sylva(delay_Sylva: delay_Sylva)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Sylva(
        message_Sylva: String,
        delay_Sylva: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Sylva, delay: delay_Sylva)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Sylva(
        message_Sylva: String,
        image_Sylva: UIImage,
        delay_Sylva: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Sylva, delay: delay_Sylva)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Sylva(
        message_Sylva: String,
        symbolName_Sylva: String,
        delay_Sylva: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Sylva, name: symbolName_Sylva)
        dismissLoadingWithDelay_Sylva(delay_Sylva: delay_Sylva)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Sylva(
        message_Sylva: String,
        delay_Sylva: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Sylva(
            message_Sylva: message_Sylva,
            symbolName_Sylva: "exclamationmark.triangle.fill",
            delay_Sylva: delay_Sylva
        )
    }
    
    /// 显示信息提示
    static func showInfo_Sylva(
        message_Sylva: String,
        delay_Sylva: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Sylva(
            message_Sylva: message_Sylva,
            symbolName_Sylva: "info.circle.fill",
            delay_Sylva: delay_Sylva
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Sylva(
        title_Sylva: String = "",
        message_Sylva: String,
        delay_Sylva: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Sylva, message_Sylva, delay: delay_Sylva)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Sylva() {
        ProgressHUD.remove()
    }
}
