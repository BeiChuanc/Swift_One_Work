import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Echd: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Echd: 字体大小，默认30
    static func setupHUDConfig_Echd(fontSize_Echd: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Echd = UIFont(name: "AvenirNext-Medium", size: fontSize_Echd) {
            ProgressHUD.fontStatus = roundedFont_Echd
        } else if let roundedFont_Echd = UIFont(name: "Helvetica Neue", size: fontSize_Echd) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Echd
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Echd, weight: .semibold)
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
    static func showLoading_Echd(message_Echd: String? = nil) {
        if let message_Echd = message_Echd, !message_Echd.isEmpty {
            ProgressHUD.animate(message_Echd)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Echd(
        progress_Echd: CGFloat,
        message_Echd: String? = nil
    ) {
        if let message_Echd = message_Echd, !message_Echd.isEmpty {
            ProgressHUD.progress(message_Echd, progress_Echd)
        } else {
            ProgressHUD.progress(progress_Echd)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Echd() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Echd(delay_Echd: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Echd) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Echd(
        message_Echd: String = "Success",
        image_Echd: UIImage? = nil,
        delay_Echd: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Echd)
        dismissLoadingWithDelay_Echd(delay_Echd: delay_Echd)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Echd(
        message_Echd: String = "Error",
        image_Echd: UIImage? = nil,
        delay_Echd: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Echd)
        dismissLoadingWithDelay_Echd(delay_Echd: delay_Echd)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Echd(
        message_Echd: String,
        delay_Echd: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Echd, delay: delay_Echd)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Echd(
        message_Echd: String,
        image_Echd: UIImage,
        delay_Echd: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Echd, delay: delay_Echd)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Echd(
        message_Echd: String,
        symbolName_Echd: String,
        delay_Echd: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Echd, name: symbolName_Echd)
        dismissLoadingWithDelay_Echd(delay_Echd: delay_Echd)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Echd(
        message_Echd: String,
        delay_Echd: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Echd(
            message_Echd: message_Echd,
            symbolName_Echd: "exclamationmark.triangle.fill",
            delay_Echd: delay_Echd
        )
    }
    
    /// 显示信息提示
    static func showInfo_Echd(
        message_Echd: String,
        delay_Echd: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Echd(
            message_Echd: message_Echd,
            symbolName_Echd: "info.circle.fill",
            delay_Echd: delay_Echd
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Echd(
        title_Echd: String = "",
        message_Echd: String,
        delay_Echd: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Echd, message_Echd, delay: delay_Echd)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Echd() {
        ProgressHUD.remove()
    }
}
