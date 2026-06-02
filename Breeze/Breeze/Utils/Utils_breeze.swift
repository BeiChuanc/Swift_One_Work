import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Breeze: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Breeze: 字体大小，默认30
    static func setupHUDConfig_Breeze(fontSize_Breeze: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Breeze = UIFont(name: "AvenirNext-Medium", size: fontSize_Breeze) {
            ProgressHUD.fontStatus = roundedFont_Breeze
        } else if let roundedFont_Breeze = UIFont(name: "Helvetica Neue", size: fontSize_Breeze) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Breeze
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Breeze, weight: .semibold)
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
    static func showLoading_Breeze(message_Breeze: String? = nil) {
        if let message_Breeze = message_Breeze, !message_Breeze.isEmpty {
            ProgressHUD.animate(message_Breeze)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Breeze(
        progress_Breeze: CGFloat,
        message_Breeze: String? = nil
    ) {
        if let message_Breeze = message_Breeze, !message_Breeze.isEmpty {
            ProgressHUD.progress(message_Breeze, progress_Breeze)
        } else {
            ProgressHUD.progress(progress_Breeze)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Breeze() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Breeze(delay_Breeze: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Breeze) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Breeze(
        message_Breeze: String = "Success",
        image_Breeze: UIImage? = nil,
        delay_Breeze: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Breeze)
        dismissLoadingWithDelay_Breeze(delay_Breeze: delay_Breeze)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Breeze(
        message_Breeze: String = "Error",
        image_Breeze: UIImage? = nil,
        delay_Breeze: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Breeze)
        dismissLoadingWithDelay_Breeze(delay_Breeze: delay_Breeze)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Breeze(
        message_Breeze: String,
        delay_Breeze: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Breeze, delay: delay_Breeze)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Breeze(
        message_Breeze: String,
        image_Breeze: UIImage,
        delay_Breeze: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Breeze, delay: delay_Breeze)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Breeze(
        message_Breeze: String,
        symbolName_Breeze: String,
        delay_Breeze: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Breeze, name: symbolName_Breeze)
        dismissLoadingWithDelay_Breeze(delay_Breeze: delay_Breeze)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Breeze(
        message_Breeze: String,
        delay_Breeze: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Breeze(
            message_Breeze: message_Breeze,
            symbolName_Breeze: "exclamationmark.triangle.fill",
            delay_Breeze: delay_Breeze
        )
    }
    
    /// 显示信息提示
    static func showInfo_Breeze(
        message_Breeze: String,
        delay_Breeze: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Breeze(
            message_Breeze: message_Breeze,
            symbolName_Breeze: "info.circle.fill",
            delay_Breeze: delay_Breeze
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Breeze(
        title_Breeze: String = "",
        message_Breeze: String,
        delay_Breeze: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Breeze, message_Breeze, delay: delay_Breeze)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Breeze() {
        ProgressHUD.remove()
    }
}
