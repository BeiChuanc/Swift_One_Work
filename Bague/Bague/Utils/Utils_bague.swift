import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Bague: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Bague: 字体大小，默认30
    static func setupHUDConfig_Bague(fontSize_Bague: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Bague = UIFont(name: "AvenirNext-Medium", size: fontSize_Bague) {
            ProgressHUD.fontStatus = roundedFont_Bague
        } else if let roundedFont_Bague = UIFont(name: "Helvetica Neue", size: fontSize_Bague) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Bague
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Bague, weight: .semibold)
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
    static func showLoading_Bague(message_Bague: String? = nil) {
        if let message_Bague = message_Bague, !message_Bague.isEmpty {
            ProgressHUD.animate(message_Bague)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Bague(
        progress_Bague: CGFloat,
        message_Bague: String? = nil
    ) {
        if let message_Bague = message_Bague, !message_Bague.isEmpty {
            ProgressHUD.progress(message_Bague, progress_Bague)
        } else {
            ProgressHUD.progress(progress_Bague)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Bague() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Bague(delay_Bague: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Bague) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Bague(
        message_Bague: String = "Success",
        image_Bague: UIImage? = nil,
        delay_Bague: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Bague)
        dismissLoadingWithDelay_Bague(delay_Bague: delay_Bague)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Bague(
        message_Bague: String = "Error",
        image_Bague: UIImage? = nil,
        delay_Bague: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Bague)
        dismissLoadingWithDelay_Bague(delay_Bague: delay_Bague)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Bague(
        message_Bague: String,
        delay_Bague: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Bague, delay: delay_Bague)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Bague(
        message_Bague: String,
        image_Bague: UIImage,
        delay_Bague: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Bague, delay: delay_Bague)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Bague(
        message_Bague: String,
        symbolName_Bague: String,
        delay_Bague: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Bague, name: symbolName_Bague)
        dismissLoadingWithDelay_Bague(delay_Bague: delay_Bague)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Bague(
        message_Bague: String,
        delay_Bague: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Bague(
            message_Bague: message_Bague,
            symbolName_Bague: "exclamationmark.triangle.fill",
            delay_Bague: delay_Bague
        )
    }
    
    /// 显示信息提示
    static func showInfo_Bague(
        message_Bague: String,
        delay_Bague: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Bague(
            message_Bague: message_Bague,
            symbolName_Bague: "info.circle.fill",
            delay_Bague: delay_Bague
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Bague(
        title_Bague: String = "",
        message_Bague: String,
        delay_Bague: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Bague, message_Bague, delay: delay_Bague)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Bague() {
        ProgressHUD.remove()
    }
}
