import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：清新家居感、明快有质感，以薄荷绿为主调、珊瑚暖色为点缀，呈现整洁灵动的现代家居氛围
struct ColorConfig_Tidy {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色起点 - 薰衣草紫
    static let primaryGradientStart_Tidy = UIColor(hexstring_Tidy: "#B794F6")
    
    /// 主渐变色终点 - 天空蓝
    static let primaryGradientEnd_Tidy = UIColor(hexstring_Tidy: "#90CDF4")
    
    /// 辅助渐变色起点 - 玫瑰粉
    static let secondaryGradientStart_Tidy = UIColor(hexstring_Tidy: "#FBB6CE")
    
    /// 辅助渐变色终点 - 珊瑚橙
    static let secondaryGradientEnd_Tidy = UIColor(hexstring_Tidy: "#FED7AA")
    
    // MARK: - Tidy 专属品牌色
    
    /// 主强调色 - 清新薄荷绿（品牌核心色，用于 CTA、选中态、高亮）
    static let tidyMint_Tidy = UIColor(hexstring_Tidy: "#4ECDC4")
    
    /// 薄荷渐变深色（渐变结束色，比主色略深）
    static let tidyMintDeep_Tidy = UIColor(hexstring_Tidy: "#38B2AC")
    
    /// 暖珊瑚色（互动反馈、点赞等暖色高亮）
    static let tidyWarm_Tidy = UIColor(hexstring_Tidy: "#FF6B6B")
    
    /// 米白背景色（首页 Header 底色，温暖中性）
    static let tidySand_Tidy = UIColor(hexstring_Tidy: "#F7F3EE")
    
    /// 柔金色（徽章、统计数字装饰）
    static let tidyGold_Tidy = UIColor(hexstring_Tidy: "#F6AD55")
    
    // MARK: - 分类主题色（7 个分类，对应 HomeCategory id）
    
    /// 分类色：客厅 - 淡蓝绿
    static let categoryLivingRoom_Tidy = UIColor(hexstring_Tidy: "#4ECDC4")
    
    /// 分类色：卧室 - 薰衣草紫
    static let categoryBedroom_Tidy = UIColor(hexstring_Tidy: "#9F7AEA")
    
    /// 分类色：厨房 - 暖橙
    static let categoryKitchen_Tidy = UIColor(hexstring_Tidy: "#F6AD55")
    
    /// 分类色：浴室 - 水蓝
    static let categoryBathroom_Tidy = UIColor(hexstring_Tidy: "#63B3ED")
    
    /// 分类色：书房 - 森绿
    static let categoryStudy_Tidy = UIColor(hexstring_Tidy: "#68D391")
    
    /// 分类色：收纳 - 玫瑰粉
    static let categoryStorage_Tidy = UIColor(hexstring_Tidy: "#FC8181")
    
    /// 分类色：花园 - 嫩绿
    static let categoryGarden_Tidy = UIColor(hexstring_Tidy: "#48BB78")
    
    /// 根据分类ID返回对应颜色
    /// 参数：
    /// - categoryId_tidy: 分类唯一标识
    /// 返回值：对应的 UIColor
    static func colorForCategory_Tidy(_ categoryId_tidy: String) -> UIColor {
        switch categoryId_tidy {
        case "living_room": return categoryLivingRoom_Tidy
        case "bedroom":     return categoryBedroom_Tidy
        case "kitchen":     return categoryKitchen_Tidy
        case "bathroom":    return categoryBathroom_Tidy
        case "study":       return categoryStudy_Tidy
        case "storage":     return categoryStorage_Tidy
        case "garden":      return categoryGarden_Tidy
        default:            return tidyMint_Tidy
        }
    }
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰（页面通用背景）
    static let backgroundPrimary_Tidy = UIColor(hexstring_Tidy: "#F7FAFC")
    
    /// 次背景色 - 纯白（卡片、弹窗背景）
    static let backgroundSecondary_Tidy = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Tidy = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰炭
    static let textPrimary_Tidy = UIColor(hexstring_Tidy: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Tidy = UIColor(hexstring_Tidy: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Tidy = UIColor(hexstring_Tidy: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Tidy = UIColor(hexstring_Tidy: "#E2E8F0")
    
    /// 边框颜色
    static let border_Tidy = UIColor(hexstring_Tidy: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Tidy = UIColor(hexstring_Tidy: "#000000", alpha_Tidy: 0.08)
}

// MARK: - UIColor扩展 - 渐变图层便捷创建

extension UIColor {
    
    /// 创建主渐变图层（薰衣草紫 → 天空蓝）
    /// 参数：
    /// - frame_Tidy: 图层尺寸
    /// 返回值：配置好的 CAGradientLayer
    static func createPrimaryGradientLayer_Tidy(frame_Tidy: CGRect) -> CAGradientLayer {
        let gradientLayer_Tidy = CAGradientLayer()
        gradientLayer_Tidy.frame = frame_Tidy
        gradientLayer_Tidy.colors = [
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor
        ]
        gradientLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Tidy.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Tidy
    }
    
    /// 创建辅助渐变图层（玫瑰粉 → 珊瑚橙）
    /// 参数：
    /// - frame_Tidy: 图层尺寸
    /// 返回值：配置好的 CAGradientLayer
    static func createSecondaryGradientLayer_Tidy(frame_Tidy: CGRect) -> CAGradientLayer {
        let gradientLayer_Tidy = CAGradientLayer()
        gradientLayer_Tidy.frame = frame_Tidy
        gradientLayer_Tidy.colors = [
            ColorConfig_Tidy.secondaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.secondaryGradientEnd_Tidy.cgColor
        ]
        gradientLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Tidy.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Tidy
    }
    
    /// 创建 Tidy 薄荷渐变图层（清新薄荷绿 → 深薄荷）
    /// 参数：
    /// - frame_Tidy: 图层尺寸
    /// - isHorizontal_Tidy: 是否水平方向渐变，默认竖向
    /// 返回值：配置好的 CAGradientLayer
    static func createTidyMintGradientLayer_Tidy(frame_Tidy: CGRect, isHorizontal_Tidy: Bool = false) -> CAGradientLayer {
        let gradientLayer_Tidy = CAGradientLayer()
        gradientLayer_Tidy.frame = frame_Tidy
        gradientLayer_Tidy.colors = [
            ColorConfig_Tidy.tidyMint_Tidy.cgColor,
            ColorConfig_Tidy.tidyMintDeep_Tidy.cgColor
        ]
        if isHorizontal_Tidy {
            gradientLayer_Tidy.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer_Tidy.endPoint = CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer_Tidy.endPoint = CGPoint(x: 1, y: 1)
        }
        return gradientLayer_Tidy
    }
    
    /// 创建分类颜色渐变图层（分类色半透明叠加效果）
    /// 参数：
    /// - categoryId_Tidy: 分类ID
    /// - frame_Tidy: 图层尺寸
    /// 返回值：配置好的 CAGradientLayer
    static func createCategoryGradientLayer_Tidy(categoryId_Tidy: String, frame_Tidy: CGRect) -> CAGradientLayer {
        let color_tidy = ColorConfig_Tidy.colorForCategory_Tidy(categoryId_Tidy)
        let gradientLayer_Tidy = CAGradientLayer()
        gradientLayer_Tidy.frame = frame_Tidy
        gradientLayer_Tidy.colors = [
            color_tidy.withAlphaComponent(0.85).cgColor,
            color_tidy.withAlphaComponent(0.6).cgColor
        ]
        gradientLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Tidy.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Tidy
    }
}
