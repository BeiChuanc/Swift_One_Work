import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Niche: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Niche: 字体大小，默认30
    static func setupHUDConfig_Niche(fontSize_Niche: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Niche = UIFont(name: "AvenirNext-Medium", size: fontSize_Niche) {
            ProgressHUD.fontStatus = roundedFont_Niche
        } else if let roundedFont_Niche = UIFont(name: "Helvetica Neue", size: fontSize_Niche) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Niche
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Niche, weight: .semibold)
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
    static func showLoading_Niche(message_Niche: String? = nil) {
        if let message_Niche = message_Niche, !message_Niche.isEmpty {
            ProgressHUD.animate(message_Niche)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Niche(
        progress_Niche: CGFloat,
        message_Niche: String? = nil
    ) {
        if let message_Niche = message_Niche, !message_Niche.isEmpty {
            ProgressHUD.progress(message_Niche, progress_Niche)
        } else {
            ProgressHUD.progress(progress_Niche)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Niche() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Niche(delay_Niche: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Niche) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Niche(
        message_Niche: String = "Success",
        image_Niche: UIImage? = nil,
        delay_Niche: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Niche)
        dismissLoadingWithDelay_Niche(delay_Niche: delay_Niche)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Niche(
        message_Niche: String = "Error",
        image_Niche: UIImage? = nil,
        delay_Niche: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Niche)
        dismissLoadingWithDelay_Niche(delay_Niche: delay_Niche)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Niche(
        message_Niche: String,
        delay_Niche: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Niche, delay: delay_Niche)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Niche(
        message_Niche: String,
        image_Niche: UIImage,
        delay_Niche: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Niche, delay: delay_Niche)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Niche(
        message_Niche: String,
        symbolName_Niche: String,
        delay_Niche: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Niche, name: symbolName_Niche)
        dismissLoadingWithDelay_Niche(delay_Niche: delay_Niche)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Niche(
        message_Niche: String,
        delay_Niche: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Niche(
            message_Niche: message_Niche,
            symbolName_Niche: "exclamationmark.triangle.fill",
            delay_Niche: delay_Niche
        )
    }
    
    /// 显示信息提示
    static func showInfo_Niche(
        message_Niche: String,
        delay_Niche: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Niche(
            message_Niche: message_Niche,
            symbolName_Niche: "info.circle.fill",
            delay_Niche: delay_Niche
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Niche(
        title_Niche: String = "",
        message_Niche: String,
        delay_Niche: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Niche, message_Niche, delay: delay_Niche)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Niche() {
        ProgressHUD.remove()
    }
}
