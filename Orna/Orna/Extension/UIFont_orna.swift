import Foundation
import UIKit

// MARK: - UIFont 扩展

/// 全局统一的"趣味"字体扩展
/// 核心作用：为应用内多处（Apple 登录按钮、视频通话、商店/订阅页等）提供统一调用的
/// funFont_Orna 字体方法，避免各页面各自定义不一致的字体逻辑
/// 设计思路：
///   - 优先采用系统圆体设计（Rounded Design），让文字风格更贴近"桌面摆件"主题温暖、圆润、
///     有趣的视觉基调，与卡片圆角、渐变色等整体设计语言保持一致
///   - 若当前字重/尺寸下系统不支持圆体设计描述符，自动降级为标准系统字体，
///     保证任意 iOS 版本下都有稳定可用的显示效果，不影响可读性与业务逻辑闭环
extension UIFont {

    /// 获取应用内统一的"趣味"字体
    /// 参数：
    /// - size: 字号
    /// - weight: 字重，默认 regular
    /// 返回：可直接用于 UILabel / UITextView / UIButton 等控件的 UIFont 实例
    static func funFont_Orna(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let baseFont_orna = UIFont.systemFont(ofSize: size, weight: weight)
        guard let roundedDescriptor_orna = baseFont_orna.fontDescriptor.withDesign(.rounded) else {
            return baseFont_orna
        }
        return UIFont(descriptor: roundedDescriptor_orna, size: size)
    }
}
