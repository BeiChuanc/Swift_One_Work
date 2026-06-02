import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 核心作用：集中管理应用所有主题色、渐变色、强调色与文本色
/// 设计理念：清新自然露营风格——青绿天空 + 暖橙晨光 + 薄荷草地，营造户外探索氛围
struct ColorConfig_Breeze {
    
    // MARK: - 主题渐变色系（晴空清晨）
    
    /// 主渐变起点 - 清爽青绿
    static let primaryGradientStart_Breeze = UIColor(hexstring_Breeze: "#4ECDC4")
    
    /// 主渐变终点 - 天空蓝
    static let primaryGradientEnd_Breeze = UIColor(hexstring_Breeze: "#45B7D1")
    
    /// 辅助渐变起点 - 晨光琥珀橙
    static let secondaryGradientStart_Breeze = UIColor(hexstring_Breeze: "#FFB347")
    
    /// 辅助渐变终点 - 暖阳金黄
    static let secondaryGradientEnd_Breeze = UIColor(hexstring_Breeze: "#FFEAA7")
    
    /// 第三渐变起点 - 薄荷草绿
    static let tertiaryGradientStart_Breeze = UIColor(hexstring_Breeze: "#55EFC4")
    
    /// 第三渐变终点 - 深苔绿
    static let tertiaryGradientEnd_Breeze = UIColor(hexstring_Breeze: "#00B894")
    
    // MARK: - 强调色
    
    /// 珊瑚红（点赞、互动按钮）
    static let accentCoral_Breeze = UIColor(hexstring_Breeze: "#FF6B6B")
    
    /// 琥珀橙（露营分类徽章）
    static let accentAmber_Breeze = UIColor(hexstring_Breeze: "#FFB347")
    
    /// 深苔绿（徒步分类徽章）
    static let accentTeal_Breeze = UIColor(hexstring_Breeze: "#00B894")
    
    /// 晚霞紫（摄影分类徽章）
    static let accentDusk_Breeze = UIColor(hexstring_Breeze: "#A29BFE")
    
    // MARK: - 背景色
    
    /// 主背景色 - 薄荷白（山林晨雾感）
    static let backgroundPrimary_Breeze = UIColor(hexstring_Breeze: "#F0F9F7")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Breeze = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Breeze = UIColor.white
    
    /// 标签背景色 - 极浅薄荷
    static let tagBackground_Breeze = UIColor(hexstring_Breeze: "#E0F5F2")
    
    // MARK: - 文本色
    
    /// 主文本色 - 深森林绿
    static let textPrimary_Breeze = UIColor(hexstring_Breeze: "#1A3C34")
    
    /// 次文本色 - 苔藓绿灰
    static let textSecondary_Breeze = UIColor(hexstring_Breeze: "#4A7066")
    
    /// 占位符文本色 - 雾青
    static let textPlaceholder_Breeze = UIColor(hexstring_Breeze: "#8BB8B0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Breeze = UIColor(hexstring_Breeze: "#CCE9E3")
    
    /// 边框颜色
    static let border_Breeze = UIColor(hexstring_Breeze: "#A8D5CD")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色（带微青绿调）
    static let shadowColor_Breeze = UIColor(hexstring_Breeze: "#2C7A6E", alpha_Breeze: 0.1)
}

// MARK: - UIColor 扩展：渐变图层工厂

extension UIColor {
    
    /// 创建主渐变图层（清爽青绿 → 天空蓝）
    /// - Parameter frame_Breeze: 图层尺寸
    /// - Returns: 配置好的 CAGradientLayer
    static func createPrimaryGradientLayer_Breeze(frame_Breeze: CGRect) -> CAGradientLayer {
        let layer_breeze = CAGradientLayer()
        layer_breeze.frame = frame_Breeze
        layer_breeze.colors = [
            ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
            ColorConfig_Breeze.primaryGradientEnd_Breeze.cgColor
        ]
        layer_breeze.startPoint = CGPoint(x: 0, y: 0)
        layer_breeze.endPoint = CGPoint(x: 1, y: 1)
        return layer_breeze
    }
    
    /// 创建辅助渐变图层（晨光琥珀橙 → 暖阳金黄）
    /// - Parameter frame_Breeze: 图层尺寸
    /// - Returns: 配置好的 CAGradientLayer
    static func createSecondaryGradientLayer_Breeze(frame_Breeze: CGRect) -> CAGradientLayer {
        let layer_breeze = CAGradientLayer()
        layer_breeze.frame = frame_Breeze
        layer_breeze.colors = [
            ColorConfig_Breeze.secondaryGradientStart_Breeze.cgColor,
            ColorConfig_Breeze.secondaryGradientEnd_Breeze.cgColor
        ]
        layer_breeze.startPoint = CGPoint(x: 0, y: 0)
        layer_breeze.endPoint = CGPoint(x: 1, y: 1)
        return layer_breeze
    }
    
    /// 创建第三渐变图层（薄荷草绿 → 深苔绿）
    /// - Parameter frame_Breeze: 图层尺寸
    /// - Returns: 配置好的 CAGradientLayer
    static func createTertiaryGradientLayer_Breeze(frame_Breeze: CGRect) -> CAGradientLayer {
        let layer_breeze = CAGradientLayer()
        layer_breeze.frame = frame_Breeze
        layer_breeze.colors = [
            ColorConfig_Breeze.tertiaryGradientStart_Breeze.cgColor,
            ColorConfig_Breeze.tertiaryGradientEnd_Breeze.cgColor
        ]
        layer_breeze.startPoint = CGPoint(x: 0, y: 0)
        layer_breeze.endPoint = CGPoint(x: 1, y: 1)
        return layer_breeze
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
