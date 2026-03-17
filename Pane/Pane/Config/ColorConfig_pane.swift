import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Pane {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Pane = UIColor(hexstring_Pane: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Pane = UIColor(hexstring_Pane: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Pane = UIColor(hexstring_Pane: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Pane = UIColor(hexstring_Pane: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 暖奶白（带微黄暖意）
    static let backgroundPrimary_Pane = UIColor(hexstring_Pane: "#FFF8F0")
    
    /// 次背景色 - 暖象牙白
    static let backgroundSecondary_Pane = UIColor(hexstring_Pane: "#FFFCF5")
    
    /// 卡片背景色 - 微暖白
    static let cardBackground_Pane = UIColor(hexstring_Pane: "#FFFDF8")
    
    // MARK: - 文本色
    
    /// 主文本色 - 暖深棕
    static let textPrimary_Pane = UIColor(hexstring_Pane: "#3D2B1F")
    
    /// 次文本色 - 暖中灰
    static let textSecondary_Pane = UIColor(hexstring_Pane: "#7C6B5C")
    
    /// 占位符文本色 - 暖浅灰
    static let textPlaceholder_Pane = UIColor(hexstring_Pane: "#B8A898")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色 - 暖米色
    static let divider_Pane = UIColor(hexstring_Pane: "#EDE0CE")
    
    /// 边框颜色 - 暖棕色
    static let border_Pane = UIColor(hexstring_Pane: "#DECDB8")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色 - 暖棕阴影
    static let shadowColor_Pane = UIColor(hexstring_Pane: "#C08040", alpha_Pane: 0.1)
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Pane: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Pane(frame_Pane: CGRect) -> CAGradientLayer {
        let gradientLayer_Pane = CAGradientLayer()
        gradientLayer_Pane.frame = frame_Pane
        gradientLayer_Pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gradientLayer_Pane.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Pane.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Pane
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Pane: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Pane(frame_Pane: CGRect) -> CAGradientLayer {
        let gradientLayer_Pane = CAGradientLayer()
        gradientLayer_Pane.frame = frame_Pane
        gradientLayer_Pane.colors = [
            ColorConfig_Pane.secondaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.secondaryGradientEnd_Pane.cgColor
        ]
        gradientLayer_Pane.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Pane.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Pane
    }
}
