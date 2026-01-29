import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Wanderbell {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Wanderbell = UIColor(hexstring_Wanderbell: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Wanderbell = UIColor(hexstring_Wanderbell: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Wanderbell = UIColor(hexstring_Wanderbell: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Wanderbell = UIColor(hexstring_Wanderbell: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Wanderbell = UIColor(hexstring_Wanderbell: "#F7FAFC")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Wanderbell = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Wanderbell = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰
    static let textPrimary_Wanderbell = UIColor(hexstring_Wanderbell: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Wanderbell = UIColor(hexstring_Wanderbell: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Wanderbell = UIColor(hexstring_Wanderbell: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Wanderbell = UIColor(hexstring_Wanderbell: "#E2E8F0")
    
    /// 边框颜色
    static let border_Wanderbell = UIColor(hexstring_Wanderbell: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Wanderbell = UIColor(hexstring_Wanderbell: "#000000", alpha_Wanderbell: 0.1)
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_wanderbell: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Wanderbell(frame_wanderbell: CGRect) -> CAGradientLayer {
        let gradientLayer_wanderbell = CAGradientLayer()
        gradientLayer_wanderbell.frame = frame_wanderbell
        gradientLayer_wanderbell.colors = [
            ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor,
            ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell.cgColor
        ]
        gradientLayer_wanderbell.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_wanderbell.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_wanderbell
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_wanderbell: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Wanderbell(frame_wanderbell: CGRect) -> CAGradientLayer {
        let gradientLayer_wanderbell = CAGradientLayer()
        gradientLayer_wanderbell.frame = frame_wanderbell
        gradientLayer_wanderbell.colors = [
            ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell.cgColor,
            ColorConfig_Wanderbell.secondaryGradientEnd_Wanderbell.cgColor
        ]
        gradientLayer_wanderbell.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_wanderbell.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_wanderbell
    }
    
    /// 创建情绪渐变图层
    /// 功能：根据情绪类型创建对应的渐变图层
    /// 参数：
    /// - emotionType_wanderbell: 情绪类型
    /// - frame_wanderbell: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createEmotionGradientLayer_Wanderbell(emotionType_wanderbell: EmotionType_Wanderbell, frame_wanderbell: CGRect) -> CAGradientLayer {
        let gradientLayer_wanderbell = CAGradientLayer()
        gradientLayer_wanderbell.frame = frame_wanderbell
        
        let baseColor_wanderbell = emotionType_wanderbell.getColor_Wanderbell()
        let lighterColor_wanderbell = baseColor_wanderbell.withAlphaComponent(0.7)
        
        gradientLayer_wanderbell.colors = [
            lighterColor_wanderbell.cgColor,
            baseColor_wanderbell.cgColor
        ]
        gradientLayer_wanderbell.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_wanderbell.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_wanderbell
    }
}
