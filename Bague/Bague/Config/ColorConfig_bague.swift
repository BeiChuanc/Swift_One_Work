import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Bague {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Bague = UIColor(hexstring_Bague: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Bague = UIColor(hexstring_Bague: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Bague = UIColor(hexstring_Bague: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Bague = UIColor(hexstring_Bague: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Bague = UIColor(hexstring_Bague: "#F7FAFC")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Bague = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Bague = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰
    static let textPrimary_Bague = UIColor(hexstring_Bague: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Bague = UIColor(hexstring_Bague: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Bague = UIColor(hexstring_Bague: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Bague = UIColor(hexstring_Bague: "#E2E8F0")
    
    /// 边框颜色
    static let border_Bague = UIColor(hexstring_Bague: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Bague = UIColor(hexstring_Bague: "#000000", alpha_Bague: 0.1)
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Bague: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Bague(frame_Bague: CGRect) -> CAGradientLayer {
        let gradientLayer_Bague = CAGradientLayer()
        gradientLayer_Bague.frame = frame_Bague
        gradientLayer_Bague.colors = [
            ColorConfig_Bague.primaryGradientStart_Bague.cgColor,
            ColorConfig_Bague.primaryGradientEnd_Bague.cgColor
        ]
        gradientLayer_Bague.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Bague.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Bague
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Bague: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Bague(frame_Bague: CGRect) -> CAGradientLayer {
        let gradientLayer_Bague = CAGradientLayer()
        gradientLayer_Bague.frame = frame_Bague
        gradientLayer_Bague.colors = [
            ColorConfig_Bague.secondaryGradientStart_Bague.cgColor,
            ColorConfig_Bague.secondaryGradientEnd_Bague.cgColor
        ]
        gradientLayer_Bague.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Bague.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Bague
    }
}
