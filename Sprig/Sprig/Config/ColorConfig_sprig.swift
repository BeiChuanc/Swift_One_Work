import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Sprig {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Sprig = UIColor(hexstring_Sprig: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Sprig = UIColor(hexstring_Sprig: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Sprig = UIColor(hexstring_Sprig: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Sprig = UIColor(hexstring_Sprig: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Sprig = UIColor(hexstring_Sprig: "#F7FAFC")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Sprig = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Sprig = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰
    static let textPrimary_Sprig = UIColor(hexstring_Sprig: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Sprig = UIColor(hexstring_Sprig: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Sprig = UIColor(hexstring_Sprig: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Sprig = UIColor(hexstring_Sprig: "#E2E8F0")
    
    /// 边框颜色
    static let border_Sprig = UIColor(hexstring_Sprig: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Sprig = UIColor(hexstring_Sprig: "#000000", alpha_Sprig: 0.1)
    
    // MARK: - 花卉主题色系
    
    /// 叶绿色 - 清新自然
    static let leafGreen_Sprig = UIColor(hexstring_Sprig: "#48BB78")
    
    /// 浅叶绿 - 柔和背景
    static let softGreen_Sprig = UIColor(hexstring_Sprig: "#C6F6D5")
    
    /// 花瓣粉 - 娇嫩活力
    static let petalPink_Sprig = UIColor(hexstring_Sprig: "#F687B3")
    
    /// 浅花瓣粉 - 柔和衬底
    static let softPink_Sprig = UIColor(hexstring_Sprig: "#FED7E2")
    
    /// 花期橙 - 温暖活泼
    static let bloomOrange_Sprig = UIColor(hexstring_Sprig: "#F6AD55")
    
    /// 浅花期橙 - 背景衬托
    static let softOrange_Sprig = UIColor(hexstring_Sprig: "#FEEBC8")
    
    /// 清新薄荷绿
    static let freshMint_Sprig = UIColor(hexstring_Sprig: "#81E6D9")
    
    /// 花草主题背景色 - 极浅米白
    static let backgroundFloral_Sprig = UIColor(hexstring_Sprig: "#FAFAF7")
    
    /// 标签背景色 - 浅蓝灰
    static let tagBackground_Sprig = UIColor(hexstring_Sprig: "#EDF2F7")
    
    /// 标签选中色 - 渐变起始
    static let tagSelected_Sprig = UIColor(hexstring_Sprig: "#667EEA")
    
    /// 点赞红色
    static let likeRed_Sprig = UIColor(hexstring_Sprig: "#FC8181")
    
    /// 深紫罗兰 - 薰衣草主色
    static let lavender_Sprig = UIColor(hexstring_Sprig: "#9F7AEA")
    
    /// 金黄色 - 向日葵主色
    static let sunflowerYellow_Sprig = UIColor(hexstring_Sprig: "#F6E05E")
    
    /// 深玫红 - 玫瑰主色
    static let roseRed_Sprig = UIColor(hexstring_Sprig: "#FC8181")
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Sprig: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Sprig(frame_Sprig: CGRect) -> CAGradientLayer {
        let gradientLayer_Sprig = CAGradientLayer()
        gradientLayer_Sprig.frame = frame_Sprig
        gradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        gradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Sprig
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Sprig: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Sprig(frame_Sprig: CGRect) -> CAGradientLayer {
        let gradientLayer_Sprig = CAGradientLayer()
        gradientLayer_Sprig.frame = frame_Sprig
        gradientLayer_Sprig.colors = [
            ColorConfig_Sprig.secondaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.secondaryGradientEnd_Sprig.cgColor
        ]
        gradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Sprig
    }
    
    /// 根据十六进制颜色字符串创建渐变图层
    /// 功能：将花卉主色转换为渐变图层，用于百科卡片背景
    /// 参数：
    /// - hexColor_Sprig: 主色十六进制字符串
    /// - frame_Sprig: 图层尺寸
    /// 返回值：CAGradientLayer
    static func createFlowerGradientLayer_Sprig(hexColor_Sprig: String, frame_Sprig: CGRect) -> CAGradientLayer {
        let baseColor_Sprig = UIColor(hexstring_Sprig: hexColor_Sprig)
        let lightColor_Sprig = baseColor_Sprig.withAlphaComponent(0.6)
        let layer_Sprig = CAGradientLayer()
        layer_Sprig.frame = frame_Sprig
        layer_Sprig.colors = [lightColor_Sprig.cgColor, baseColor_Sprig.cgColor]
        layer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        layer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        return layer_Sprig
    }
}
