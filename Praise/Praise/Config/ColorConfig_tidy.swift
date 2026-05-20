import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：围绕拍照出片主题，采用镜头蓝、暮光紫、暖日落橙等摄影感配色，强化光影与画面氛围
struct ColorConfig_Tidy {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色起点 - 暮光紫
    static let primaryGradientStart_Tidy = UIColor(hexstring_Tidy: "#7C5CFF")
    
    /// 主渐变色终点 - 镜头蓝
    static let primaryGradientEnd_Tidy = UIColor(hexstring_Tidy: "#35C2FF")
    
    /// 辅助渐变色起点 - 晚霞珊瑚
    static let secondaryGradientStart_Tidy = UIColor(hexstring_Tidy: "#FF7B72")
    
    /// 辅助渐变色终点 - 柔光琥珀
    static let secondaryGradientEnd_Tidy = UIColor(hexstring_Tidy: "#FFB457")
    
    // MARK: - Tidy 专属品牌色
    
    /// 主强调色 - 镜头蓝（品牌核心色，用于 CTA、选中态、高亮）
    static let tidyMint_Tidy = UIColor(hexstring_Tidy: "#5B8CFF")
    
    /// 品牌深色 - 深夜蓝（渐变结束色，比主色更沉稳）
    static let tidyMintDeep_Tidy = UIColor(hexstring_Tidy: "#2D4DDA")
    
    /// 暖日落色（互动反馈、点赞等暖色高亮）
    static let tidyWarm_Tidy = UIColor(hexstring_Tidy: "#FF8A4C")
    
    /// 柔雾米色（暖调中性背景）
    static let tidySand_Tidy = UIColor(hexstring_Tidy: "#FFF4E8")
    
    /// 柔金色（高光提示、徽章装饰）
    static let tidyGold_Tidy = UIColor(hexstring_Tidy: "#FFC247")
    
    // MARK: - 分类主题色（7 个分类，对应 HomeCategory id）
    
    /// 分类色：光线 - 暖金
    static let categoryLivingRoom_Tidy = UIColor(hexstring_Tidy: "#FFB547")
    
    /// 分类色：姿势 - 暮光紫
    static let categoryBedroom_Tidy = UIColor(hexstring_Tidy: "#8B7CFF")
    
    /// 分类色：构图 - 通透青蓝
    static let categoryKitchen_Tidy = UIColor(hexstring_Tidy: "#45C8FF")
    
    /// 分类色：穿搭 - 玫瑰珊瑚
    static let categoryBathroom_Tidy = UIColor(hexstring_Tidy: "#FF7A8A")
    
    /// 分类色：选景 - 清新绿
    static let categoryStudy_Tidy = UIColor(hexstring_Tidy: "#35C58B")
    
    /// 分类色：修图 - 洋红粉
    static let categoryStorage_Tidy = UIColor(hexstring_Tidy: "#FF5CA8")
    
    /// 分类色：器材 - 深蓝
    static let categoryGarden_Tidy = UIColor(hexstring_Tidy: "#4F6DFF")
    
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
    
    /// 主背景色 - 冷调浅灰蓝（页面通用背景）
    static let backgroundPrimary_Tidy = UIColor(hexstring_Tidy: "#F5F7FC")
    
    /// 次背景色 - 纯白（卡片、弹窗背景）
    static let backgroundSecondary_Tidy = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Tidy = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深石墨
    static let textPrimary_Tidy = UIColor(hexstring_Tidy: "#1F2937")
    
    /// 次文本色 - 冷灰
    static let textSecondary_Tidy = UIColor(hexstring_Tidy: "#667085")
    
    /// 占位符文本色 - 浅灰蓝
    static let textPlaceholder_Tidy = UIColor(hexstring_Tidy: "#98A2B3")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Tidy = UIColor(hexstring_Tidy: "#E6EAF2")
    
    /// 边框颜色
    static let border_Tidy = UIColor(hexstring_Tidy: "#D7DEEA")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Tidy = UIColor(hexstring_Tidy: "#000000", alpha_Tidy: 0.08)
}

// MARK: - UIColor扩展 - 渐变图层便捷创建

extension UIColor {
    
    /// 创建主渐变图层（暮光紫 → 镜头蓝）
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
    
    /// 创建辅助渐变图层（晚霞珊瑚 → 柔光琥珀）
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
    
    /// 创建品牌渐变图层（镜头蓝 → 深夜蓝）
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
