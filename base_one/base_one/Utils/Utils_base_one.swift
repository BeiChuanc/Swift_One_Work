import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Base_one: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    static func setupHUDConfig_Base_one(fontSize_base_one: CGFloat = 16) {
        // 设置字体
        ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_base_one)
        
        // 设置动画类型
        ProgressHUD.animationType = .circleStrokeSpin
        
        // 设置媒体大小
        ProgressHUD.mediaSize = 60
    }
    
    // MARK: - 加载动画
    
    /// 显示加载动画
    static func showLoading_Base_one(message_base_one: String? = nil) {
        if let message_base_one = message_base_one, !message_base_one.isEmpty {
            ProgressHUD.animate(message_base_one)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Base_one(
        progress_base_one: CGFloat,
        message_base_one: String? = nil
    ) {
        if let message_base_one = message_base_one, !message_base_one.isEmpty {
            ProgressHUD.progress(message_base_one, progress_base_one)
        } else {
            ProgressHUD.progress(progress_base_one)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Base_one() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Base_one(delay_base_one: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_base_one) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Base_one(
        message_base_one: String = "Success",
        image_base_one: UIImage? = nil,
        delay_base_one: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_base_one)
        dismissLoadingWithDelay_Base_one(delay_base_one: delay_base_one)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Base_one(
        message_base_one: String = "Error",
        image_base_one: UIImage? = nil,
        delay_base_one: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_base_one)
        dismissLoadingWithDelay_Base_one(delay_base_one: delay_base_one)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Base_one(
        message_base_one: String,
        delay_base_one: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_base_one, delay: delay_base_one)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Base_one(
        message_base_one: String,
        image_base_one: UIImage,
        delay_base_one: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_base_one, delay: delay_base_one)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Base_one(
        message_base_one: String,
        symbolName_base_one: String,
        delay_base_one: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_base_one, name: symbolName_base_one)
        dismissLoadingWithDelay_Base_one(delay_base_one: delay_base_one)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Base_one(
        message_base_one: String,
        delay_base_one: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Base_one(
            message_base_one: message_base_one,
            symbolName_base_one: "exclamationmark.triangle.fill",
            delay_base_one: delay_base_one
        )
    }
    
    /// 显示信息提示
    static func showInfo_Base_one(
        message_base_one: String,
        delay_base_one: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Base_one(
            message_base_one: message_base_one,
            symbolName_base_one: "info.circle.fill",
            delay_base_one: delay_base_one
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Base_one(
        title_base_one: String = "",
        message_base_one: String,
        delay_base_one: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_base_one, message_base_one, delay: delay_base_one)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Base_one() {
        ProgressHUD.remove()
    }
}
