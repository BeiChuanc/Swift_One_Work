import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 核心作用：集中管理应用的全套主题色、情绪色、渐变色和功能色，保证页面色彩统一且丰富。
/// 设计理念：柔和渐变、温暖包容、富有疗愈感；每类颜色提供 "主色 + 浅色" 两档方便灵活运用。
struct ColorConfig_Posture {

    // MARK: - 主题色系（紫→蓝）

    /// 主渐变起点 - 薰衣草紫
    static let primaryGradientStart_Posture  = UIColor(hexstring_Posture: "#9F7AEA")

    /// 主渐变终点 - 天空蓝
    static let primaryGradientEnd_Posture    = UIColor(hexstring_Posture: "#63B3ED")

    /// 主渐变浅色 - 淡紫
    static let primaryLight_Posture          = UIColor(hexstring_Posture: "#E9D8FD")

    // MARK: - 辅助色系（粉→橙）

    /// 辅助渐变起点 - 玫瑰粉
    static let secondaryGradientStart_Posture = UIColor(hexstring_Posture: "#F687B3")

    /// 辅助渐变终点 - 珊瑚橙
    static let secondaryGradientEnd_Posture   = UIColor(hexstring_Posture: "#FC8181")

    /// 辅助浅色 - 浅玫瑰
    static let secondaryLight_Posture         = UIColor(hexstring_Posture: "#FED7E2")

    // MARK: - 薄荷绿色系

    /// 薄荷绿 - 主色
    static let accentMint_Posture   = UIColor(hexstring_Posture: "#48BB78")

    /// 薄荷绿 - 浅色
    static let accentMintLight_Posture = UIColor(hexstring_Posture: "#C6F6D5")

    // MARK: - 青色 / 海洋色系

    /// 青蓝 - 主色
    static let accentTeal_Posture      = UIColor(hexstring_Posture: "#38B2AC")

    /// 青蓝 - 浅色
    static let accentTealLight_Posture = UIColor(hexstring_Posture: "#B2F5EA")

    // MARK: - 靛蓝 / 深蓝色系

    /// 靛蓝 - 主色
    static let accentIndigo_Posture      = UIColor(hexstring_Posture: "#667EEA")

    /// 靛蓝 - 浅色
    static let accentIndigoLight_Posture = UIColor(hexstring_Posture: "#C3DAFE")

    // MARK: - 珊瑚红 / 暖红色系

    /// 珊瑚红 - 主色
    static let accentCoral_Posture      = UIColor(hexstring_Posture: "#FC8181")

    /// 珊瑚红 - 浅色
    static let accentCoralLight_Posture = UIColor(hexstring_Posture: "#FED7D7")

    // MARK: - 琥珀 / 暖黄色系

    /// 琥珀橙 - 主色
    static let accentAmber_Posture      = UIColor(hexstring_Posture: "#F6AD55")

    /// 琥珀橙 - 浅色
    static let accentAmberLight_Posture = UIColor(hexstring_Posture: "#FEFCBF")

    // MARK: - 青紫 / 霓虹色系

    /// 霓虹青紫 - 主色
    static let accentCyan_Posture      = UIColor(hexstring_Posture: "#4FD1C5")

    /// 霓虹青紫 - 浅色
    static let accentCyanLight_Posture = UIColor(hexstring_Posture: "#E6FFFA")

    // MARK: - 品红 / 洋红色系

    /// 品红 - 主色
    static let accentFuchsia_Posture      = UIColor(hexstring_Posture: "#D53F8C")

    /// 品红 - 浅色
    static let accentFuchsiaLight_Posture = UIColor(hexstring_Posture: "#FED7E2")

    // MARK: - 柠檬黄绿色系

    /// 黄绿 - 主色
    static let accentLime_Posture      = UIColor(hexstring_Posture: "#68D391")

    /// 黄绿 - 浅色
    static let accentLimeLight_Posture = UIColor(hexstring_Posture: "#F0FFF4")

    // MARK: - 背景色

    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Posture   = UIColor(hexstring_Posture: "#F7FAFC")

    /// 次背景色 - 纯白
    static let backgroundSecondary_Posture = UIColor.white

