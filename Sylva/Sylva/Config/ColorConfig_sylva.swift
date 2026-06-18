import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Sylva {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Sylva = UIColor(hexstring_Sylva: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Sylva = UIColor(hexstring_Sylva: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Sylva = UIColor(hexstring_Sylva: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Sylva = UIColor(hexstring_Sylva: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Sylva = UIColor(hexstring_Sylva: "#F7FAFC")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Sylva = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Sylva = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰
    static let textPrimary_Sylva = UIColor(hexstring_Sylva: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Sylva = UIColor(hexstring_Sylva: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Sylva = UIColor(hexstring_Sylva: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Sylva = UIColor(hexstring_Sylva: "#E2E8F0")
    
    /// 边框颜色
    static let border_Sylva = UIColor(hexstring_Sylva: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Sylva = UIColor(hexstring_Sylva: "#000000", alpha_Sylva: 0.1)
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Sylva: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Sylva(frame_Sylva: CGRect) -> CAGradientLayer {
        let gradientLayer_Sylva = CAGradientLayer()
        gradientLayer_Sylva.frame = frame_Sylva
        gradientLayer_Sylva.colors = [
            ColorConfig_Sylva.primaryGradientStart_Sylva.cgColor,
            ColorConfig_Sylva.primaryGradientEnd_Sylva.cgColor
        ]
        gradientLayer_Sylva.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sylva.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Sylva
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Sylva: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Sylva(frame_Sylva: CGRect) -> CAGradientLayer {
        let gradientLayer_Sylva = CAGradientLayer()
        gradientLayer_Sylva.frame = frame_Sylva
        gradientLayer_Sylva.colors = [
            ColorConfig_Sylva.secondaryGradientStart_Sylva.cgColor,
            ColorConfig_Sylva.secondaryGradientEnd_Sylva.cgColor
        ]
        gradientLayer_Sylva.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sylva.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Sylva
    }
}
