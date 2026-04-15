import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Epoch {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Epoch = UIColor(hexstring_Epoch: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Epoch = UIColor(hexstring_Epoch: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Epoch = UIColor(hexstring_Epoch: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Epoch = UIColor(hexstring_Epoch: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Epoch = UIColor(hexstring_Epoch: "#F7FAFC")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Epoch = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Epoch = UIColor.white

    /// 柔和面板背景色
    static let surfaceTint_Epoch = UIColor(hexstring_Epoch: "#FFF8FE")
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰
    static let textPrimary_Epoch = UIColor(hexstring_Epoch: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Epoch = UIColor(hexstring_Epoch: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Epoch = UIColor(hexstring_Epoch: "#A0AEC0")

    /// 反白文本色
    static let textOnDark_Epoch = UIColor(hexstring_Epoch: "#FFFDFE")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Epoch = UIColor(hexstring_Epoch: "#E2E8F0")
    
    /// 边框颜色
    static let border_Epoch = UIColor(hexstring_Epoch: "#CBD5E0")

    /// 轻强调边框
    static let accentBorder_Epoch = UIColor(hexstring_Epoch: "#E9D8FD")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Epoch = UIColor(hexstring_Epoch: "#000000", alpha_Epoch: 0.1)

    // MARK: - 强调色

    /// 紫色强调
    static let accentPurple_Epoch = UIColor(hexstring_Epoch: "#9F7AEA")

    /// 粉色强调
    static let accentPink_Epoch = UIColor(hexstring_Epoch: "#ED64A6")

    /// 琥珀强调
    static let accentGold_Epoch = UIColor(hexstring_Epoch: "#F6AD55")

    /// 薄雾蓝强调
    static let accentBlue_Epoch = UIColor(hexstring_Epoch: "#63B3ED")

    /// 深色遮罩
    static let darkOverlay_Epoch = UIColor(hexstring_Epoch: "#1A202C", alpha_Epoch: 0.16)
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Epoch: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Epoch(frame_Epoch: CGRect) -> CAGradientLayer {
        let gradientLayer_Epoch = CAGradientLayer()
        gradientLayer_Epoch.frame = frame_Epoch
        gradientLayer_Epoch.colors = [
            ColorConfig_Epoch.primaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.primaryGradientEnd_Epoch.cgColor
        ]
        gradientLayer_Epoch.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Epoch.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Epoch
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Epoch: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Epoch(frame_Epoch: CGRect) -> CAGradientLayer {
        let gradientLayer_Epoch = CAGradientLayer()
        gradientLayer_Epoch.frame = frame_Epoch
        gradientLayer_Epoch.colors = [
            ColorConfig_Epoch.secondaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.secondaryGradientEnd_Epoch.cgColor
        ]
        gradientLayer_Epoch.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Epoch.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Epoch
    }
}