    /// 卡片背景色
    static let cardBackground_Posture      = UIColor.white

    // MARK: - 文本色

    /// 主文本色 - 深灰
    static let textPrimary_Posture     = UIColor(hexstring_Posture: "#2D3748")

    /// 次文本色 - 中灰
    static let textSecondary_Posture   = UIColor(hexstring_Posture: "#718096")

    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Posture = UIColor(hexstring_Posture: "#A0AEC0")

    // MARK: - 分割线和边框

    /// 分割线颜色
    static let divider_Posture = UIColor(hexstring_Posture: "#E2E8F0")

    /// 边框颜色
    static let border_Posture  = UIColor(hexstring_Posture: "#CBD5E0")

    // MARK: - 阴影色

    /// 卡片阴影色
    static let shadowColor_Posture = UIColor(hexstring_Posture: "#000000", alpha_Posture: 0.08)

    // MARK: - 调色盘（按索引循环取色）

    /// 卡片装饰色调色盘（主色、浅色、对应阴影）
    /// 设计思路：每个帖子按 index % count 取色，让瀑布流中每张卡片都有独立颜色个性
    static let cardAccentPalette_Posture: [(main: UIColor, light: UIColor, shadow: UIColor)] = [
        (accentIndigo_Posture,  accentIndigoLight_Posture,  accentIndigo_Posture.withAlphaComponent(0.25)),
        (accentTeal_Posture,    accentTealLight_Posture,    accentTeal_Posture.withAlphaComponent(0.25)),
        (secondaryGradientStart_Posture, secondaryLight_Posture, secondaryGradientStart_Posture.withAlphaComponent(0.25)),
        (accentAmber_Posture,   accentAmberLight_Posture,   accentAmber_Posture.withAlphaComponent(0.25)),
        (accentMint_Posture,    accentMintLight_Posture,    accentMint_Posture.withAlphaComponent(0.25)),
        (accentCoral_Posture,   accentCoralLight_Posture,   accentCoral_Posture.withAlphaComponent(0.25)),
        (accentCyan_Posture,    accentCyanLight_Posture,    accentCyan_Posture.withAlphaComponent(0.25)),
        (accentFuchsia_Posture, accentFuchsiaLight_Posture, accentFuchsia_Posture.withAlphaComponent(0.25)),
        (primaryGradientStart_Posture, primaryLight_Posture, primaryGradientStart_Posture.withAlphaComponent(0.25)),
        (accentLime_Posture,    accentLimeLight_Posture,    accentLime_Posture.withAlphaComponent(0.25)),
    ]

    /// 背景光晕颜色列表（用于页面背景装饰圆）
    static let glowPalette_Posture: [UIColor] = [
        accentIndigo_Posture.withAlphaComponent(0.18),
        accentTeal_Posture.withAlphaComponent(0.16),
        secondaryGradientStart_Posture.withAlphaComponent(0.16),
        accentAmber_Posture.withAlphaComponent(0.15),
        accentMint_Posture.withAlphaComponent(0.17),
        accentCyan_Posture.withAlphaComponent(0.16),
    ]

    // MARK: - 分类标签配色映射

    /// 根据标签关键字返回 (标签背景色, 标签文字色) 的颜色对
    /// - Parameter tag_Posture: 标签文字（如 "NECK"、"CORE" 等）
    /// - Returns: (UIColor, UIColor) - 背景色与文字色
    static func tagColors_Posture(for tag_Posture: String) -> (bg: UIColor, text: UIColor) {
        switch tag_Posture.uppercased() {
        case "NECK":
            return (accentCoralLight_Posture, accentCoral_Posture)
        case "CORE":
            return (accentTealLight_Posture, accentTeal_Posture)
        case "DESK":
            return (accentIndigoLight_Posture, accentIndigo_Posture)
        case "WALK":
            return (accentMintLight_Posture, accentMint_Posture)
        case "BACK":
            return (accentAmberLight_Posture, accentAmber_Posture)
        case "BREATH":
            return (accentCyanLight_Posture, accentCyan_Posture)
        default:
            return (primaryLight_Posture, primaryGradientStart_Posture)
        }
    }

