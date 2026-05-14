import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Echd {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Echd = UIColor(hexstring_Echd: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Echd = UIColor(hexstring_Echd: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Echd = UIColor(hexstring_Echd: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Echd = UIColor(hexstring_Echd: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Echd = UIColor(hexstring_Echd: "#F7FAFC")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Echd = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Echd = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰
    static let textPrimary_Echd = UIColor(hexstring_Echd: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Echd = UIColor(hexstring_Echd: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Echd = UIColor(hexstring_Echd: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Echd = UIColor(hexstring_Echd: "#E2E8F0")
    
    /// 边框颜色
    static let border_Echd = UIColor(hexstring_Echd: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Echd = UIColor(hexstring_Echd: "#000000", alpha_Echd: 0.1)
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Echd: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Echd(frame_Echd: CGRect) -> CAGradientLayer {
        let gradientLayer_Echd = CAGradientLayer()
        gradientLayer_Echd.frame = frame_Echd
        gradientLayer_Echd.colors = [
            ColorConfig_Echd.primaryGradientStart_Echd.cgColor,
            ColorConfig_Echd.primaryGradientEnd_Echd.cgColor
        ]
        gradientLayer_Echd.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Echd.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Echd
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Echd: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Echd(frame_Echd: CGRect) -> CAGradientLayer {
        let gradientLayer_Echd = CAGradientLayer()
        gradientLayer_Echd.frame = frame_Echd
        gradientLayer_Echd.colors = [
            ColorConfig_Echd.secondaryGradientStart_Echd.cgColor,
            ColorConfig_Echd.secondaryGradientEnd_Echd.cgColor
        ]
        gradientLayer_Echd.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Echd.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Echd
    }
}
