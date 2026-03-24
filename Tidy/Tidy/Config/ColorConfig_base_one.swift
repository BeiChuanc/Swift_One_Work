import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：清新家居感、明快有质感，以薄荷绿为主调、珊瑚暖色为点缀，呈现整洁灵动的现代家居氛围
struct ColorConfig_Base_one {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色起点 - 薰衣草紫
    static let primaryGradientStart_Base_one = UIColor(hexstring_Base_one: "#B794F6")
    
    /// 主渐变色终点 - 天空蓝
    static let primaryGradientEnd_Base_one = UIColor(hexstring_Base_one: "#90CDF4")
    
    /// 辅助渐变色起点 - 玫瑰粉
    static let secondaryGradientStart_Base_one = UIColor(hexstring_Base_one: "#FBB6CE")
    
    /// 辅助渐变色终点 - 珊瑚橙
    static let secondaryGradientEnd_Base_one = UIColor(hexstring_Base_one: "#FED7AA")
    
    // MARK: - Tidy 专属品牌色
    
    /// 主强调色 - 清新薄荷绿（品牌核心色，用于 CTA、选中态、高亮）
    static let tidyMint_Base_one = UIColor(hexstring_Base_one: "#4ECDC4")
    
    /// 薄荷渐变深色（渐变结束色，比主色略深）
    static let tidyMintDeep_Base_one = UIColor(hexstring_Base_one: "#38B2AC")
    
    /// 暖珊瑚色（互动反馈、点赞等暖色高亮）
    static let tidyWarm_Base_one = UIColor(hexstring_Base_one: "#FF6B6B")
    
    /// 米白背景色（首页 Header 底色，温暖中性）
    static let tidySand_Base_one = UIColor(hexstring_Base_one: "#F7F3EE")
    
    /// 柔金色（徽章、统计数字装饰）
    static let tidyGold_Base_one = UIColor(hexstring_Base_one: "#F6AD55")
    
    // MARK: - 分类主题色（7 个分类，对应 HomeCategory id）
    
    /// 分类色：客厅 - 淡蓝绿
    static let categoryLivingRoom_Base_one = UIColor(hexstring_Base_one: "#4ECDC4")
    
    /// 分类色：卧室 - 薰衣草紫
    static let categoryBedroom_Base_one = UIColor(hexstring_Base_one: "#9F7AEA")
    
    /// 分类色：厨房 - 暖橙
    static let categoryKitchen_Base_one = UIColor(hexstring_Base_one: "#F6AD55")
    
    /// 分类色：浴室 - 水蓝
    static let categoryBathroom_Base_one = UIColor(hexstring_Base_one: "#63B3ED")
    
    /// 分类色：书房 - 森绿
    static let categoryStudy_Base_one = UIColor(hexstring_Base_one: "#68D391")
    
    /// 分类色：收纳 - 玫瑰粉
    static let categoryStorage_Base_one = UIColor(hexstring_Base_one: "#FC8181")
    
    /// 分类色：花园 - 嫩绿
    static let categoryGarden_Base_one = UIColor(hexstring_Base_one: "#48BB78")
    
    /// 根据分类ID返回对应颜色
    /// 参数：
    /// - categoryId_base_one: 分类唯一标识
    /// 返回值：对应的 UIColor
    static func colorForCategory_Base_one(_ categoryId_base_one: String) -> UIColor {
        switch categoryId_base_one {
        case "living_room": return categoryLivingRoom_Base_one
        case "bedroom":     return categoryBedroom_Base_one
        case "kitchen":     return categoryKitchen_Base_one
        case "bathroom":    return categoryBathroom_Base_one
        case "study":       return categoryStudy_Base_one
        case "storage":     return categoryStorage_Base_one
        case "garden":      return categoryGarden_Base_one
        default:            return tidyMint_Base_one
        }
    }
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰（页面通用背景）
    static let backgroundPrimary_Base_one = UIColor(hexstring_Base_one: "#F7FAFC")
    
