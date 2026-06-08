import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Utils_Vestir: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Vestir: 字体大小，默认30
    static func setupHUDConfig_Vestir(fontSize_Vestir: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Vestir = UIFont(name: "AvenirNext-Medium", size: fontSize_Vestir) {
            ProgressHUD.fontStatus = roundedFont_Vestir
        } else if let roundedFont_Vestir = UIFont(name: "Helvetica Neue", size: fontSize_Vestir) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Vestir
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Vestir, weight: .semibold)
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
    static func showLoading_Vestir(message_Vestir: String? = nil) {
        if let message_Vestir = message_Vestir, !message_Vestir.isEmpty {
            ProgressHUD.animate(message_Vestir)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Vestir(
        progress_Vestir: CGFloat,
        message_Vestir: String? = nil
    ) {
        if let message_Vestir = message_Vestir, !message_Vestir.isEmpty {
            ProgressHUD.progress(message_Vestir, progress_Vestir)
        } else {
            ProgressHUD.progress(progress_Vestir)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Vestir() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Vestir(delay_Vestir: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Vestir) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Vestir(
        message_Vestir: String = "Success",
        image_Vestir: UIImage? = nil,
        delay_Vestir: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Vestir)
        dismissLoadingWithDelay_Vestir(delay_Vestir: delay_Vestir)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Vestir(
        message_Vestir: String = "Error",
        image_Vestir: UIImage? = nil,
        delay_Vestir: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Vestir)
        dismissLoadingWithDelay_Vestir(delay_Vestir: delay_Vestir)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Vestir(
        message_Vestir: String,
        delay_Vestir: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Vestir, delay: delay_Vestir)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Vestir(
        message_Vestir: String,
        image_Vestir: UIImage,
        delay_Vestir: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Vestir, delay: delay_Vestir)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Vestir(
        message_Vestir: String,
        symbolName_Vestir: String,
        delay_Vestir: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Vestir, name: symbolName_Vestir)
        dismissLoadingWithDelay_Vestir(delay_Vestir: delay_Vestir)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Vestir(
        message_Vestir: String,
        delay_Vestir: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Vestir(
            message_Vestir: message_Vestir,
            symbolName_Vestir: "exclamationmark.triangle.fill",
            delay_Vestir: delay_Vestir
        )
    }
    
    /// 显示信息提示
    static func showInfo_Vestir(
        message_Vestir: String,
        delay_Vestir: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Vestir(
            message_Vestir: message_Vestir,
            symbolName_Vestir: "info.circle.fill",
            delay_Vestir: delay_Vestir
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Vestir(
        title_Vestir: String = "",
        message_Vestir: String,
        delay_Vestir: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Vestir, message_Vestir, delay: delay_Vestir)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Vestir() {
        ProgressHUD.remove()
    }
}
