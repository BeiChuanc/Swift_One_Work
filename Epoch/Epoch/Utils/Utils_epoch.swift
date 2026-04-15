import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Epoch: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Epoch: 字体大小，默认30
    static func setupHUDConfig_Epoch(fontSize_Epoch: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Epoch = UIFont(name: "AvenirNext-Medium", size: fontSize_Epoch) {
            ProgressHUD.fontStatus = roundedFont_Epoch
        } else if let roundedFont_Epoch = UIFont(name: "Helvetica Neue", size: fontSize_Epoch) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Epoch
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Epoch, weight: .semibold)
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
    static func showLoading_Epoch(message_Epoch: String? = nil) {
        if let message_Epoch = message_Epoch, !message_Epoch.isEmpty {
            ProgressHUD.animate(message_Epoch)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Epoch(
        progress_Epoch: CGFloat,
        message_Epoch: String? = nil
    ) {
        if let message_Epoch = message_Epoch, !message_Epoch.isEmpty {
            ProgressHUD.progress(message_Epoch, progress_Epoch)
        } else {
            ProgressHUD.progress(progress_Epoch)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Epoch() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Epoch(delay_Epoch: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Epoch) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Epoch(
        message_Epoch: String = "Success",
        image_Epoch: UIImage? = nil,
        delay_Epoch: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Epoch)
        dismissLoadingWithDelay_Epoch(delay_Epoch: delay_Epoch)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Epoch(
        message_Epoch: String = "Error",
        image_Epoch: UIImage? = nil,
        delay_Epoch: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Epoch)
        dismissLoadingWithDelay_Epoch(delay_Epoch: delay_Epoch)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Epoch(
        message_Epoch: String,
        delay_Epoch: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Epoch, delay: delay_Epoch)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Epoch(
        message_Epoch: String,
        image_Epoch: UIImage,
        delay_Epoch: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Epoch, delay: delay_Epoch)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Epoch(
        message_Epoch: String,
        symbolName_Epoch: String,
        delay_Epoch: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Epoch, name: symbolName_Epoch)
        dismissLoadingWithDelay_Epoch(delay_Epoch: delay_Epoch)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Epoch(
        message_Epoch: String,
        delay_Epoch: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Epoch(
            message_Epoch: message_Epoch,
            symbolName_Epoch: "exclamationmark.triangle.fill",
            delay_Epoch: delay_Epoch
        )
    }
    
    /// 显示信息提示
    static func showInfo_Epoch(
        message_Epoch: String,
        delay_Epoch: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Epoch(
            message_Epoch: message_Epoch,
            symbolName_Epoch: "info.circle.fill",
            delay_Epoch: delay_Epoch
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Epoch(
        title_Epoch: String = "",
        message_Epoch: String,
        delay_Epoch: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Epoch, message_Epoch, delay: delay_Epoch)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Epoch() {
        ProgressHUD.remove()
    }
}