    /// 次背景色 - 纯白（卡片、弹窗背景）
    static let backgroundSecondary_Base_one = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Base_one = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰炭
    static let textPrimary_Base_one = UIColor(hexstring_Base_one: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Base_one = UIColor(hexstring_Base_one: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Base_one = UIColor(hexstring_Base_one: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Base_one = UIColor(hexstring_Base_one: "#E2E8F0")
    
    /// 边框颜色
    static let border_Base_one = UIColor(hexstring_Base_one: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Base_one = UIColor(hexstring_Base_one: "#000000", alpha_Base_one: 0.08)
}

// MARK: - UIColor扩展 - 渐变图层便捷创建

extension UIColor {
    
    /// 创建主渐变图层（薰衣草紫 → 天空蓝）
    /// 参数：
    /// - frame_Base_one: 图层尺寸
    /// 返回值：配置好的 CAGradientLayer
    static func createPrimaryGradientLayer_Base_one(frame_Base_one: CGRect) -> CAGradientLayer {
        let gradientLayer_Base_one = CAGradientLayer()
        gradientLayer_Base_one.frame = frame_Base_one
        gradientLayer_Base_one.colors = [
            ColorConfig_Base_one.primaryGradientStart_Base_one.cgColor,
            ColorConfig_Base_one.primaryGradientEnd_Base_one.cgColor
        ]
        gradientLayer_Base_one.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Base_one.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Base_one
    }
    
    /// 创建辅助渐变图层（玫瑰粉 → 珊瑚橙）
    /// 参数：
    /// - frame_Base_one: 图层尺寸
    /// 返回值：配置好的 CAGradientLayer
    static func createSecondaryGradientLayer_Base_one(frame_Base_one: CGRect) -> CAGradientLayer {
        let gradientLayer_Base_one = CAGradientLayer()
        gradientLayer_Base_one.frame = frame_Base_one
        gradientLayer_Base_one.colors = [
            ColorConfig_Base_one.secondaryGradientStart_Base_one.cgColor,
            ColorConfig_Base_one.secondaryGradientEnd_Base_one.cgColor
        ]
        gradientLayer_Base_one.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Base_one.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Base_one
    }
    
    /// 创建 Tidy 薄荷渐变图层（清新薄荷绿 → 深薄荷）
    /// 参数：
    /// - frame_Base_one: 图层尺寸
    /// - isHorizontal_Base_one: 是否水平方向渐变，默认竖向
    /// 返回值：配置好的 CAGradientLayer
    static func createTidyMintGradientLayer_Base_one(frame_Base_one: CGRect, isHorizontal_Base_one: Bool = false) -> CAGradientLayer {
        let gradientLayer_Base_one = CAGradientLayer()
        gradientLayer_Base_one.frame = frame_Base_one
        gradientLayer_Base_one.colors = [
            ColorConfig_Base_one.tidyMint_Base_one.cgColor,
            ColorConfig_Base_one.tidyMintDeep_Base_one.cgColor
        ]
        if isHorizontal_Base_one {
            gradientLayer_Base_one.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer_Base_one.endPoint = CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer_Base_one.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer_Base_one.endPoint = CGPoint(x: 1, y: 1)
        }
        return gradientLayer_Base_one
    }
    
    /// 创建分类颜色渐变图层（分类色半透明叠加效果）
    /// 参数：
    /// - categoryId_Base_one: 分类ID
    /// - frame_Base_one: 图层尺寸
    /// 返回值：配置好的 CAGradientLayer
    static func createCategoryGradientLayer_Base_one(categoryId_Base_one: String, frame_Base_one: CGRect) -> CAGradientLayer {
        let color_base_one = ColorConfig_Base_one.colorForCategory_Base_one(categoryId_Base_one)
        let gradientLayer_Base_one = CAGradientLayer()
        gradientLayer_Base_one.frame = frame_Base_one
        gradientLayer_Base_one.colors = [
            color_base_one.withAlphaComponent(0.85).cgColor,
            color_base_one.withAlphaComponent(0.6).cgColor
        ]
        gradientLayer_Base_one.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Base_one.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Base_one
    }
}
