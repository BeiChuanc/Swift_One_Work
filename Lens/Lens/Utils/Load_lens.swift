import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Load_Lens: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Lens: 字体大小，默认30
    static func setupHUDConfig_Lens(fontSize_Lens: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Lens = UIFont(name: "AvenirNext-Medium", size: fontSize_Lens) {
            ProgressHUD.fontStatus = roundedFont_Lens
        } else if let roundedFont_Lens = UIFont(name: "Helvetica Neue", size: fontSize_Lens) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Lens
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Lens, weight: .semibold)
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
    static func showLoading_Lens(message_Lens: String? = nil) {
        if let message_Lens = message_Lens, !message_Lens.isEmpty {
            ProgressHUD.animate(message_Lens)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Lens(
        progress_Lens: CGFloat,
        message_Lens: String? = nil
    ) {
        if let message_Lens = message_Lens, !message_Lens.isEmpty {
            ProgressHUD.progress(message_Lens, progress_Lens)
        } else {
            ProgressHUD.progress(progress_Lens)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Lens() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Lens(delay_Lens: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Lens) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Lens(
        message_Lens: String = "Success",
        image_Lens: UIImage? = nil,
        delay_Lens: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Lens)
        dismissLoadingWithDelay_Lens(delay_Lens: delay_Lens)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Lens(
        message_Lens: String = "Error",
        image_Lens: UIImage? = nil,
        delay_Lens: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Lens)
        dismissLoadingWithDelay_Lens(delay_Lens: delay_Lens)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Lens(
        message_Lens: String,
        delay_Lens: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Lens, delay: delay_Lens)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Lens(
        message_Lens: String,
        image_Lens: UIImage,
        delay_Lens: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Lens, delay: delay_Lens)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Lens(
        message_Lens: String,
        symbolName_Lens: String,
        delay_Lens: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Lens, name: symbolName_Lens)
        dismissLoadingWithDelay_Lens(delay_Lens: delay_Lens)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Lens(
        message_Lens: String,
        delay_Lens: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Lens(
            message_Lens: message_Lens,
            symbolName_Lens: "exclamationmark.triangle.fill",
            delay_Lens: delay_Lens
        )
    }
    
    /// 显示信息提示
    static func showInfo_Lens(
        message_Lens: String,
        delay_Lens: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Lens(
            message_Lens: message_Lens,
            symbolName_Lens: "info.circle.fill",
            delay_Lens: delay_Lens
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Lens(
        title_Lens: String = "",
        message_Lens: String,
        delay_Lens: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Lens, message_Lens, delay: delay_Lens)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Lens() {
        ProgressHUD.remove()
    }
}
