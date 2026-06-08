import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖时尚、精致奢华感
struct ColorConfig_Vestir {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色起点 - 薰衣草紫
    static let primaryGradientStart_Vestir = UIColor(hexstring_Vestir: "#B794F6")
    
    /// 主渐变色终点 - 天空蓝
    static let primaryGradientEnd_Vestir = UIColor(hexstring_Vestir: "#90CDF4")
    
    /// 辅助渐变色起点 - 玫瑰粉
    static let secondaryGradientStart_Vestir = UIColor(hexstring_Vestir: "#FBB6CE")
    
    /// 辅助渐变色终点 - 珊瑚橙
    static let secondaryGradientEnd_Vestir = UIColor(hexstring_Vestir: "#FED7AA")
    
    /// 暖调渐变色起点 - 蜜桃粉（发现页顶部装饰）
    static let warmGradientStart_Vestir = UIColor(hexstring_Vestir: "#F9A8D4")
    
    /// 暖调渐变色终点 - 浅橙金
    static let warmGradientEnd_Vestir = UIColor(hexstring_Vestir: "#FDE68A")
    
    // MARK: - 背景色
    
    /// 主背景色 - 暖奶白（时尚感）
    static let backgroundPrimary_Vestir = UIColor(hexstring_Vestir: "#FFFBF7")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Vestir = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Vestir = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深暖褐
    static let textPrimary_Vestir = UIColor(hexstring_Vestir: "#2D2926")
    
    /// 次文本色 - 中暖灰
    static let textSecondary_Vestir = UIColor(hexstring_Vestir: "#7C7069")
    
    /// 占位符文本色 - 浅暖灰
    static let textPlaceholder_Vestir = UIColor(hexstring_Vestir: "#B8AFA9")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色 - 暖米色
    static let divider_Vestir = UIColor(hexstring_Vestir: "#F0EAE4")
    
    /// 边框颜色
    static let border_Vestir = UIColor(hexstring_Vestir: "#E8DDD6")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色 - 紫调阴影（区别于冷灰阴影，更有时尚感）
    static let shadowColor_Vestir = UIColor(hexstring_Vestir: "#B794F6", alpha_Vestir: 0.18)
    
    // MARK: - 功能强调色
    
    /// 点赞心形色 - 柔玫瑰红
    static let heartColor_Vestir = UIColor(hexstring_Vestir: "#FB7185")
    
    /// 标签徽章背景色 - 极浅薰衣草
    static let tagPill_Vestir = UIColor(hexstring_Vestir: "#F3EEFF")
    
    /// 标签徽章文字色 - 深紫
    static let tagPillText_Vestir = UIColor(hexstring_Vestir: "#7C3AED")
}

// MARK: - UIColor扩展 - 渐变图层工厂

extension UIColor {
    
    /// 创建主渐变图层（薰衣草紫 → 天空蓝，对角方向）
    /// 参数：
    /// - frame_Vestir: 渐变图层的尺寸
    /// 返回值：配置好的渐变图层
    static func createPrimaryGradientLayer_Vestir(frame_Vestir: CGRect) -> CAGradientLayer {
        let gradientLayer_Vestir = CAGradientLayer()
        gradientLayer_Vestir.frame = frame_Vestir
        gradientLayer_Vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor
        ]
        gradientLayer_Vestir.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Vestir.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Vestir
    }
    
    /// 创建辅助渐变图层（玫瑰粉 → 珊瑚橙，对角方向）
    /// 参数：
    /// - frame_Vestir: 渐变图层的尺寸
    /// 返回值：配置好的渐变图层
    static func createSecondaryGradientLayer_Vestir(frame_Vestir: CGRect) -> CAGradientLayer {
        let gradientLayer_Vestir = CAGradientLayer()
        gradientLayer_Vestir.frame = frame_Vestir
        gradientLayer_Vestir.colors = [
            ColorConfig_Vestir.secondaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.secondaryGradientEnd_Vestir.cgColor
        ]
        gradientLayer_Vestir.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Vestir.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Vestir
    }
    
    /// 创建暖调渐变图层（蜜桃粉 → 浅橙金，横向渐变，用于导航装饰线）
    /// 参数：
    /// - frame_Vestir: 渐变图层的尺寸
    /// 返回值：配置好的渐变图层
    static func createWarmGradientLayer_Vestir(frame_Vestir: CGRect) -> CAGradientLayer {
        let gradientLayer_Vestir = CAGradientLayer()
        gradientLayer_Vestir.frame = frame_Vestir
        gradientLayer_Vestir.colors = [
            ColorConfig_Vestir.warmGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.warmGradientEnd_Vestir.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer_Vestir
    }
}
