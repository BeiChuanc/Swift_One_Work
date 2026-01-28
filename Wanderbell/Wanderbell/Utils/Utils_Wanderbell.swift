import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Wanderbell: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    static func setupHUDConfig_Wanderbell(fontSize_wanderbell: CGFloat = 16) {
        // 设置字体
        ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_wanderbell)
        
        // 设置动画类型
        ProgressHUD.animationType = .circleStrokeSpin
        
        // 设置媒体大小
        ProgressHUD.mediaSize = 60
    }
    
    // MARK: - 加载动画
    
    /// 显示加载动画
    static func showLoading_Wanderbell(message_wanderbell: String? = nil) {
        if let message_wanderbell = message_wanderbell, !message_wanderbell.isEmpty {
            ProgressHUD.animate(message_wanderbell)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Wanderbell(
        progress_wanderbell: CGFloat,
        message_wanderbell: String? = nil
    ) {
        if let message_wanderbell = message_wanderbell, !message_wanderbell.isEmpty {
            ProgressHUD.progress(message_wanderbell, progress_wanderbell)
        } else {
            ProgressHUD.progress(progress_wanderbell)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Wanderbell() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Wanderbell(delay_wanderbell: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_wanderbell) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Wanderbell(
        message_wanderbell: String = "Success",
        image_wanderbell: UIImage? = nil,
        delay_wanderbell: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_wanderbell)
        dismissLoadingWithDelay_Wanderbell(delay_wanderbell: delay_wanderbell)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Wanderbell(
        message_wanderbell: String = "Error",
        image_wanderbell: UIImage? = nil,
        delay_wanderbell: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_wanderbell)
        dismissLoadingWithDelay_Wanderbell(delay_wanderbell: delay_wanderbell)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Wanderbell(
        message_wanderbell: String,
        delay_wanderbell: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_wanderbell, delay: delay_wanderbell)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Wanderbell(
        message_wanderbell: String,
        image_wanderbell: UIImage,
        delay_wanderbell: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_wanderbell, delay: delay_wanderbell)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Wanderbell(
        message_wanderbell: String,
        symbolName_wanderbell: String,
        delay_wanderbell: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_wanderbell, name: symbolName_wanderbell)
        dismissLoadingWithDelay_Wanderbell(delay_wanderbell: delay_wanderbell)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Wanderbell(
        message_wanderbell: String,
        delay_wanderbell: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Wanderbell(
            message_wanderbell: message_wanderbell,
            symbolName_wanderbell: "exclamationmark.triangle.fill",
            delay_wanderbell: delay_wanderbell
        )
    }
    
    /// 显示信息提示
    static func showInfo_Wanderbell(
        message_wanderbell: String,
        delay_wanderbell: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Wanderbell(
            message_wanderbell: message_wanderbell,
            symbolName_wanderbell: "info.circle.fill",
            delay_wanderbell: delay_wanderbell
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Wanderbell(
        title_wanderbell: String = "",
        message_wanderbell: String,
        delay_wanderbell: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_wanderbell, message_wanderbell, delay: delay_wanderbell)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Wanderbell() {
        ProgressHUD.remove()
    }
}
