import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色系，基于「Hush 街头随拍」调性调和
/// 设计理念：暗夜橙红主渐变（街头霓虹/黄金时刻）+ 炭灰辅调（纪录片质感）+ 暖纸白背景（胶片底色）
struct ColorConfig_Hush {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变起始色 - 街头橙（黄金时刻路灯色）
    static let primaryGradientStart_Hush = UIColor(hexstring_Hush: "#FF6B35")
    
    /// 主渐变结束色 - 暗红玫瑰（霓虹反光）
    static let primaryGradientEnd_Hush = UIColor(hexstring_Hush: "#C0392B")
    
    /// 辅助渐变起始色 - 薄暮靛蓝（蓝调时刻天空）
    static let secondaryGradientStart_Hush = UIColor(hexstring_Hush: "#3A3D8F")
    
    /// 辅助渐变结束色 - 深钢炭（暗巷阴影）
    static let secondaryGradientEnd_Hush = UIColor(hexstring_Hush: "#2C2F3A")
    
    // MARK: - 背景色
    
    /// 主背景色 - 暖纸白（模拟胶片相纸底色）
    static let backgroundPrimary_Hush = UIColor(hexstring_Hush: "#F9F7F4")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Hush = UIColor.white
    
    /// 卡片背景色 - 纯白
    static let cardBackground_Hush = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 近黑（印刷级深度）
    static let textPrimary_Hush = UIColor(hexstring_Hush: "#1A1B25")
    
    /// 次文本色 - 中性灰
    static let textSecondary_Hush = UIColor(hexstring_Hush: "#6B7280")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Hush = UIColor(hexstring_Hush: "#9CA3AF")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Hush = UIColor(hexstring_Hush: "#E5E7EB")
    
    /// 边框颜色
    static let border_Hush = UIColor(hexstring_Hush: "#D1D5DB")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Hush = UIColor(hexstring_Hush: "#000000", alpha_Hush: 0.08)
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Hush: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Hush(frame_Hush: CGRect) -> CAGradientLayer {
        let gradientLayer_Hush = CAGradientLayer()
        gradientLayer_Hush.frame = frame_Hush
        gradientLayer_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        gradientLayer_Hush.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Hush.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Hush
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Hush: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Hush(frame_Hush: CGRect) -> CAGradientLayer {
        let gradientLayer_Hush = CAGradientLayer()
        gradientLayer_Hush.frame = frame_Hush
        gradientLayer_Hush.colors = [
            ColorConfig_Hush.secondaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.secondaryGradientEnd_Hush.cgColor
        ]
        gradientLayer_Hush.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Hush.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Hush
    }
}
