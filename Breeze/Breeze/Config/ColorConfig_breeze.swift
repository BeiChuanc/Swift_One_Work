import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Breeze {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Breeze = UIColor(hexstring_Breeze: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Breeze = UIColor(hexstring_Breeze: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Breeze = UIColor(hexstring_Breeze: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Breeze = UIColor(hexstring_Breeze: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Breeze = UIColor(hexstring_Breeze: "#F7FAFC")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Breeze = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Breeze = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰
    static let textPrimary_Breeze = UIColor(hexstring_Breeze: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Breeze = UIColor(hexstring_Breeze: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Breeze = UIColor(hexstring_Breeze: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Breeze = UIColor(hexstring_Breeze: "#E2E8F0")
    
    /// 边框颜色
    static let border_Breeze = UIColor(hexstring_Breeze: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Breeze = UIColor(hexstring_Breeze: "#000000", alpha_Breeze: 0.1)
    
    // MARK: - 强调色（补充）
    
    /// 珊瑚红（点赞心形、互动按钮）
    static let accentCoral_Breeze = UIColor(hexstring_Breeze: "#FF6B6B")
    
    /// 暮色紫（穿搭分类徽章、Tip 详情标签）
    static let accentDusk_Breeze = UIColor(hexstring_Breeze: "#A29BFE")
    
    /// 深苔绿（徒步分类徽章、设置协议图标）
    static let accentTeal_Breeze = UIColor(hexstring_Breeze: "#00B894")
    
    /// 琥珀橙（设置登出图标）
    static let accentAmber_Breeze = UIColor(hexstring_Breeze: "#FFB347")
    
    // MARK: - 第三渐变色系（露营路线主题）
    
    /// 第三渐变起点 - 薄荷草绿
    static let tertiaryGradientStart_Breeze = UIColor(hexstring_Breeze: "#55EFC4")
    
    /// 第三渐变终点 - 深苔绿
    static let tertiaryGradientEnd_Breeze = UIColor(hexstring_Breeze: "#00B894")
    
    // MARK: - 标签背景色
    
    /// 标签背景色 - 极浅薄荷（相册添加按钮、分类芯片背景）
    static let tagBackground_Breeze = UIColor(hexstring_Breeze: "#E0F5F2")
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Breeze: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Breeze(frame_Breeze: CGRect) -> CAGradientLayer {
        let gradientLayer_Breeze = CAGradientLayer()
        gradientLayer_Breeze.frame = frame_Breeze
        gradientLayer_Breeze.colors = [
            ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
            ColorConfig_Breeze.primaryGradientEnd_Breeze.cgColor
        ]
        gradientLayer_Breeze.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Breeze.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Breeze
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Breeze: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Breeze(frame_Breeze: CGRect) -> CAGradientLayer {
        let gradientLayer_Breeze = CAGradientLayer()
        gradientLayer_Breeze.frame = frame_Breeze
        gradientLayer_Breeze.colors = [
            ColorConfig_Breeze.secondaryGradientStart_Breeze.cgColor,
            ColorConfig_Breeze.secondaryGradientEnd_Breeze.cgColor
        ]
        gradientLayer_Breeze.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Breeze.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Breeze
    }
}

// MARK: - PostCategory_Breeze UIKit 扩展

extension PostCategory_Breeze {
    
    /// 分类对应的主题色
    var themeColor_Breeze: UIColor {
        switch self {
        case .all_breeze:         return ColorConfig_Breeze.primaryGradientStart_Breeze
        case .camping_breeze:     return ColorConfig_Breeze.accentAmber_Breeze
        case .hiking_breeze:      return ColorConfig_Breeze.accentTeal_Breeze
        case .nature_breeze:      return ColorConfig_Breeze.tertiaryGradientStart_Breeze
        case .photography_breeze: return ColorConfig_Breeze.accentDusk_Breeze
        }
    }
    
    /// 分类对应的渐变色对（用于徽章渐变背景）
    var gradientColors_Breeze: [CGColor] {
        switch self {
        case .all_breeze:
            return [ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
                    ColorConfig_Breeze.primaryGradientEnd_Breeze.cgColor]
        case .camping_breeze:
            return [ColorConfig_Breeze.accentAmber_Breeze.cgColor,
                    ColorConfig_Breeze.accentCoral_Breeze.cgColor]
        case .hiking_breeze:
            return [ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
                    ColorConfig_Breeze.accentTeal_Breeze.cgColor]
        case .nature_breeze:
            return [ColorConfig_Breeze.tertiaryGradientStart_Breeze.cgColor,
                    ColorConfig_Breeze.tertiaryGradientEnd_Breeze.cgColor]
        case .photography_breeze:
            return [ColorConfig_Breeze.accentDusk_Breeze.cgColor,
                    UIColor(hexstring_Breeze: "#6C5CE7").cgColor]
        }
    }
}