    /// 根据分类索引返回胶囊颜色对（用于循环着色）
    /// - Parameter index_Posture: 胶囊排序索引
    /// - Returns: (UIColor, UIColor) - 背景色与图标/文字色
    static func chipColors_Posture(at index_Posture: Int) -> (bg: UIColor, tint: UIColor) {
        let palette_Posture: [(UIColor, UIColor)] = [
            (accentIndigoLight_Posture,  accentIndigo_Posture),
            (accentTealLight_Posture,    accentTeal_Posture),
            (accentAmberLight_Posture,   accentAmber_Posture),
            (accentMintLight_Posture,    accentMint_Posture),
            (accentCoralLight_Posture,   accentCoral_Posture),
            (accentCyanLight_Posture,    accentCyan_Posture),
        ]
        let idx_Posture = index_Posture % palette_Posture.count
        return palette_Posture[idx_Posture]
    }
}

// MARK: - UIColor 渐变工具扩展

extension UIColor {

    /// 创建主渐变图层（薰衣草紫→天空蓝）
    /// - Parameter frame_Posture: 目标尺寸
    /// - Returns: CAGradientLayer - 已配置的渐变图层
    static func createPrimaryGradientLayer_Posture(frame_Posture: CGRect) -> CAGradientLayer {
        makeGradient_Posture(
            colors_Posture: [ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
                             ColorConfig_Posture.primaryGradientEnd_Posture.cgColor],
            frame_Posture: frame_Posture
        )
    }

    /// 创建辅助渐变图层（玫瑰粉→珊瑚橙）
    /// - Parameter frame_Posture: 目标尺寸
    /// - Returns: CAGradientLayer - 已配置的渐变图层
    static func createSecondaryGradientLayer_Posture(frame_Posture: CGRect) -> CAGradientLayer {
        makeGradient_Posture(
            colors_Posture: [ColorConfig_Posture.secondaryGradientStart_Posture.cgColor,
                             ColorConfig_Posture.secondaryGradientEnd_Posture.cgColor],
            frame_Posture: frame_Posture
        )
    }

    /// 创建鲜活三色渐变图层（靛蓝→青蓝→薄荷绿）
    /// - Parameter frame_Posture: 目标尺寸
    /// - Returns: CAGradientLayer - 已配置的渐变图层
    static func createVividGradientLayer_Posture(frame_Posture: CGRect) -> CAGradientLayer {
        makeGradient_Posture(
            colors_Posture: [ColorConfig_Posture.accentIndigo_Posture.cgColor,
                             ColorConfig_Posture.accentTeal_Posture.cgColor,
                             ColorConfig_Posture.accentMint_Posture.cgColor],
            frame_Posture: frame_Posture
        )
    }

    /// 创建暖色渐变图层（珊瑚→琥珀→粉）
    /// - Parameter frame_Posture: 目标尺寸
    /// - Returns: CAGradientLayer - 已配置的渐变图层
    static func createWarmGradientLayer_Posture(frame_Posture: CGRect) -> CAGradientLayer {
        makeGradient_Posture(
            colors_Posture: [ColorConfig_Posture.accentCoral_Posture.cgColor,
                             ColorConfig_Posture.accentAmber_Posture.cgColor,
                             ColorConfig_Posture.secondaryGradientStart_Posture.cgColor],
            frame_Posture: frame_Posture
        )
    }

    /// 内部通用渐变图层工厂
    /// - Parameters:
    ///   - colors_Posture: cgColor 数组
    ///   - frame_Posture: 目标尺寸
    /// - Returns: CAGradientLayer
    private static func makeGradient_Posture(colors_Posture: [CGColor], frame_Posture: CGRect) -> CAGradientLayer {
        let layer_Posture = CAGradientLayer()
        layer_Posture.frame = frame_Posture
        layer_Posture.colors = colors_Posture
        layer_Posture.startPoint = CGPoint(x: 0, y: 0)
        layer_Posture.endPoint   = CGPoint(x: 1, y: 1)
        return layer_Posture
    }
}
