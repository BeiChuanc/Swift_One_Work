import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Glasspaint {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Glasspaint = UIColor(hexstring_Glasspaint: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Glasspaint = UIColor(hexstring_Glasspaint: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Glasspaint = UIColor(hexstring_Glasspaint: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Glasspaint = UIColor(hexstring_Glasspaint: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Glasspaint = UIColor(hexstring_Glasspaint: "#F7FAFC")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Glasspaint = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Glasspaint = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰
    static let textPrimary_Glasspaint = UIColor(hexstring_Glasspaint: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Glasspaint = UIColor(hexstring_Glasspaint: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Glasspaint = UIColor(hexstring_Glasspaint: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Glasspaint = UIColor(hexstring_Glasspaint: "#E2E8F0")
    
    /// 边框颜色
    static let border_Glasspaint = UIColor(hexstring_Glasspaint: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Glasspaint = UIColor(hexstring_Glasspaint: "#000000", alpha_Glasspaint: 0.1)
    
    // MARK: - 难度等级颜色
    
    /// 新手等级颜色 - 薄荷绿
    static let levelBeginnerColor_Glasspaint = UIColor(hexstring_Glasspaint: "#48BB78")
    
    /// 进阶等级颜色 - 天蓝色
    static let levelIntermediateColor_Glasspaint = UIColor(hexstring_Glasspaint: "#4299E1")
    
    /// 高级等级颜色 - 紫罗兰
    static let levelAdvancedColor_Glasspaint = UIColor(hexstring_Glasspaint: "#9F7AEA")
    
    // MARK: - 风格主题颜色
    
    /// 极简风格颜色 - 极简灰
    static let styleMinimalistColor_Glasspaint = UIColor(hexstring_Glasspaint: "#718096")
    
    /// 复古风格颜色 - 复古橙
    static let styleRetroColor_Glasspaint = UIColor(hexstring_Glasspaint: "#ED8936")
    
    /// 可爱风格颜色 - 可爱粉
    static let styleCuteColor_Glasspaint = UIColor(hexstring_Glasspaint: "#FC8181")
    
    /// 现代风格颜色 - 现代蓝
    static let styleModernColor_Glasspaint = UIColor(hexstring_Glasspaint: "#4299E1")
    
    /// 艺术风格颜色 - 艺术紫
    static let styleArtisticColor_Glasspaint = UIColor(hexstring_Glasspaint: "#9F7AEA")
    
    // MARK: - 载体类型颜色
    
    /// 玻璃杯颜色 - 水蓝色
    static let carrierGlassCupColor_Glasspaint = UIColor(hexstring_Glasspaint: "#4FD1C5")
    
    /// 玻璃片颜色 - 透明灰
    static let carrierGlassPlateColor_Glasspaint = UIColor(hexstring_Glasspaint: "#A0AEC0")
    
    /// 小摆件颜色 - 琥珀黄
    static let carrierOrnamentColor_Glasspaint = UIColor(hexstring_Glasspaint: "#F6AD55")
    
    /// 花瓶颜色 - 玫瑰粉
    static let carrierVaseColor_Glasspaint = UIColor(hexstring_Glasspaint: "#FC8181")
    
    /// 窗户颜色 - 天蓝色
    static let carrierWindowColor_Glasspaint = UIColor(hexstring_Glasspaint: "#63B3ED")
    
    // MARK: - 功能颜色
    
    /// 高复刻率标签颜色 - 橙色
    static let highReplicationColor_Glasspaint = UIColor(hexstring_Glasspaint: "#F6AD55")
    
    /// 成功颜色 - 绿色
    static let successColor_Glasspaint = UIColor(hexstring_Glasspaint: "#48BB78")
    
    /// 警告颜色 - 橙色
    static let warningColor_Glasspaint = UIColor(hexstring_Glasspaint: "#ED8936")
    
    /// 排名金色
    static let rankingGoldColor_Glasspaint = UIColor(hexstring_Glasspaint: "#F6E05E")
    
    /// 排名银色
    static let rankingSilverColor_Glasspaint = UIColor(hexstring_Glasspaint: "#CBD5E0")
    
    /// 排名铜色
    static let rankingBronzeColor_Glasspaint = UIColor(hexstring_Glasspaint: "#ED8936")
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Glasspaint: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Glasspaint(frame_Glasspaint: CGRect) -> CAGradientLayer {
        let gradientLayer_Glasspaint = CAGradientLayer()
        gradientLayer_Glasspaint.frame = frame_Glasspaint
        gradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.cgColor
        ]
        gradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Glasspaint
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Glasspaint: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Glasspaint(frame_Glasspaint: CGRect) -> CAGradientLayer {
        let gradientLayer_Glasspaint = CAGradientLayer()
        gradientLayer_Glasspaint.frame = frame_Glasspaint
        gradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.secondaryGradientEnd_Glasspaint.cgColor
        ]
        gradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Glasspaint
    }
}
